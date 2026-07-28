package com.soldesk.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

/**
 * 업로드 경로 설정 (properties/app.properties 의 upload.path).
 * webapp 바깥 경로이므로 WAR 을 재배포해도 업로드된 파일이 남는다.
 */
@Configuration
public class UploadConfig {

    @Value("${upload.path}")
    private String uploadPath;

    public String getUploadPath() {
        return uploadPath;
    }
}
