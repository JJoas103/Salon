package com.soldesk.controller;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import com.soldesk.vo.ImageResponse;

/** 참고 이미지와 문구를 ai-service(FastAPI) 로 중계해 편집된 이미지를 받아오는 컨트롤러
 *  SecurityConfig 의 anyRequest().authenticated() 를 그대로 탐 — 호출당 비용이 나가는 기능이라 열지 않음 */
@Controller
@RequestMapping("/api")
public class AiImageController {

    /** web.xml 의 max-file-size(5MB)가 실제 상한이라 그 값에 맞춤
     *  강의자료 원본은 10MB 였지만 여기를 올리면 리뷰·공지 업로드까지 같이 헐거워짐 */
    private static final long MAX_IMAGE_BYTES = 5L * 1024 * 1024;

    /** ai-service 가 매직바이트로 다시 검사하므로 여기서도 같은 두 종류만 받음 */
    private static final Set<String> ALLOWED_IMAGE_TYPES = Set.of(
            MediaType.IMAGE_PNG_VALUE,
            MediaType.IMAGE_JPEG_VALUE);

    private final RestTemplate imageRestTemplate;

    @Value("${fastapi.url}")
    private String fastApiUrl;

    @Autowired
    public AiImageController(@Qualifier("imageRestTemplate") RestTemplate imageRestTemplate) {
        this.imageRestTemplate = imageRestTemplate;
    }

    @PostMapping(value = "/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseBody
    public ResponseEntity<?> createImage(
            @RequestParam String prompt,
            @RequestParam("image") MultipartFile image) {

        if (!StringUtils.hasText(prompt) || prompt.length() > 1000) {
            return badRequest("이미지 생성 문구는 1자 이상 1000자 이하로 입력해주세요");
        }
        if (image.isEmpty()) {
            return badRequest("이미지를 첨부해주세요");
        }
        if (image.getSize() > MAX_IMAGE_BYTES) {
            return badRequest("첨부 이미지는 5MB 이하여야 합니다");
        }

        String contentType = image.getContentType();
        if (!StringUtils.hasText(contentType)
                || !ALLOWED_IMAGE_TYPES.contains(contentType.toLowerCase())) {
            return badRequest("PNG, JPG, JPEG 형식의 이미지만 사용할 수 있습니다");
        }

        try {
            final String fileName = StringUtils.cleanPath(
                    image.getOriginalFilename() == null
                            ? "reference-image"
                            : image.getOriginalFilename());

            // RestTemplate 이 파일명 없는 파트를 그냥 필드로 보내버려 FastAPI 가 422 를 냄
            ByteArrayResource imageResource = new ByteArrayResource(image.getBytes()) {
                @Override
                public String getFilename() {
                    return fileName;
                }
            };

            HttpHeaders imageHeaders = new HttpHeaders();
            imageHeaders.setContentDispositionFormData("image", fileName);
            imageHeaders.setContentType(MediaType.parseMediaType(contentType));

            MultiValueMap<String, Object> parts = new LinkedMultiValueMap<>();
            parts.add("prompt", prompt.trim());
            parts.add("image", new HttpEntity<>(imageResource, imageHeaders));

            HttpHeaders requestHeaders = new HttpHeaders();
            requestHeaders.setContentType(MediaType.MULTIPART_FORM_DATA);

            return imageRestTemplate.postForEntity(
                    fastApiUrl + "/api/images",
                    new HttpEntity<>(parts, requestHeaders),
                    ImageResponse.class);

        } catch (HttpStatusCodeException e) {
            // FastAPI 의 detail 에 키·주소가 섞일 수 있어 본문을 그대로 넘기지 않음
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .body(message("이미지 생성 요청을 처리하지 못했습니다"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(message("첨부 이미지를 읽을 수 없습니다"));
        } catch (RestClientException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .body(message("이미지 생성 서버에 연결할 수 없습니다"));
        }
    }

    private ResponseEntity<Map<String, Object>> badRequest(String text) {
        return ResponseEntity.badRequest().body(message(text));
    }

    private Map<String, Object> message(String text) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("message", text);
        body.put("receivedBy", "spring");
        return body;
    }
}
