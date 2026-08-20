#!/usr/bin/env bash
# ai-service(FastAPI) 기동 스크립트
#
# 그냥 python app.py 로 띄우면 두 가지가 자주 어긋남
#   1. 이전 프로세스가 8000 을 쥔 채 남아, 새로 띄운 줄 알고 옛날 코드로 답함
#   2. 어느 Ollama 를 보는지 눈에 안 보여서 로컬/원격을 헷갈림
# 그래서 포트를 먼저 비우고, 어디에 붙는지 찍고 나서 띄움
#
# 사용법
#   ./run.sh                                     로컬 Ollama(localhost:11434)
#   ./run.sh --fg                                로그를 화면에 띄운 채 실행(Ctrl+C 로 종료)
#   OLLAMA_BASE_URL=http://<주소>:11434 ./run.sh   다른 PC 의 Ollama 로 추론

set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$DIR/.venv/bin/python"
LOG="$DIR/ai-service.log"

# .env 는 파이썬(load_dotenv)만 읽는다. 여기서도 같은 값을 봐야 표시와 실제 추론 대상이 어긋나지 않음
# load_dotenv 는 이미 있는 환경변수를 덮어쓰지 않으므로, 여기서 기본값을 넣어 넘기면 .env 가 통째로 무시됨
# 우선순위는 llm.py 와 같게 — 셸 > 저장소 루트 .env > ai-service/.env
env_value() {
    local key="$1" file line value
    for file in "$DIR/../.env" "$DIR/.env"; do
        [ -f "$file" ] || continue
        line=$(grep -E "^[[:space:]]*${key}=" "$file" | tail -1)
        [ -n "$line" ] || continue
        value=${line#*=}
        value=${value%$'\r'}                       # 윈도우에서 저장한 .env 대비
        value=${value%\"}; value=${value#\"}
        value=${value%\'}; value=${value#\'}
        [ -n "$value" ] || continue
        printf '%s' "$value"
        return
    done
}

MODEL="${OLLAMA_MODEL:-$(env_value OLLAMA_MODEL)}"
MODEL="${MODEL:-qwen3.5:9b}"
BASE="${OLLAMA_BASE_URL:-$(env_value OLLAMA_BASE_URL)}"
BASE="${BASE:-http://localhost:11434}"
PROVIDER="${LLM_PROVIDER:-$(env_value LLM_PROVIDER)}"

[ -x "$PY" ] || { echo "가상환경이 없습니다: $PY"; echo "  python -m venv .venv && .venv/bin/pip install -r requirements.txt"; exit 1; }

# 1. 포트 정리 — 남은 프로세스가 있으면 새 코드가 반영되지 않음
if command -v fuser >/dev/null 2>&1 && fuser -s 8000/tcp 2>/dev/null; then
    echo "8000 을 쓰던 기존 프로세스를 종료합니다"
    fuser -k 8000/tcp >/dev/null 2>&1
    sleep 2
fi

# 2. 의존 서비스 확인 — 없으면 기동은 되지만 답변이 통째로 실패하므로 먼저 알려줌
check() {
    if curl -sf -m 3 "$1" >/dev/null 2>&1; then echo "  [ok]  $2"; else echo "  [--]  $2  ← 꺼져 있음"; return 1; fi
}
echo "의존 서비스"
if [ "${PROVIDER:-ollama}" = "openai" ]; then
    echo "  [--]  Ollama        건너뜀 (LLM_PROVIDER=openai)"
    OLLAMA_DOWN=1
else
    check "$BASE/api/tags"      "Ollama        $BASE"  || OLLAMA_DOWN=1
fi
check "http://localhost:9200"   "Elasticsearch localhost:9200" || ES_DOWN=1

# 3. 모델이 실제로 받아져 있는지 — 없으면 첫 질문에서 404 가 남
if [ -z "${OLLAMA_DOWN:-}" ] && ! curl -s -m 5 "$BASE/api/tags" | grep -q "\"$MODEL\""; then
    echo
    echo "$BASE 에 $MODEL 이 없습니다. 먼저 받아주세요:"
    echo "  ollama pull $MODEL"
    exit 1
fi

echo
if [ "${PROVIDER:-ollama}" = "openai" ]; then
    echo "공급자 OpenAI (OPENAI_MODEL / OPENAI_API_KEY 사용)"
else
    echo "모델 $MODEL  →  $BASE"
fi

# 4. 기동
cd "$DIR" || exit 1
if [ "${1:-}" = "--fg" ]; then
    OLLAMA_MODEL="$MODEL" OLLAMA_BASE_URL="$BASE" exec "$PY" "$DIR/app.py"
fi

OLLAMA_MODEL="$MODEL" OLLAMA_BASE_URL="$BASE" nohup "$PY" "$DIR/app.py" > "$LOG" 2>&1 &
PID=$!

# MCP 서버 연결까지 기다렸다가 확인 — 기동 직후엔 아직 포트가 안 열려 있음
for _ in $(seq 1 30); do
    sleep 1
    curl -sf -m 2 http://localhost:8000/health >/dev/null 2>&1 && break
done

if curl -sf -m 2 http://localhost:8000/health >/dev/null 2>&1; then
    echo "기동 완료 (pid $PID)   로그: $LOG"
else
    echo "기동 실패 — 로그를 확인하세요: $LOG"
    tail -20 "$LOG"
    exit 1
fi
