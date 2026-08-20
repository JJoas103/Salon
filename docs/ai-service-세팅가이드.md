# AI 상담 챗봇(ai-service) 세팅 — Windows

`feature/ai-service` 브랜치에서 챗봇까지 돌리기 위한 준비.
JDK / Maven / MySQL / Tomcat 9 는 `docs/초기세팅가이드.md` 참고. **사이트가 이미 톰캣에서 뜨는 상태**를 전제로 한다.

받아야 할 것은 넷, 합쳐서 약 10GB 다. 시연 당일에 받지 말 것.

| | 용량 |
|---|---|
| Elasticsearch 8.15 + nori | 1.3GB |
| Ollama + `qwen3.5:9b` | 6GB (GPT 로 쓰면 불필요) |
| 파이썬 패키지 (torch 포함) | 3GB |
| 임베딩 모델 | 470MB |

---

## 1. Elasticsearch

Docker Desktop 설치 후, 저장소 최상위에서.

```
docker build -t salu-es ai-service/docker/elasticsearch
```

```
docker run -d --name salu-es -p 9200:9200 -e discovery.type=single-node -e xpack.security.enabled=false -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" -v es_data:/usr/share/elasticsearch/data salu-es
```

두 번째 명령은 **줄바꿈 없이 한 줄로**. 다음부터는 아래만 쓴다.

```
docker start salu-es
docker stop  salu-es
```

<http://localhost:9200> 에서 JSON 이 나오면 성공.

---

## 2. Ollama

<https://ollama.com/download/windows> 에서 `OllamaSetup.exe` 설치. 설치하면 트레이에 뜨고 11434 가 열린다.

```
ollama pull qwen3.5:9b
ollama list
```

**도커로 올리지 말 것.** Docker Desktop 은 WSL2 를 거쳐서 GPU 를 못 잡는다. CPU 로 9b 를 돌리면 답변 하나에 몇 분 걸린다.

### GPT 로 대신하려면

Ollama 설치와 모델 6GB 를 건너뛸 수 있다. **코드는 안 고친다.**

```
.venv\Scripts\activate
pip install langchain-openai
```

`ai-service\.env.example` 을 `.env` 로 복사한 뒤, 아래 두 줄의 `#` 를 지우고 키를 채운다.

```
LLM_PROVIDER=openai
OPENAI_API_KEY=sk-...
```

- 키를 `llm.py` 에 적지 않는다. `llm.py:62` 가 `os.getenv("OPENAI_API_KEY")` 로 읽는다
- `DEFAULT_MODEL = "qwen3.5:9b"` 은 그대로 둔다. `_ollama_llm()` 안에서만 쓰는 값이라
  `LLM_PROVIDER=openai` 면 그 함수가 아예 호출되지 않는다 (`llm.py:33` 에서 분기)
- 모델 기본값은 `gpt-4o-mini`. 바꾸려면 `.env` 에 `OPENAI_MODEL=...` 을 추가한다
- **반드시 `ai-service\.env` 에 둘 것.** 저장소 루트 `.env` 는 `.gitignore` 에 없어서 키가 커밋된다
- `pip install langchain-openai` 를 빼먹으면 기동할 때 안내 메시지와 함께 죽는다

키가 없거나 틀리면 `python app.py` 가 **기동 단계에서 바로** 죽는다. 첫 질문까지 가지 않는다.

Elasticsearch 와 임베딩 모델은 GPT 를 써도 그대로 필요하다. 빠지는 건 Ollama 6GB 뿐이다.

---

## 3. 파이썬

파이썬 3.12 이상. **cmd 에서** 실행한다(PowerShell 은 실행 정책에 막힐 수 있다).

```
cd ai-service
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')"
```

마지막 줄은 임베딩 모델(470MB)을 미리 받아두는 것이다. 안 하면 첫 질문 때 받으려다 인터넷이 없으면 실패한다.

`activate` 는 이 창에서 python/pip 를 `.venv` 것으로 바꾸는 명령이다. **창을 새로 열 때마다 다시 해야 한다.**

---

## 4. DB

저장소 최상위에서.

```
mysql -u root -p < sql\schema.sql
mysql -u root -p salu < sql\migration_owner_request_type.sql
mysql -u root -p salu < dummydata_original.sql
mysql -u root -p salu < sql\seed_operating_hours.sql
mysql -u root -p salu < sql\salon_coordinates.sql
mysql -u root -p salu < sql\seed_ai_demo.sql
```

**이미 `salu` DB 가 있으면 첫 줄만 바꾼다.** 나머지는 그대로.

```
mysql -u root -p salu < sql\migration_catchup.sql
```

- `dummydata_original.sql` 만 `sql\` 이 아니라 저장소 최상위에 있다
- `migration_catchup.sql` 은 멱등이라 자기 DB 가 어느 시점인지 몰라도 그냥 돌리면 된다
- `migration_owner_request_type.sql` 을 빼먹으면 점주 승격·매장 추가 요청이 `Unknown column` 으로 죽는다

---

## 5. 실행

**ai-service 를 마지막에 띄운다.**

```
docker start salu-es
```

Ollama 트레이 아이콘 확인 → MySQL 실행 → `deploy.bat` 으로 톰캣 배포. 그다음.

```
cd ai-service
.venv\Scripts\activate
python app.py
```

`Application startup complete` 가 뜨면 완료. **이 창을 닫으면 챗봇이 멈춘다.**

로그인한 뒤 우측 하단 지팡이 버튼을 누르면 상담창이 열린다. 비로그인은 버튼이 안 보인다.

> 리눅스·맥은 `./ai-service/run.sh` 하나로 끝난다. bash 전용이라 Windows 에서는 못 쓴다.

---

## 확인

| 주소 | 정상 |
|---|---|
| <http://localhost:9200> | ES 버전 JSON |
| <http://localhost:11434/api/tags> | 목록에 `qwen3.5:9b` |
| <http://localhost:8000/health> | `{"status":"ok"}` |
| <http://localhost:8080/api/services> | 시술 JSON (비면 4장 안 한 것) |

---

## 막힐 때

**첫 질문만 오래 걸린다** — 정상. 임베딩 모델 적재와 카탈로그 색인이 첫 요청에 붙는다.

**"상담 서버에 연결할 수 없습니다"** — `python app.py` 창이 죽었다.

**답이 30초 넘게 안 온다** — `ollama ps` 가 `100% CPU` 면 GPU 를 못 잡은 것이다.

**시술을 추가했는데 챗봇이 모른다** — ai-service 가 꺼져 있던 사이에 바꾸면 재색인을 놓친다.

```
curl -X POST http://localhost:8000/api/reindex
```

**8000 포트 사용 중**

```
netstat -ano | findstr :8000
taskkill /PID <나온번호> /F
```

**챗봇 버튼이 안 보인다** — 로그인하지 않았다. 개인 예약이력을 쓰는 상담이라 로그인 사용자에게만 뜬다.

---

## 모델 바꾸기

기본값은 `ai-service/llm.py` 의 `DEFAULT_MODEL`, `ai-service/run.sh` 의 `MODEL` 두 곳. 코드를 안 고치려면 환경변수로.

```
set OLLAMA_MODEL=qwen3:8b
python app.py
```

더 작은 모델로는 내리지 말 것. MCP 도구 호출(`prepare_service_index`, `search_services`, `list_catalog`)로 굴러가는데 1~2b 급은 도구를 못 부르고 지어낸다. 8b 도 없는 시술을 지어내서 9b 로 올린 것이다.
