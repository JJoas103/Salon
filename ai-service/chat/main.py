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
from time import monotonic

from langchain_mcp_adapters.tools import load_mcp_tools
from langchain_mcp_adapters.resources import load_mcp_resources
from langchain_mcp_adapters.prompts import load_mcp_prompt

PYTHON_SERVICE_DIR = Path(__file__).parent/".." #python-service 디렉토리 경로
MCP_SERVER_MODULE = "mcp_chat.mcp_product_server"   #MCP 서버 모듈 경로
RESOURCE_URI = "catalog://salon/search-guide"      #리소스 경로

# system_prompt로 마크다운 금지를 지시해도 모델이 종종 무시해서, 응답 문자열에서 강제로 벗겨냄
_MD_BOLD_RE = re.compile(r"\*\*(.+?)\*\*")
_MD_HEADING_RE = re.compile(r"^#{1,6}\s*", re.MULTILINE)
_MD_BULLET_RE = re.compile(r"^[ \t]*[-*]\s+", re.MULTILINE)

def _strip_markdown(text: str) -> str:
    text = _MD_BOLD_RE.sub(r"\1", text)
    text = _MD_HEADING_RE.sub("", text)
    text = _MD_BULLET_RE.sub("", text)
    return text

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

    # 에이전트를 통해 LLM에 질문하고, 세션별 대화기록을 갱신
    async def ask(self, session_id: str, question: str, user_context: str | None = None)-> str:
        # 첫 요청에서 에이전트 객체를 오직 하나만 만들 수 있게끔
        await self.start()

        # 동시접근 방지(에이전트 객체가 생성 중 다른 에이전트 생성 요청이 들어오면 리턴)
        async with self._invoke_lock:
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
            request_messages.append(HumanMessage(content=question))

            # 현재 시작 인덱스 계산
            current_turn_start = len(self._base_messages) + len(history)

            # 에이전트 호출
            result = await self._agent.ainvoke(
                {"messages" : request_messages},
                config = {"recursion_limit" : 12}
            )
            # 에이전트 결과 처리
            result_messages = list(result["messages"])

            # 세션별 대화 기록 갱신
            history = result_messages[len(self._base_messages):]
            self._messages_by_session[session_id] = self._trim_history(history)
            self._last_access_by_session[session_id] = now # 세션별 마지막 접근 시간 갱신
            return _strip_markdown(str(result_messages[-1].content)) # LLM의 답변을 전달

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

    # 최근 사용자 대화만 남기고, Tool 요청 결과 묶음은 유지
    def _trim_history(self, messages: list[BaseMessage]) -> list[BaseMessage]:
        human_message_indexes = [
            index
            for index, message in enumerate(messages)
            if isinstance(message, HumanMessage) 
        ]
        if len(human_message_indexes) <= 10:
            return messages
        return messages[human_message_indexes[-10]:]

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