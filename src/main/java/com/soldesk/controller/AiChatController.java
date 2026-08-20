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
import com.soldesk.service.SalonService;
import com.soldesk.service.UserService;
import com.soldesk.vo.ChatRequest;
import com.soldesk.vo.ChatResponse;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.UserVO;

/** ai-service(FastAPI) 로 시술 추천 채팅을 중계하는 컨트롤러
 *  개인 예약이력을 다루므로 인증이 필요 — SecurityConfig 의 기본 규칙을 그대로 따름 */
@Controller
@RequestMapping("/api")
public class AiChatController {

    /** 개인화 컨텍스트에 넣는 완료된 시술 이력 최대 개수 */
    private static final int MAX_HISTORY_ITEMS = 5;

    private final RestTemplate restTemplate;
    private final UserService userService;
    private final ReservationService reservationService;
    private final SalonService salonService;

    @Value("${fastapi.url}")
    private String fastApiUrl;

    @Autowired
    public AiChatController(RestTemplate restTemplate, UserService userService,
            ReservationService reservationService, SalonService salonService) {
        this.restTemplate = restTemplate;
        this.userService = userService;
        this.reservationService = reservationService;
        this.salonService = salonService;
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

        // 클라이언트가 보낸 값은 믿지 않고 로그인 사용자 본인의 예약이력으로 서버가 채움
        request.setUserContext(buildUserContext(authentication));
        request.setSalonId(resolveSalonId(request.getSalonId()));

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

    /** 영업 중인 매장일 때만 통과 — 없는 매장으로 범위를 좁히면 답이 통째로 빔 */
    private Integer resolveSalonId(Integer salonId) {
        if (salonId == null || salonId <= 0) {
            return null;
        }
        SalonVO salon = salonService.getSalon(salonId);
        if (salon == null || salon.getClosedAt() != null) {
            return null;
        }
        return salonId;
    }

    /** 완료한 시술 이력을 최근 순으로 요약 — 같은 시술명은 한 번만 남김 */
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

    /** 예약 이력 한 건을 "여성컷(컷, 라움헤어)" 형태로 조립
     *  매장명을 안 넘기면 LLM 이 어느 매장이었는지 추측함. salon_name 은 getRevList 가 조인해옴 */
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
