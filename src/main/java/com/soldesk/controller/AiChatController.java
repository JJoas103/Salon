package com.soldesk.controller;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.soldesk.service.ReservationService;
import com.soldesk.service.UserService;
import com.soldesk.vo.ChatRequest;
import com.soldesk.vo.ChatResponse;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.UserVO;

/** ai-service(FastAPI) 로 시술 추천 채팅을 중계하는 컨트롤러.
 *  개인 예약이력을 다루는 상담이라 인증이 필요 — SecurityConfig 의 기본 규칙
 *  (permitAll 목록에 없는 요청은 anyRequest().authenticated()) 을 그대로 따른다. */
@Controller
@RequestMapping("/api")
public class AiChatController {

    /** 개인화 컨텍스트에 넣는 완료된 시술 이력 최대 개수. 프롬프트가 너무 길어지지 않게 최근 것만 */
    private static final int MAX_HISTORY_ITEMS = 5;

    private final RestTemplate restTemplate;
    private final UserService userService;
    private final ReservationService reservationService;

    @Value("${fastapi.url}")
    private String fastApiUrl;

    @Autowired
    public AiChatController(RestTemplate restTemplate, UserService userService,
            ReservationService reservationService) {
        this.restTemplate = restTemplate;
        this.userService = userService;
        this.reservationService = reservationService;
    }

    @PostMapping(value = "/chat", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public ResponseEntity<ChatResponse> chat(@RequestBody ChatRequest request, Authentication authentication) {

        if (request.getQuestion() == null
                || request.getQuestion().trim().isEmpty()
                || request.getQuestion().length() > 500) {
            return ResponseEntity.badRequest().body(new ChatResponse(
                    "질문은 1자 이상 500자 이하로 입력해주세요",
                    "spring",
                    request.getQuestion(),
                    request.getSessionId()));
        }

        // 클라이언트가 보낸 값은 신뢰하지 않고, 로그인 사용자 본인의 예약이력으로 서버가 직접 채운다
        request.setUserContext(buildUserContext(authentication));

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

    /** 로그인 사용자가 완료한 시술 이력을 "시술명(카테고리)" 형태로 최근 순 요약
     *  같은 시술명이 반복되면 한 번만 남기고, ai-service 쪽 프롬프트에 그대로 얹을 문자열을 만든다 */
    private String buildUserContext(Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
        List<ReservationVO> history = reservationService.getRevList(user.getUserId());

        Set<String> summarized = new LinkedHashSet<>();
        for (ReservationVO r : history) {
            if (!"completed".equals(r.getStatus())) {
                continue;
            }
            summarized.add(formatHistoryItem(r));
            if (summarized.size() >= MAX_HISTORY_ITEMS) {
                break;
            }
        }

        if (summarized.isEmpty()) {
            return null;
        }
        return summarized.stream().collect(Collectors.joining(", "));
    }

    /** 예약 이력 한 건을 "여성컷(컷, 라움헤어)" 형태로 조립함
     *  매장명까지 넘기지 않으면 LLM 이 어느 매장이었는지 추측해서 답함
     *  salon_name 은 getRevList 가 이미 조인해오므로 추가 조회는 없음 */
    private String formatHistoryItem(ReservationVO r) {
        List<String> detail = new ArrayList<>();
        if (r.getCategory() != null && !r.getCategory().isBlank()) {
            detail.add(r.getCategory());
        }
        if (r.getSalonName() != null && !r.getSalonName().isBlank()) {
            detail.add(r.getSalonName());
        }
        return detail.isEmpty()
                ? r.getServiceName()
                : r.getServiceName() + "(" + String.join(", ", detail) + ")";
    }
}
