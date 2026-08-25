# Elasticsearch 실질적인 기능을 담당

import hashlib
import json
import os
from typing import Any

import requests
from elasticsearch import Elasticsearch, helpers
from sentence_transformers import SentenceTransformer

# ── 상수 ──────────────────────────────────────────
# Spring 이 내려주는 시술 카탈로그 (폐업 매장 제외)
# SalonService 가 시술 CRUD 직후 /api/reindex 를 호출함
SPRING_SERVICES_URL = os.getenv('SPRING_SERVICES_URL', 'http://localhost:8080/api/services')
INDEX_NAME = 'salon-services-agent'
EMBEDDING_MODEL_NAME = 'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2'

embedding_model: SentenceTransformer | None = None

client = Elasticsearch(
    os.getenv("ELASTICSEARCH_URL", "http://localhost:9200"),
    request_timeout=30
)

def get_embedding_model() -> SentenceTransformer:
    global embedding_model
    if embedding_model is None:
        embedding_model = SentenceTransformer(EMBEDDING_MODEL_NAME)
    return embedding_model

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

def _catalog_hash(products: list[dict[str, Any]]) -> str:
    # service_id가 TRUNCATE 뒤 재사용돼도 내용 변화까지 감지해야 함
    canonical = json.dumps(products, ensure_ascii=False, sort_keys=True, separators=(',', ':'))
    return hashlib.sha256(canonical.encode('utf-8')).hexdigest()

def _index_mappings(embedding_dims: int, catalog_hash: str) -> dict[str, Any]:
    return {
        '_meta': {'catalog_hash': catalog_hash},
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
# 카탈로그가 작아 통째로 다시 만듦 — 일부만 갱신하다 누락되는 것보다 안전함
def rebuild_index(products: list[dict[str, Any]] | None = None) -> dict[str, Any]:
    ensure_elasticsearch()

    if products is None:
        products = load_products()
    catalog_hash = _catalog_hash(products)

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
        mappings=_index_mappings(embedding_dims, catalog_hash),
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

# ── 인덱스 준비 및 DB 정합성 확인 ─────────────────
# SQL 시드·복원은 Spring CRUD를 거치지 않으므로 첫 상담에서 원본 카탈로그 hash를 대조함
def prepare_index() -> dict[str, Any]:
    ensure_elasticsearch()

    products = load_products()
    current_hash = _catalog_hash(products)

    if client.indices.exists(index=INDEX_NAME):
        stored_count = client.count(index=INDEX_NAME)['count']
        mappings = client.indices.get_mapping(index=INDEX_NAME)
        stored_hash = (
            mappings.get(INDEX_NAME, {})
            .get('mappings', {})
            .get('_meta', {})
            .get('catalog_hash')
        )
        if stored_count == len(products) and stored_hash == current_hash:
            return {
                'created': False,
                'index': INDEX_NAME,
                'document_count': stored_count,
                'message': '기존 시술 인덱스를 사용합니다.'
            }

    return rebuild_index(products)

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

    filters: list[dict[str, Any]] = []

    if max_price is not None:
        filters.append({'range': {'price': {'lte': max_price}}})

    if category is not None:
        filters.append({'term': {'category': category}})

    # concerns 에 가중치를 줘야 "부스스해요" 같은 자연어가 매칭됨
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

    response = client.search(
        index=INDEX_NAME,
        size=count,
        query=keyword_query,
        knn=knn
    )

    results = []
    for hit in response['hits']['hits']:
        item = dict(hit['_source'])
        item.pop('embedding', None)
        item['search_score'] = hit.get('_score')
        results.append(item)

    return results


# ── 카탈로그 목록 조회 (검색이 아니라 정렬/전량) ─────────────────
# hybrid_search 는 관련도 top-k 라서 "제일 저렴한" 같은 정렬형 질문에 구조적으로 못 맞춤
def list_services(
    category: str | None = None,
    salon: str | None = None,
    salon_id: str | int | None = None,
    sort_by: str = 'price',
    order: str = 'asc',
    count: int = 20,
) -> list[dict[str, Any]]:
    ensure_elasticsearch()

    conditions: list[dict[str, Any]] = []
    if category:
        conditions.append({'term': {'category': category}})

    # 매장 상세 페이지에서 넘어온 매장은 id 로 거름 — 아래 salon 인자와 달리 ES 가 바로 필터링함
    if salon_id is not None and str(salon_id).strip():
        conditions.append({'term': {'salon_id': str(salon_id).strip()}})

    query: dict[str, Any] = (
        {'bool': {'filter': conditions}} if conditions else {'match_all': {}}
    )

    sort_field = sort_by if sort_by in ('price', 'duration_min') else 'price'
    sort_order = 'desc' if order == 'desc' else 'asc'

    # salon_name 은 nori 분석 text 라 '라움헤어' 로 match 하면 '헤어' 가 겹치는 매장까지 딸려옴
    # keyword 서브필드가 없으므로 후보를 넉넉히 받아 파이썬에서 거름
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
