package com.soldesk.es;

import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.rest_client.RestClientTransport;

@Configuration
public class ElasticSearchConfig {
    private static final Logger log = LoggerFactory.getLogger(ElasticSearchConfig.class);

    @Value("${elasticsearch.host}")
    private String host;

    @Value("${elasticsearch.port}")
    private int port;

    @Bean(destroyMethod = "close")
    public RestClient restClient(){
        log.info("ElasticSearch 클라이언트 생성: {}:{}", host, port);
        return RestClient.builder(new HttpHost(host, port, "http")).build();
    }//엘라스틱 서치 접속 

    @Bean
    public ElasticsearchClient elasticsearchClient(RestClient restClient){
        ElasticsearchTransport transport 
            = new RestClientTransport(restClient, new JacksonJsonpMapper());
        return new ElasticsearchClient(transport); 
    }
    //json 데이이터를 class 객체로 변환
    //엘라스틱서치에 접속할 클라이언트
}
