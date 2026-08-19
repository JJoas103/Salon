# Elasticsearch 실질적인 기능을 담당

import os
from typing import Any

import requests
from elasticsearch import Elasticsearch, helpers
from sentence_transformers import SentenceTransformer

# ── 상수 ──────────────────────────────────────────
# Spring 이 내려주는 시술 카탈로그(salon_id/salon_name 포함, 폐업 매장 제외).
# SalonService 가 시술 등록/수정/삭제 직후 /api/reindex 를 호출해 항상 최신으로 맞춘다.
SPRING_SERVICES_URL = os.getenv('SPRING_SERVICES_URL', 'http://localhost:8080/api/services')
INDEX_NAME = 'salon-services-agent'
EMBEDDING_MODEL_NAME = 'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2'

# 임베딩 모델
embedding_model: SentenceTransformer | None = None

# ES 클라이언트
client = Elasticsearch(
    os.getenv("ELASTICSEARCH_URL", "http://localhost:9200"),
    request_timeout=30
)

# 임베딩 모델 객체 생성
def get_embedding_model() -> SentenceTransformer:
    global embedding_model
    if embedding_model is None:
        embedding_model = SentenceTransformer(EMBEDDING_MODEL_NAME)
    return embedding_model

# ES 연결 상태 확인
def ensure_elasticsearch() -> None:
    if not client.ping():
        raise ConnectionError('엘라스틱서치 연결에 실패했습니다.')

# ── 카탈로그 로드 (Spring /api/services) ───────────
def load_products() -> list[dict[str, Any]]:
    response = requests.get(SPRING_SERVICES_URL, timeout=10)
    response.raise_for_status()

    products = []
    for row in response.json():
        price = int(row['price'])
        duration_min = row.get('durationMinutes') or 0
        concern = row.get('concern') or ''
        salon_name = row.get('salonName') or ''
        category = row.get('category') or ''
        description = row.get('description') or ''
        content = (
            f"매장: {salon_name}\n"
            f"시술명: {row['serviceName']}\n"
            f"카테고리: {category}\n"
            f"가격: {price}원\n"
            f"소요시간: {duration_min}분\n"
            f"추천고민: {concern}\n"
            f"설명: {description}"
        )
        products.append({
            "service_id": str(row['serviceId']),
            "salon_id": row['salonId'],
            "salon_name": salon_name,
            "name": row['serviceName'],
            "category": category,
            "price": price,
            "duration_min": duration_min,
            "concerns": concern,
            "description": description,
            "content": content,
        })
    return products

def _index_mappings(embedding_dims: int) -> dict[str, Any]:
    return {
        'properties': {
            'service_id':   {'type': 'keyword'},
            'salon_id':     {'type': 'keyword'},
            'salon_name':   {'type': 'text', 'analyzer': 'nori'},
            'name':         {'type': 'text', 'analyzer': 'nori'},
            'category':     {'type': 'keyword'},
            'price':        {'type': 'integer'},
            'duration_min': {'type': 'integer'},
            'concerns':     {'type': 'text', 'analyzer': 'nori'},
            'description':  {'type': 'text', 'analyzer': 'nori'},
            'content':      {'type': 'text', 'analyzer': 'nori'},
            'embedding': {
                'type': 'dense_vector',
                'dims': embedding_dims,
                'index': True,
                'similarity': 'cosine'
            },
        }
    }

# ── 인덱스 새로고침 (무조건 재생성) ─────────────────
# 시술이 등록/수정/삭제될 때마다 Spring 이 호출한다(/api/reindex). 카탈로그 규모가
# 작아 매번 통째로 다시 만드는 편이 "일부만 갱신"하다 누락되는 것보다 안전하다.
def rebuild_index() -> dict[str, Any]:
    ensure_elasticsearch()

    products = load_products()

    model = get_embedding_model()
    vectors = (
        model.encode(
            [product['content'] for product in products],
            normalize_embeddings=True,
        ).tolist()
        if products else []
    )

    embedding_dims = len(vectors[0]) if vectors else model.get_sentence_embedding_dimension()
    client.indices.delete(index=INDEX_NAME, ignore_unavailable=True)
    client.indices.create(
        index=INDEX_NAME,
        mappings=_index_mappings(embedding_dims),
    )

    if products:
        helpers.bulk(
            client,
            (
                {
                    '_index': INDEX_NAME,
                    '_id': product['service_id'],
                    '_source': {**product, 'embedding': vector},
                } for product, vector in zip(products, vectors)
            ),
        )
    client.indices.refresh(index=INDEX_NAME)

    return {
        'created': True,
        'index': INDEX_NAME,
        'document_count': len(products),
        'message': '시술 인덱스를 새로 고쳤습니다.'
    }

# ── 인덱스 준비 (없을 때만 새로고침) ────────────────
# MCP 툴(prepare_service_index)이 상담 중 호출하는 진입점 — 이미 색인돼 있으면 그대로 쓴다.
# 실제 최신화는 rebuild_index 가 시술 CRUD 이벤트로 담당하므로, 여기서는 "완전히 비어있는
# 최초 상태"만 채워주면 된다.
def prepare_index() -> dict[str, Any]:
    ensure_elasticsearch()

    if client.indices.exists(index=INDEX_NAME):
        stored_count = client.count(index=INDEX_NAME)['count']
        if stored_count > 0:
            return {
                'created': False,
                'index': INDEX_NAME,
                'document_count': stored_count,
                'message': '기존 시술 인덱스를 사용합니다.'
            }

    return rebuild_index()

# ── 하이브리드 검색 ──────────────────────────────
def hybrid_search(
        query: str,
        max_price: int | None = None,
        category: str | None = None,
        count: int = 5,
) -> list[dict[str, Any]]:

    ensure_elasticsearch()

    if not client.indices.exists(index=INDEX_NAME):
        raise RuntimeError('prepare_service_index Tool을 먼저 호출하세요.')

    query = query.strip()
    if not query:
        raise ValueError('시술 종류나 고민을 query에 입력하세요.')

    if max_price is not None:
        if max_price <= 0 or max_price > 100000000:
            raise ValueError('max_price는 1원 이상 1억 원 이하이어야 합니다.')

    if count < 1:
        count = 1
    elif count > 10:
        count = 10

    # 필터 조건 구성(가격/카테고리)
    filters: list[dict[str, Any]] = []

    if max_price is not None:
        filters.append({'range': {'price': {'lte': max_price}}})

    if category is not None:
        filters.append({'term': {'category': category}})

    # 키워드 검색 — concerns(고민) 필드에 가중치를 줘서
    # "부스스해요" 같은 자연어가 잘 매칭되도록
    keyword_query: dict[str, Any] = {
        'multi_match': {
            'query': query,
            'fields': ['name^3', 'concerns^2', 'content'],
            'boost': 0.7
        }
    }
    if filters:
        keyword_query = {
            'bool': {
                'must': [keyword_query],
                'filter': filters,
            }
        }

    # 벡터 기반 검색
    model = get_embedding_model()
    knn: dict[str, Any] = {
        'field': 'embedding',
        'query_vector': model.encode(
            query,
            normalize_embeddings=True,
        ).tolist(),
        'k': count,
        'num_candidates': max(50, count * 5),
        'boost': 0.3,
    }
    if filters:
        knn['filter'] = {'bool': {'filter': filters}}

    # 검색 요청
    response = client.search(
        index=INDEX_NAME,
        size=count,
        query=keyword_query,
        knn=knn
    )

    # 결과 반환
    results = []
    for hit in response['hits']['hits']:
        item = dict(hit['_source'])
        item.pop('embedding', None)
        item['search_score'] = hit.get('_score')
        results.append(item)

    return results


# ── 카탈로그 목록 조회 (검색이 아니라 정렬/전량) ─────────────────
# hybrid_search 는 관련도 top-k 라서 "제일 저렴한", "10만원 넘는 것 전부" 같은
# 정렬·집계형 질문에 구조적으로 못 맞춤. 그런 질문은 이 함수로 받음
def list_services(
    category: str | None = None,
    salon: str | None = None,
    sort_by: str = 'price',
    order: str = 'asc',
    count: int = 20,
) -> list[dict[str, Any]]:
    ensure_elasticsearch()

    conditions: list[dict[str, Any]] = []
    if category:
        conditions.append({'term': {'category': category}})

    query: dict[str, Any] = (
        {'bool': {'filter': conditions}} if conditions else {'match_all': {}}
    )

    sort_field = sort_by if sort_by in ('price', 'duration_min') else 'price'
    sort_order = 'desc' if order == 'desc' else 'asc'

    # 매장 필터는 ES 에 안 맡김 — salon_name 이 nori 분석 text 라
    # '라움헤어' 로 match 하면 '헤어' 토큰이 겹치는 위드헤어/블랑쉬헤어까지 딸려옴
    # keyword 서브필드가 매핑에 없으므로 후보를 넉넉히 받아 여기서 정확히 거름
    fetch_size = 100 if salon else max(1, min(count, 100))
    response = client.search(
        index=INDEX_NAME,
        size=fetch_size,
        query=query,
        sort=[{sort_field: {'order': sort_order}}],
        source_excludes=['embedding'],
    )
    items = [hit['_source'] for hit in response['hits']['hits']]

    if salon:
        key = salon.replace(' ', '')
        items = [
            i for i in items
            if key in (i.get('salon_name') or '').replace(' ', '')
        ]
        items = items[:max(1, count)]

    return items
