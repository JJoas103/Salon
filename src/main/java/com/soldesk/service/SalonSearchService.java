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
