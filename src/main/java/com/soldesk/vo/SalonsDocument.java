package com.soldesk.vo;


//엘라스틱 서치 저장용 vo
public class SalonsDocument {
    
    private int salonId;
    private int ownerId;
    private String salonName;
    private String address;
    private String phoneNumber;
    private String description;
    private java.math.BigDecimal averageRating; // 평균 별점 (average_rating)
    private java.math.BigDecimal minimumPrice;
    private java.math.BigDecimal latitude;  //위도
    private java.math.BigDecimal longitude; //경도
    private String imageUrl;


    public static SalonsDocument from(SalonVO salon){
        SalonsDocument document = new SalonsDocument();
        document.setSalonId(salon.getSalonId());
        document.setOwnerId(salon.getOwnerId());
        document.setSalonName(salon.getSalonName());
        document.setAddress(salon.getAddress());
        document.setPhoneNumber(salon.getPhoneNumber());
        document.setDescription(salon.getDescription());
        document.setAverageRating(salon.getAverageRating());
        document.setMinimumPrice(salon.getMinimumPrice());
        document.setLatitude(salon.getLatitude());
        document.setLongitude(salon.getLongitude());
        document.setImageUrl(salon.getImageUrl());
        return document;
    }

    public SalonVO toSalonVO(){
        SalonVO salonVO = new SalonVO();
        salonVO.setSalonId(salonId);
        salonVO.setOwnerId(ownerId);
        salonVO.setSalonName(salonName);
        salonVO.setAddress(address);
        salonVO.setPhoneNumber(phoneNumber);
        salonVO.setDescription(description);
        salonVO.setAverageRating(averageRating);
        salonVO.setMinimumPrice(minimumPrice);
        salonVO.setLatitude(latitude);
        salonVO.setLongitude(longitude);
        salonVO.setImageUrl(imageUrl);
        return salonVO;
    }

    public int getSalonId() {
        return this.salonId;
    }

    public void setSalonId(int salonId) {
        this.salonId = salonId;
    }

    public int getOwnerId() {
        return this.ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public String getSalonName() {
        return this.salonName;
    }

    public void setSalonName(String salonName) {
        this.salonName = salonName;
    }

    public String getAddress() {
        return this.address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPhoneNumber() {
        return this.phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getDescription() {
        return this.description;
    }

    public void setDescription(String description) {
        this.description = description;
    }


    public java.math.BigDecimal getAverageRating() {
        return this.averageRating;
    }

    public void setAverageRating(java.math.BigDecimal averageRating) {
        this.averageRating = averageRating;
    }

    public java.math.BigDecimal getMinimumPrice() {
        return this.minimumPrice;
    }

    public void setMinimumPrice(java.math.BigDecimal minimumPrice) {
        this.minimumPrice = minimumPrice;
    }

    public java.math.BigDecimal getLatitude() {
        return this.latitude;
    }

    public void setLatitude(java.math.BigDecimal latitude) {
        this.latitude = latitude;
    }

    public java.math.BigDecimal getLongitude() {
        return this.longitude;
    }

    public void setLongitude(java.math.BigDecimal longitude) {
        this.longitude = longitude;
    }


    public String getImageUrl() {
        return this.imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    

}
