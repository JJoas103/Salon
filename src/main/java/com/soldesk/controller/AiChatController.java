package com.soldesk.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.soldesk.vo.ChatRequest;
import com.soldesk.vo.ChatResponse;

/** ai-service(FastAPI) 로 시술 추천 채팅을 중계하는 컨트롤러.
 *  개인 예약이력을 다루는 상담이라 인증이 필요 — SecurityConfig 의 기본 규칙
 *  (permitAll 목록에 없는 요청은 anyRequest().authenticated()) 을 그대로 따른다. */
@Controller
@RequestMapping("/api")
public class AiChatController {

    private final RestTemplate restTemplate;

    @Value("${fastapi.url}")
    private String fastApiUrl;

    @Autowired
    public AiChatController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @PostMapping(value = "/chat", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public ResponseEntity<ChatResponse> chat(@RequestBody ChatRequest request) {

        if (request.getQuestion() == null
                || request.getQuestion().trim().isEmpty()
                || request.getQuestion().length() > 500) {
            return ResponseEntity.badRequest().body(new ChatResponse(
                    "질문은 1자 이상 500자 이하로 입력해주세요",
                    "spring",
                    request.getQuestion(),
                    request.getSessionId()));
        }

        try {
            return restTemplate.postForEntity(fastApiUrl + "/api/chat", request, ChatResponse.class);
        } catch (HttpStatusCodeException e) {
            // FastAPI 가 4xx/5xx 로 응답
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(new ChatResponse(
                    "서버상 문제로 AI 상담 서비스를 사용할 수 없습니다",
                    "mcp-error",
                    request.getQuestion(),
                    request.getSessionId()));
        } catch (RestClientException e) {
            // FastAPI 자체에 연결이 안 됨(꺼져 있거나 타임아웃)
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(new ChatResponse(
                    "AI 상담 서버에 연결할 수 없습니다",
                    "spring",
                    request.getQuestion(),
                    request.getSessionId()));
        }
    }
}
