package com.soldesk.vo;

/**
 * Services - 시술/서비스
 */
public class ServiceVO {

    private int serviceId; // service_id
    private int salonId; // salon_id
    private String serviceName;
    private String category; // 컷/펌/염색/클리닉/세트 (AI 시술 추천 필터링용, 미분류면 null)
    private java.math.BigDecimal price;
    private int durationMinutes; // 소요시간(분) (duration_minutes)
    private String description;
    private String concern; // AI 시술 추천 검색 가중치용 고민 키워드 (컷/펌 처럼 쉼표로 나열, 미분류면 null)
    private String createdAt; // created_at
    private String updatedAt; // updated_at

    // Services 테이블 컬럼이 아니라 findAllServices() 의 Salons 조인 결과.
    // /api/services(ai-service 카탈로그 API) 응답에만 채워지고, insert/update 는 참조하지 않는다.
    private String salonName;

    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }
    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public java.math.BigDecimal getPrice() { return price; }
    public void setPrice(java.math.BigDecimal price) { this.price = price; }
    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int durationMinutes) { this.durationMinutes = durationMinutes; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getConcern() { return concern; }
    public void setConcern(String concern) { this.concern = concern; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    public String getSalonName() { return salonName; }
    public void setSalonName(String salonName) { this.salonName = salonName; }
}
