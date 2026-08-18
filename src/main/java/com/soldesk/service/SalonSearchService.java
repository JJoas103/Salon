package com.soldesk.service;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.soldesk.mapper.SalonMapper;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.SalonsDocument;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.elasticsearch.indices.CreateIndexRequest;
import co.elastic.clients.elasticsearch.indices.ExistsRequest;

@Service
public class SalonSearchService implements InitializingBean{
    
    private static final Logger log = 
        LoggerFactory.getLogger(SalonSearchService.class);

    @Autowired
    private ElasticsearchClient elasticsearchClient;

    @Autowired
    private SalonMapper salonMapper;

    @Value("${elasticsearch.index}")
    private String indexName;
    
    //인덱스 없으면 생성
    public void createIndexIfNotExists() throws Exception{
        boolean exists = elasticsearchClient.indices()
                                .exists(ExistsRequest.of(req->req.index(indexName)))
                                .value();
        if(!exists){ //인덱스 없으면 생성
                elasticsearchClient.indices()
                    .create(CreateIndexRequest.of(create->
                        create.index(indexName)
                            .mappings(mappings -> mappings
                                .properties("salonId", p->p.integer(i->i))
                                .properties("ownerId", p->p.integer(i->i))
                                .properties("salonName", p->p.text(t->t.analyzer("nori")))
                                .properties("address", p->p.text(t->t.analyzer("nori")))
                                .properties("phoneNumber", p->p.keyword(k->k))
                                .properties("description", p->p.text(t->t.analyzer("nori")))
                                .properties("averageRating", p->p.double_(d->d))
                                .properties("minimumPrice", p->p.integer(i->i))
                                .properties("latitude", p->p.double_(d->d))
                                .properties("longitude", p->p.double_(d->d))
                            )));
            log.info("ElasticSearch 인덱스 생성 완료: {}", indexName);
        }   
            
    }

    public void reindexAll() throws Exception{
        List<SalonVO> salons = salonMapper.findAllWithMinimumPrice();
            for(SalonVO salon : salons){
                elasticsearchClient.index(index -> index
                    .index(indexName)
                    .id(String.valueOf(salon.getSalonId()))
                    .document(SalonsDocument.from(salon)));
            }
            log.info("ElasticSearch reindex 완료: {}건", salons.size());
    }

    /**
     * 매장 한 건만 색인을 다시 쓴다. 매장정보가 바뀔 때마다 불러야 검색 결과가 DB 를 따라간다
     * (reindexAll 은 기동 시 한 번뿐이라, 이게 없으면 재기동 전까지 옛 주소·좌표가 검색에 남는다).
     *
     * 넘겨받은 VO 를 쓰지 않고 salonId 로 다시 읽는 이유: 점주 수정 폼은 이름/주소/연락처/소개만
     * 담은 VO 를 만들어 오므로, 그대로 색인하면 평점·최저가·이미지가 문서에서 사라진다.
     *
     * 색인 실패가 매장 저장 자체를 되돌리면 안 되므로 예외는 여기서 삼키고 로그만 남긴다
     * (afterPropertiesSet 이 ES 장애를 "검색 기능 제한" 으로 넘기는 것과 같은 취급).
     */
    public void indexSalon(int salonId) {
        try {
            SalonVO salon = salonMapper.findById(salonId);
            if (salon == null) {
                return;
            }
            elasticsearchClient.index(index -> index
                .index(indexName)
                .id(String.valueOf(salonId))
                .document(SalonsDocument.from(salon)));
            log.debug("ElasticSearch 색인 갱신: salonId={}", salonId);
        } catch (Exception e) {
            log.warn("ElasticSearch 색인 갱신 실패 - 검색 결과가 최신이 아닐 수 있습니다: salonId={}", salonId, e);
        }
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        try {
            createIndexIfNotExists();
            reindexAll();
        } catch (Exception e) {
            log.warn("ElasticSearch 초기화 실패 - 검색 기능 제한", e);
        }
    }

    // 검색하기
    public List<SalonVO> search(String keyword, int page, int size) throws Exception{
        int from = (page - 1) * size;
        
        //키워드와 일치하는 미용실 가져오기
        SearchResponse<SalonsDocument> response
            = elasticsearchClient.search(search->search
                .index(indexName)
                .from(from)
                .size(size)
                .query(query->query.bool(bool->{
                    bool.must(must->must.multiMatch(multi->multi
                        .fields("salonName^3", "address^2", "description")
                        .query(keyword)));
                    return bool;
                })), SalonsDocument.class);
        List<SalonVO> salons = new ArrayList<>();

        for(Hit<SalonsDocument> hit : response.hits().hits()){
            SalonsDocument document = hit.source();
            if(document != null){
                salons.add(document.toSalonVO());
            }
        }
        log.debug("ElasticSearch 검색: keyword={}, result={}", keyword, salons.size());
        return salons;
    }

}
