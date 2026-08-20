# AI 챗봇 세팅 (Windows)

`feature/ai-service` 브랜치. JDK / Maven / MySQL / Tomcat 9 는 `docs/초기세팅가이드.md`

받을 용량 약 10GB — ES 1.3GB, 모델 6GB, torch 3GB, 임베딩 470MB

---

## 1. Elasticsearch

Docker Desktop 필요. 한국어 분석기(nori) 때문에 직접 빌드

```
docker build -t salu-es ai-service/docker/elasticsearch
docker run -d --name salu-es -p 9200:9200 -e discovery.type=single-node -e xpack.security.enabled=false -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" -v es_data:/usr/share/elasticsearch/data salu-es
```

`docker run` 은 한 줄. 이후로는 `docker start salu-es` / `docker stop salu-es`

---

## 2. Ollama

<https://ollama.com/download/windows> 설치 → 트레이 상주, 11434 열림

```
ollama pull qwen3.5:9b
```

도커로 올리면 WSL2 를 거쳐 GPU 를 못 잡음

### GPT 로 대신할 때

```
pip install langchain-openai
```

`ai-service\.env.example` → `.env` 복사 후 두 줄의 `#` 제거

```
LLM_PROVIDER=openai
OPENAI_API_KEY=sk-...
```

Ollama 6GB 만 빠지고 ES·임베딩 모델은 그대로 필요

---

## 3. 파이썬

3.12 이상, cmd 에서 (PowerShell 은 실행 정책에 막힘)

```
cd ai-service
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')"
```

마지막 줄은 임베딩 모델 미리 받기. `activate` 는 창 열 때마다

---

## 4. DB

```
mysql -u root -p < sql\schema.sql
mysql -u root -p salu < sql\migration_owner_request_type.sql
mysql -u root -p salu < dummydata_original.sql
mysql -u root -p salu < sql\seed_operating_hours.sql
mysql -u root -p salu < sql\salon_coordinates.sql
mysql -u root -p salu < sql\seed_ai_demo.sql
```

이미 `salu` DB 가 있으면 첫 줄만 `sql\migration_catchup.sql` 로 교체 (멱등)

`dummydata_original.sql` 은 `sql\` 이 아니라 저장소 최상위
`migration_owner_request_type.sql` 없으면 점주 요청이 `Unknown column` 으로 죽음

---

## 5. 실행

ES → Ollama → MySQL → 톰캣(`deploy.bat`) 순으로 띄운 뒤 마지막에

```
docker start salu-es
cd ai-service
.venv\Scripts\activate
python app.py
```

`Application startup complete` 뜨면 완료. 창 닫으면 챗봇도 멈춤
로그인 후 우하단 지팡이 버튼 (비로그인은 안 보임)

리눅스·맥은 `./ai-service/run.sh` 하나로 끝

---

## 확인

| 주소 | 정상 |
|---|---|
| <http://localhost:9200> | ES 버전 JSON |
| <http://localhost:11434/api/tags> | 목록에 `qwen3.5:9b` |
| <http://localhost:8000/health> | `{"status":"ok"}` |
| <http://localhost:8080/api/services> | 시술 JSON — 비면 4번 누락 |

---

## 안 될 때

| 증상 | 원인 |
|---|---|
| 첫 질문만 오래 걸림 | 정상. 임베딩 적재 + 색인이 첫 요청에 붙음 |
| 상담 서버에 연결할 수 없습니다 | `python app.py` 창이 죽음 |
| 30초 넘게 응답 없음 | `ollama ps` 가 `100% CPU` 면 GPU 미인식 |
| 챗봇 버튼이 안 보임 | 비로그인 상태 |
| 시술 추가했는데 모름 | `curl -X POST http://localhost:8000/api/reindex` |
| 8000 포트 사용 중 | `netstat -ano \| findstr :8000` → `taskkill /PID <번호> /F` |

---

## 모델 교체

`llm.py` 수정 불필요

```
set OLLAMA_MODEL=qwen3:8b
python app.py
```

1~2b 급은 MCP 도구 호출을 못 해서 답을 지어냄
