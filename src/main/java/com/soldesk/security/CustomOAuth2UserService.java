package com.soldesk.security;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.UserMapper;
import com.soldesk.vo.UserVO;

/**
 * 구글/네이버 로그인 후 프로필을 Users 테이블과 연결한다.
 * 이메일이 같은 기존 로컬 계정이 있으면 provider/provider_id만 갱신해 자동 연동하고(계정 분리 없음),
 * 없으면 비밀번호 없는 새 customer 계정을 만든다.
 */
@Service
public class CustomOAuth2UserService implements OAuth2UserService<OAuth2UserRequest, OAuth2User> {

    private final DefaultOAuth2UserService delegate = new DefaultOAuth2UserService();

    @Autowired
    private UserMapper userMapper;

    @Override
    @Transactional
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User raw = delegate.loadUser(userRequest);
        String registrationId = userRequest.getClientRegistration().getRegistrationId(); // "google" / "naver"

        Map<String, Object> profile = extractProfile(registrationId, raw.getAttributes());
        String email = (String) profile.get("email");
        String name = (String) profile.get("name");
        String providerId = String.valueOf(profile.get("id"));

        if (email == null || email.isBlank()) {
            throw new OAuth2AuthenticationException(registrationId + " 계정에서 이메일 제공 동의가 필요합니다.");
        }

        UserVO user = userMapper.findByEmail(email);
        int userId;
        String role;
        if (user == null) {
            UserVO newUser = new UserVO();
            newUser.setEmail(email);
            newUser.setUserName(name != null ? name : email);
            newUser.setUserType("customer");
            newUser.setProvider(registrationId);
            newUser.setProviderId(providerId);
            userMapper.insertOAuthUser(newUser);
            userId = newUser.getUserId();
            role = "CUSTOMER";
        } else {
            if (!registrationId.equals(user.getProvider())) {
                userMapper.linkProvider(email, registrationId, providerId);
            }
            userId = user.getUserId();
            role = UserDetailService.resolveRole(user.getUserType());
        }

        return new CustomOAuth2User(userId, email, name != null ? name : email, role, raw.getAttributes());
    }

    // 프로바이더별 사용자 정보 응답 모양이 달라 이메일/이름/식별자를 평탄화한다.
    // 구글: 최상위에 email/name/sub. 네이버: {resultcode, message, response:{id,email,name}}.
    @SuppressWarnings("unchecked")
    private Map<String, Object> extractProfile(String registrationId, Map<String, Object> attributes) {
        Map<String, Object> profile = new LinkedHashMap<>();
        if ("naver".equals(registrationId)) {
            Map<String, Object> response = (Map<String, Object>) attributes.get("response");
            if (response != null) {
                profile.put("id", response.get("id"));
                profile.put("email", response.get("email"));
                profile.put("name", response.get("name"));
            }
        } else {
            profile.put("id", attributes.get("sub"));
            profile.put("email", attributes.get("email"));
            profile.put("name", attributes.get("name"));
        }
        return profile;
    }
}
