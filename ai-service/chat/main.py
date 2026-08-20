import asyncio
import re
import sys
from pathlib import Path
from langchain.agents import create_agent
from langchain_mcp_adapters.client import MultiServerMCPClient
from typing import Any
from contextlib import AsyncExitStack
from langchain_core.messages import AIMessage, BaseMessage, HumanMessage
from llm import get_llm
from chat.intent import (Intent, classify, needs_history,
                         no_history_answer, out_of_scope_answer)
from chat.links import reservation_links, salon_link
from time import monotonic

from langchain_mcp_adapters.tools import load_mcp_tools
from langchain_mcp_adapters.resources import load_mcp_resources
from langchain_mcp_adapters.prompts import load_mcp_prompt

PYTHON_SERVICE_DIR = Path(__file__).parent/".." #python-service 디렉토리 경로
MCP_SERVER_MODULE = "mcp_chat.mcp_product_server"   #MCP 서버 모듈 경로
RESOURCE_URI = "catalog://salon/search-guide"      #리소스 경로

# 상담 한 건이 붙잡을 수 있는 시간의 상한
#
# 상담은 _invoke_lock 으로 한 번에 하나씩 처리하는데, 상한이 없으면 요청 하나가 멈췄을 때
# 락이 영원히 안 풀려 이후 모든 사용자가 무한정 대기함(재기동 외에 복구 수단이 없음)
# 실제로 클라이언트가 중간에 끊긴 뒤 서비스 전체가 잠긴 적이 있음
# 둘을 더한 값이 Spring 의 readTimeout(120초)보다 작아야 Spring 이 먼저 끊지 않음
LOCK_WAIT_SECONDS = 25      # 앞 사람 답변을 기다려주는 시간
AGENT_TIMEOUT_SECONDS = 90  # 한 건이 LLM·도구에 쓸 수 있는 시간

# system_prompt로 마크다운 금지를 지시해도 모델이 종종 무시해서, 응답 문자열에서 강제로 벗겨냄
_MD_BOLD_RE = re.compile(r"\*\*(.+?)\*\*")
_MD_HEADING_RE = re.compile(r"^#{1,6}\s*", re.MULTILINE)
_MD_BULLET_RE = re.compile(r"^[ \t]*[-*]\s+", re.MULTILINE)

def _strip_markdown(text: str) -> str:
    text = _MD_BOLD_RE.sub(r"\1", text)
    text = _MD_HEADING_RE.sub("", text)
    text = _MD_BULLET_RE.sub("", text)
    return text

# 도구 이름이 답변에 그대로 나간 적이 있음
# ("현재 제공된 도구(search_service, list_catalog, prepare_service_index)는 ...")
_INTERNAL_RE = re.compile(
    r"search_service|list_catalog|prepare_service_index"
    r"|MCP|tool\b|툴\s*(호출|을|를|이|가)"
    r"|(제공된|사용\s*가능한|현재|해당|이런|위의)\s*도구"
    r"|도구\s*(목록|이름|를|가|는|로|에는)",
    re.IGNORECASE,
)

# 예약은 이 서비스가 직접 처리하므로 외부 경로 안내는 전부 오답
# "전화"는 매장 연락처라 제외
_EXTERNAL_BOOKING_RE = re.compile(r"카카오|네이버|인스타|왓츠앱|\bDM\b", re.IGNORECASE)

_DROP_SENTENCE_RES = (_INTERNAL_RE, _EXTERNAL_BOOKING_RE)

# 줄바꿈은 문단 구분이라 살리고 같은 줄 안에서만 나눔
_SENTENCE_SPLIT_RE = re.compile(r"(?<=[.!?])\s+")


def _strip_internal(text: str) -> str:
    """도구 이름이나 외부 예약 경로가 드러난 문장을 지움 — 프롬프트만 믿지 않고 한 번 더 거름"""
    lines = []
    for line in text.split("\n"):
        kept = [
            sentence for sentence in _SENTENCE_SPLIT_RE.split(line)
            if sentence.strip()
            and not any(rule.search(sentence) for rule in _DROP_SENTENCE_RES)
        ]
        lines.append(" ".join(kept))

    # 문장이 날아간 자리에 빈 줄이 겹치지 않도록
    return re.sub(r"\n{3,}", "\n\n", "\n".join(lines)).strip()

# MCP 연결 및 세션관리
class McpChatService:
    def __init__(self) -> None:
        self._client: MultiServerMCPClient | None = None    # MCP 클라이언트 객체
        self._agent: Any = None                             # MCP 에이전트 객체

        self._start_lock = asyncio.Lock()
        self._invoke_lock = asyncio.Lock()
        self._exit_stack: AsyncExitStack | None = None

        # 메시지 리스트
        self._base_messages: list[BaseMessage] = []

        # 세션별 메시지 리스트
        self._messages_by_session: dict[str, list[BaseMessage]] = {}

        # 세션별 마지막 접근시간
        self._last_access_by_session: dict[str, float] = {}

        # 매 턴 같은 매장을 다시 붙이지 않으려고 들고 있음
        self._salon_by_session: dict[str, int] = {}

    # MCP 서버 연결 및 에이전트 객체 생성
    async def start(self) -> None:
        # Fast-API 서버의 에이전트 객체는 오직 한개만 생성
        if self._agent is not None:
            return

        # 동시접근 방지(에이전트 객체가 생성 중에 다른 클라이언트의 에이전트 생성 요청이 들어오면 리턴)
        async with self._start_lock:
            # 락을 얻는 동안 다른 요청이 먼저 생성을 끝냈을 수 있으므로 다시 확인
            if self._agent is not None:
                return

            # 비동기 코드 종료 시 자원정리
            exit_stack = AsyncExitStack()

            # MCP 클라이언트 객체 생성(MCP 서버와 통신)
            try:
                client = MultiServerMCPClient(
                    {
                        "products" : {
                            "transport" : "stdio",
                            "command" : sys.executable,
                            "args" : ["-m", MCP_SERVER_MODULE],
                            "cwd" : str(PYTHON_SERVICE_DIR)
                        }
                    }
                )

                # MCP 세션 생성(MCP 서버와 통신)
                session = await exit_stack.enter_async_context(
                    client.session("products")
                )
                # MCP 도구 가져오기
                tools = await load_mcp_tools(session)
                # MCP 리소스 가져오기
                resource = await load_mcp_resources(
                    session,
                    uris = RESOURCE_URI
                )
                # MCP 프롬프트 로드
                prompt = await load_mcp_prompt(
                    session,
                    "salon_consult_prompt",
                    arguments = {"tone" : "친절하고 전문적인"}
                )
                # 에이전트 생성
                agent = create_agent(
                    get_llm(),
                    tools,
                    system_prompt=(
                        "시술 정보는 MCP Tool 결과만 근거로 답하세요."
                        "검색 결과에 없는 시술, 가격, 소요시간은 만들지 마세요."
                        "Tool 호출 여부와 인자는 현재 질문과 대화 기록을 바탕으로 판단하세요."
                        "대화 기록에 [사용자 예약 이력]이 있으면 참고해 그 취향/고민에 맞는 시술을 우선 추천하되,"
                        "이력에 없는 내용을 추천 근거로 지어내지 마세요. 이력이 없으면 일반 상담으로 답하세요."
                        # 이력의 매장명을 쓰라고 명시하지 않으면 단골과 무관한 매장을 그냥 던짐
                        "예약 이력에 매장명이 있으면, 추천할 시술이 그 매장에도 있는지 Tool 결과에서 먼저 확인하세요."
                        "그 매장에 없으면 '자주 가시는 OO에는 없어서' 라고 밝히고 다른 매장을 안내하세요."
                        # 되묻기를 먼저 시키면 추천 자체를 건너뛰어서, 검색 결과를 낸 뒤에만 되묻게 함
                        "추천 요청에는 반드시 Tool 로 찾은 시술을 먼저 제시하세요. 되묻기만 하고 끝내지 마세요."
                        "제시한 뒤에 더 좁힐 여지가 있으면 마지막에 질문을 하나만 덧붙이세요."
                        "시술명 없이 증상만 말한 경우(예: '머리 상했어요')에만 검색 전에 한 가지를 되물어도 됩니다."
                        # 도구 이름을 나열한 답이 화면에 나간 적 있음
                        "search_service, list_catalog, prepare_service_index 같은 도구 이름과 "
                        "Tool, MCP, 검색 과정은 내부 동작이므로 답변에 쓰지 마세요."
                        "찾지 못했을 때도 도구를 핑계로 들지 말고 '등록된 시술 중에는 없습니다' 라고 답하세요."
                        # 카카오톡·네이버예약·인스타 DM 을 안내한 적 있음
                        "예약은 이 서비스의 예약 화면에서 진행됩니다."
                        "전화, 카카오톡, 네이버 예약, 인스타그램 DM 같은 외부 예약 방법을 안내하지 마세요."
                    )
                )

                self._client = client
                self._agent = agent
                self._exit_stack = exit_stack
                self._base_messages = [
                    *prompt,
                    HumanMessage(content=f"[MCP Resource]: {RESOURCE_URI}\n"
                                         f"{resource[0].as_string()}")

                ]
            except Exception:
                await exit_stack.aclose()
                raise

    # "여성컷(컷, 라움헤어)" 형태의 이력 문자열에서 매장명만 뽑음
    # 마지막 괄호 안 항목이 AiChatController.formatHistoryItem 이 붙인 매장명임
    @staticmethod
    def _salons_from_context(user_context: str) -> list[str]:
        salons: list[str] = []
        for inner in re.findall(r'\(([^)]*)\)', user_context):
            parts = [p.strip() for p in inner.split(',')]
            if len(parts) >= 2 and parts[-1] and parts[-1] not in salons:
                salons.append(parts[-1])
        return salons

    # 이력 매장이 실제로 뭘 취급하는지 미리 붙여줌
    # LLM 에게 "매번 매장을 확인해라" 라고 지시만 하면 첫 턴에서 건너뛰는 일이 잦아,
    # 판단을 맡기는 대신 데이터를 먼저 쥐여주는 방식으로 바꿈
    @staticmethod
    def _salon_catalog_hint(user_context: str) -> str | None:
        try:
            from search.elasticsearch_store import list_services
        except Exception:
            return None

        lines: list[str] = []
        for salon in McpChatService._salons_from_context(user_context):
            try:
                items = list_services(salon=salon, count=20)
            except Exception:
                continue
            if not items:
                continue
            listed = ", ".join(
                f"{i['name']}({i['category']}/{i['price']}원)" for i in items
            )
            lines.append(f"- {salon}: {listed}")

        if not lines:
            return None
        return (
            "[이력 매장이 취급하는 시술 전체]\n"
            + "\n".join(lines)
            + "\n이 목록에 없는 시술은 해당 매장에서 받을 수 없습니다."
        )

    # 매장 상세 페이지에서 연 상담
    # 후보가 카탈로그 전체에서 그 매장 몇 건으로 줄어 환각이 줄고 빨라짐
    @staticmethod
    def _current_salon_hint(salon_id: int) -> str | None:
        try:
            from search.elasticsearch_store import list_services
            items = list_services(salon_id=salon_id, count=50)
        except Exception:
            return None

        if not items:
            return None

        salon_name = items[0].get("salon_name") or ""
        listed = "\n".join(
            f"- {i.get('name')} ({i.get('category')}/{i.get('price')}원/"
            f"{i.get('duration_min', 0)}분)"
            for i in items
        )
        return (
            f"[지금 사용자가 보고 있는 매장: {salon_name}]\n"
            f"{listed}\n"
            f"사용자는 {salon_name} 의 예약 화면에서 상담을 열었습니다. "
            "이 목록에 있는 시술을 먼저 추천하고, 목록에 없는 시술을 물으면 "
            f"{salon_name} 에는 없다고 밝힌 뒤 다른 매장을 안내하세요."
        )

    @staticmethod
    def _salon_find_hint(question: str) -> str | None:
        try:
            from search.salon_store import salon_find_hint
            return salon_find_hint(question)
        except Exception:
            return None

    # 에이전트가 돌려준 메시지 더미에서 실제 답변 문장을 꺼냄
    #
    # 마지막 메시지를 그냥 쓰면 빈 답변이 나감 — recursion_limit 에 걸려 멈추면
    # 끝 메시지가 "도구를 부르려던 중"인 AIMessage 라서 content 가 비어 있음
    # 카탈로그가 커질수록 도구 호출이 늘어 이 경우가 잦아짐
    @staticmethod
    def _final_answer(messages: list[BaseMessage]) -> str:
        for message in reversed(messages):
            if not isinstance(message, AIMessage):
                continue
            content = message.content
            # 일부 모델은 content 를 블록 리스트로 돌려줌 — 텍스트 블록만 이어붙임
            if isinstance(content, list):
                content = "".join(
                    block.get("text", "")
                    for block in content
                    if isinstance(block, dict) and block.get("type") == "text"
                )
            text = str(content).strip()
            if text:
                return text
        return ""

    # (답변, 예약 링크용 매장 목록) 을 돌려줌
    async def ask(
        self,
        session_id: str,
        question: str,
        user_context: str | None = None,
        salon_id: int | None = None,
    ) -> tuple[str, list[dict[str, Any]]]:
        # 카탈로그에 없는 정보를 묻는 질문은 LLM 까지 보내지 않음
        # 없는 걸 답하려면 지어낼 수밖에 없어서, 모델이 바뀌어도 흔들리지 않게 코드에서 끊음
        # 대화기록에도 안 남김 — 차단된 질문이 이후 턴의 맥락을 오염시키지 않도록
        intent, blocked_reason = classify(question)
        if intent is Intent.OUT_OF_SCOPE:
            # 보고 있던 매장의 예약 화면까지 걸어줌
            links = salon_link(salon_id) if blocked_reason == "예약 방법" else []
            return out_of_scope_answer(blocked_reason or "요청하신 정보"), links

        # 이력을 봐야만 답할 수 있는데 이력이 없으면 근거가 없어 엉뚱한 답이 나감
        # 매장을 직접 댄 질문("라움헤어에 뭐 있어")은 이력이 필요 없으므로 걸리지 않음
        if not user_context and needs_history(question):
            return no_history_answer(), []

        # 첫 요청에서 에이전트 객체를 오직 하나만 만들 수 있게끔
        await self.start()

        # 상담은 한 번에 하나씩 — 앞 사람이 끝나기를 기다리되 무한정 매달리지는 않음
        try:
            await asyncio.wait_for(self._invoke_lock.acquire(), LOCK_WAIT_SECONDS)
        except (asyncio.TimeoutError, TimeoutError):
            return ("지금 다른 상담을 처리하고 있어 답변이 늦어지고 있습니다. "
                    "잠시 후 다시 여쭤봐 주세요."), []

        try:
            now = monotonic()   # 시간측정
            self._remove_expired_sessions(now)       # (수정) 오탈자: _remove_expired_session -> _remove_expired_sessions
            self._make_session_space(session_id)     # 세션 공간 생성

            history = self._messages_by_session.get(session_id, []) # 세션별 대화 기록 가져오기

            # 요청 메시지 생성
            request_messages = [
                *self._base_messages,   # 시스템 프롬프트
                *history,               # 세션별 대화기록
            ]
            # 세션 첫 턴에만 예약이력을 얹는다 — 이후 턴은 이미 대화기록에 남아있으므로 중복으로 안 넣는다
            if not history and user_context:
                request_messages.append(HumanMessage(
                    content=f"[사용자 예약 이력] 완료한 시술: {user_context}"
                ))
                hint = self._salon_catalog_hint(user_context)
                if hint:
                    request_messages.append(HumanMessage(content=hint))

            # 같은 탭에서 매장을 옮겨도 세션은 그대로라 매장이 바뀐 턴에만 넣음
            if salon_id is not None and self._salon_by_session.get(session_id) != salon_id:
                current_hint = self._current_salon_hint(salon_id)
                if current_hint:
                    request_messages.append(HumanMessage(content=current_hint))
                    self._salon_by_session[session_id] = salon_id

            # 매장을 고르려는 질문은 시술 인덱스로 답할 수 없어 salons 인덱스를 미리 붙임
            # 매 턴 넣으면 컨텍스트가 빨리 차므로 해당 인텐트일 때만
            if intent is Intent.SALON_FIND:
                salon_hint = self._salon_find_hint(question)
                if salon_hint:
                    request_messages.append(HumanMessage(content=salon_hint))
            request_messages.append(HumanMessage(content=question))

            # 현재 시작 인덱스 계산
            current_turn_start = len(self._base_messages) + len(history)

            # 에이전트 호출
            try:
                result = await asyncio.wait_for(
                    self._agent.ainvoke(
                        {"messages" : request_messages},
                        # 시술이 늘면서 도구 호출이 한 번 더 붙는 질문이 생겨 12 로는 중간에 끊겼음
                        config = {"recursion_limit" : 20}
                    ),
                    AGENT_TIMEOUT_SECONDS,
                )
            except (asyncio.TimeoutError, TimeoutError):
                # 여기서 멈췄다면 MCP 세션이 어긋났을 수 있음 — 다음 요청이 새로 연결하도록 버림
                # 버리지 않으면 이후 요청도 전부 같은 자리에서 90초씩 까먹음
                self._agent = None
                self._client = None
                self._exit_stack = None
                self._base_messages = []
                return ("답변이 너무 오래 걸려 중단했습니다. "
                        "질문을 조금 더 짧고 구체적으로 적어 주시면 다시 찾아보겠습니다."), []
            # 에이전트 결과 처리
            result_messages = list(result["messages"])

            # 세션별 대화 기록 갱신
            history = result_messages[len(self._base_messages):]
            self._messages_by_session[session_id] = self._trim_history(history)
            self._last_access_by_session[session_id] = now # 세션별 마지막 접근 시간 갱신
            answer = _strip_internal(_strip_markdown(self._final_answer(result_messages)))
            if not answer:
                # 답을 못 만들었거나 내부 이야기뿐이었던 것 — 빈 말풍선을 띄우지 않음
                return ("답변을 정리하지 못했습니다. "
                        "질문을 조금 더 구체적으로 적어 주시면 다시 찾아보겠습니다."), []

            # 답변이 매장을 언급 안 해도 매장 페이지에서 물었으면 그 매장으로 이어줌
            return answer, (reservation_links(answer) or salon_link(salon_id))
        finally:
            # 어떤 경로로 빠져나가든 락은 반드시 돌려놓음
            self._invoke_lock.release()

    # 만료된 세션 제거
    def _remove_expired_sessions(self, now: float)-> None:  # (수정) 오탈자: _remove_expried_sessions -> _remove_expired_sessions
        expired_session_ids = []  # (수정) 오탈자: exprired_session_ids -> expired_session_ids
        for session_id, last_access in self._last_access_by_session.items():  # (수정) 오탈자: last_accesss -> last_access
            # 1시간 머무른 세션
            if now - last_access >= 60 * 60 :
                expired_session_ids.append(session_id)

        for session_id in expired_session_ids:
            self._messages_by_session.pop(session_id, None)
            self._last_access_by_session.pop(session_id, None)
            self._salon_by_session.pop(session_id, None)

    # 세션 공간 생성
    def _make_session_space(self, session_id: str)->None:
        if session_id in self._messages_by_session:
            return 
        # 세션별 대화 기록 목록의 길이가 최대 세션 수 500보다 크면 가장 오래된 세션ID를 제거
        while len(self._messages_by_session) >= 500:
            oldest_session_id = min(self._last_access_by_session,
                                    key=self._last_access_by_session.get)
            self._messages_by_session.pop(oldest_session_id, None)
            self._last_access_by_session.pop(oldest_session_id, None)
            self._salon_by_session.pop(oldest_session_id, None)

    # 최근 사용자 대화만 남기고, Tool 요청 결과 묶음은 유지
    def _trim_history(self, messages: list[BaseMessage]) -> list[BaseMessage]:
        human_message_indexes = [
            index
            for index, message in enumerate(messages)
            if isinstance(message, HumanMessage) 
        ]
        # 10턴을 들고 있으면 뒤로 갈수록 답변이 느려지고 같은 말을 반복함
        # 시술 상담은 3~4턴이면 결론이 나므로 6턴이면 충분함
        if len(human_message_indexes) <= 6:
            return messages
        return messages[human_message_indexes[-6]:]

    # FastAPI 종료 시 MCP 세션과 하위 프로세스를 정리
    async def close(self) -> None:
        async with self._invoke_lock:
            if self._exit_stack is not None:
                await self._exit_stack.aclose()

            self._client = None
            self._exit_stack = None
            self._agent = None
            self._base_messages = []
            self._messages_by_session = {}
            self._last_access_by_session.clear()
            self._salon_by_session.clear()