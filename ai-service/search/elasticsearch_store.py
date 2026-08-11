# Elasticsearch 실질적인 기능을 담당

import csv
import os
from pathlib import Path
from typing import Any

from elasticsearch import Elasticsearch, helpers
from sentence_transformers import SentenceTransformer

# ── 상수 ──────────────────────────────────────────
# CSV 경로: search/ 가 아니라 ai-service/ 루트에 CSV가 있으므로 parents[1]
CSV_PATH = Path(__file__).resolve().parents[1] / 'salon_services.csv'
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

# ── CSV 로드 (시술 카탈로그) ──────────────────────
def load_products() -> list[dict[str, Any]]:
    products = []
    with CSV_PATH.open(encoding='utf-8', newline='') as file:
        for row in csv.DictReader(file):
            price = int(row['가격'])
            cycle_weeks = int(row['유지주기'])
            duration_min = int(row['소요시간'])
            content = (
                f"시술명: {row['시술명']}\n"
                f"카테고리: {row['카테고리']}\n"
                f"가격: {price}원\n"
                f"소요시간: {duration_min}분\n"
                f"유지주기: {cycle_weeks}주\n"
                f"추천고민: {row['추천고민']}\n"
                f"설명: {row['설명']}"
            )
            products.append({
                "service_id": row['시술ID'],
                "name": row['시술명'],
                "category": row['카테고리'],
                "price": price,
                "duration_min": duration_min,
                "cycle_weeks": cycle_weeks,
                "concerns": row['추천고민'],
                "description": row['설명'],
                "content": content,
            })
    return products

# ── 인덱스 준비 ──────────────────────────────────
def prepare_index() -> dict[str, Any]:
    ensure_elasticsearch()

    exists = bool(client.indices.exists(index=INDEX_NAME))

    if exists:
        stored_count = client.count(index=INDEX_NAME)['count']
        if stored_count > 0:
            return {
                'created': False,
                'index': INDEX_NAME,
                'document_count': stored_count,
                'message': '기존 시술 인덱스를 사용합니다.'
            }

    products = load_products()

    model = get_embedding_model()
    vectors = model.encode(
        [product['content'] for product in products],
        normalize_embeddings=True,
    ).tolist()

    if not exists:
        client.indices.create(
            index=INDEX_NAME,
            mappings={
                'properties': {
                    'service_id':   {'type': 'keyword'},
                    'name':         {'type': 'text', 'analyzer': 'nori'},
                    'category':     {'type': 'keyword'},
                    'price':        {'type': 'integer'},
                    'duration_min': {'type': 'integer'},
                    'cycle_weeks':  {'type': 'integer'},
                    'concerns':     {'type': 'text', 'analyzer': 'nori'},
                    'description':  {'type': 'text', 'analyzer': 'nori'},
                    'content':      {'type': 'text', 'analyzer': 'nori'},
                    'embedding': {
                        'type': 'dense_vector',
                        'dims': len(vectors[0]),
                        'index': True,
                        'similarity': 'cosine'
                    },
                }
            },
        )

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
        'message': '시술 인덱스와 임베딩을 준비했습니다.'
    }

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