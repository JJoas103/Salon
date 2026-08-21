package com.soldesk.vo;

/** ai-service 가 돌려주는 이미지 편집 결과
 *  이미지를 파일로 저장하지 않고 base64 로 실어 보냄 — 브라우저에서 data: URL 로 바로 씀 */
public class ImageResponse {

    private String imageBase64;
    private String mediaType;
    private String prompt;
    private String source;
    private String model;

    public ImageResponse() {
    }

    public String getImageBase64() {
        return imageBase64;
    }

    public void setImageBase64(String imageBase64) {
        this.imageBase64 = imageBase64;
    }

    public String getMediaType() {
        return mediaType;
    }

    public void setMediaType(String mediaType) {
        this.mediaType = mediaType;
    }

    public String getPrompt() {
        return prompt;
    }

    public void setPrompt(String prompt) {
        this.prompt = prompt;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }
}
