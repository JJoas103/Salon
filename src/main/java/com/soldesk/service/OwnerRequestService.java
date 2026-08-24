package com.soldesk.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.OwnerRequestMapper;
import com.soldesk.mapper.SalonMapper;
import com.soldesk.mapper.UserMapper;
import com.soldesk.vo.OwnerRequestVO;
import com.soldesk.vo.SalonVO;

@Service
public class OwnerRequestService {

    @Autowired
    private OwnerRequestMapper ownerRequestMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private SalonMapper salonMapper;

    @Transactional
    public int countPending(){
        return ownerRequestMapper.countPending();
    }//대기중인 요청 수 (관리자 회원관리 통계 카드용)

    @Transactional
    public int countPendingPromotion(){
        return ownerRequestMapper.countPendingByType("promotion");
    }//"점주 승격 요청" 탭 배지 숫자

    @Transactional
    public int countPendingAdditionalSalon(){
        return ownerRequestMapper.countPendingByType("additional_salon");
    }//"매장 추가 요청" 탭 배지 숫자

    @Transactional
    public List<OwnerRequestVO> getPendingAdditionalSalonRequests(){
        return ownerRequestMapper.findPendingByType("additional_salon");
    }//관리자 매장관리 "매장 추가 요청" 탭 목록

    // 화면(pattern="[0-9-]{9,13}")과 같은 규칙 — 폼 검증을 우회해 바로 요청을 보내는 경우까지 막는다
    private void assertValidPhone(String salonPhone) {
        if (salonPhone == null || !salonPhone.matches("[0-9-]{9,13}")) {
            throw new IllegalArgumentException("매장 연락처는 숫자와 하이픈(-)만 사용해 입력해주세요.");
        }
    }

    private void assertValidSalonName(String salonName) {
        if (salonName == null || salonName.trim().isEmpty()) {
            throw new IllegalArgumentException("매장명을 입력해주세요.");
        }
        if (salonName.trim().length() > 255) {
            throw new IllegalArgumentException("매장명은 255자 이하로 입력해주세요.");
        }
    }

    // 승격이든 매장추가든, 이미 처리 대기중인 요청이 있으면 또 넣을 수 없다 — 관리자가 뭘 승인하는 건지 헷갈리게 됨
    private void assertNoPendingRequest(int userId) {
        if (ownerRequestMapper.countPendingByUserId(userId) > 0) {
            throw new IllegalArgumentException("이미 처리 대기중인 요청이 있습니다. 관리자 검토가 끝난 뒤 다시 신청해주세요.");
        }
    }

    @Transactional
    public void submit(int userId, String salonName, String salonPhone, String message){
        assertValidSalonName(salonName);
        assertValidPhone(salonPhone);
        assertNoPendingRequest(userId);
        OwnerRequestVO request = new OwnerRequestVO();
        request.setUserId(userId);
        request.setSalonName(salonName.trim());
        request.setSalonPhone(salonPhone);
        request.setMessage(message);
        request.setRequestType("promotion");
        ownerRequestMapper.insertRequest(request);
    }//점주 승격 요청 등록

    /**
     * 이미 점주인 회원이 매장을 하나 더 등록해달라는 요청.
     * approve() 는 승격 요청과 똑같이 동작한다 — promoteToOwner 는 이미 점주라도 그대로 둘 뿐이라 무해하고,
     * insertSalon 은 owner_id 에 매장이 몇 개 있든 상관없이 새 행을 하나 추가한다.
     * 여기서 다른 건 request_type 뿐이고, 이건 관리자 화면 문구를 승격 요청과 구분해서 보여주는 데만 쓴다.
     */
    @Transactional
    public void submitAdditionalSalon(int ownerId, String salonName, String salonPhone, String message){
        assertValidSalonName(salonName);
        assertValidPhone(salonPhone);
        assertNoPendingRequest(ownerId);
        OwnerRequestVO request = new OwnerRequestVO();
        request.setUserId(ownerId);
        request.setSalonName(salonName.trim());
        request.setSalonPhone(salonPhone);
        request.setMessage(message);
        request.setRequestType("additional_salon");
        ownerRequestMapper.insertRequest(request);
    }//점주의 매장 추가 요청 등록

    @Transactional
    public void approve(int requestId, int adminUserId){
        OwnerRequestVO request = ownerRequestMapper.findById(requestId);
        if(request == null || !"pending".equals(request.getStatus())){
            throw new IllegalArgumentException("이미 처리된 요청입니다.");
        }
        ownerRequestMapper.approve(requestId, adminUserId);
        userMapper.promoteToOwner(request.getUserId());

        SalonVO salon = new SalonVO();
        salon.setOwnerId(request.getUserId());
        salon.setSalonName(request.getSalonName());
        salon.setPhoneNumber(request.getSalonPhone());
        salon.setAddress("");
        salonMapper.insertSalon(salon);
        // 영업시간을 기본값으로 미리 채워두면 필수정보 체크리스트에서 영업시간만 항상
        // "완료"로 시작해 나머지 3개(주소·시술메뉴·디자이너)와 형평이 안 맞는다.
        // preparing 상태인 동안은 손님에게 노출되지 않으니 비워둬도 안전하다 — 다른 항목처럼
        // 점주가 직접 영업시간관리 탭에서 입력해야 체크리스트가 완료된다.
    }//승인: 요청 상태 변경 + 회원 user_type='owner' 전환(이미 점주면 무해한 재실행) + 신청서의 매장명/연락처로 매장 생성(주소·영업시간 등은 점주가 직접 입력) — 승격/매장추가 요청 공통

    @Transactional
    public void reject(int requestId, int adminUserId){
        OwnerRequestVO request = ownerRequestMapper.findById(requestId);
        if(request == null || !"pending".equals(request.getStatus())){
            throw new IllegalArgumentException("이미 처리된 요청입니다.");
        }
        ownerRequestMapper.reject(requestId, adminUserId);
    }//반려: 요청 상태 변경만

    // 회원관리(점주 승격)와 매장관리(매장 추가)가 서로 다른 화면에서 각자의 종류만 처리하도록,
    // 승인/반려 전에 요청 종류가 그 화면이 다루는 종류가 맞는지 확인한다.
    // (예: 매장관리 화면에서 실수로 promotion 요청 id를 승인하는 것을 막는다)
    private void assertRequestType(int requestId, String expectedType) {
        OwnerRequestVO request = ownerRequestMapper.findById(requestId);
        if (request == null || !expectedType.equals(request.getRequestType())) {
            throw new IllegalArgumentException("해당 유형의 요청을 찾을 수 없습니다.");
        }
    }

    @Transactional
    public void approvePromotionRequest(int requestId, int adminUserId) {
        assertRequestType(requestId, "promotion");
        approve(requestId, adminUserId);
    }//회원관리 "점주 승격 요청" 탭 전용

    @Transactional
    public void rejectPromotionRequest(int requestId, int adminUserId) {
        assertRequestType(requestId, "promotion");
        reject(requestId, adminUserId);
    }//회원관리 "점주 승격 요청" 탭 전용

    @Transactional
    public void approveAdditionalSalonRequest(int requestId, int adminUserId) {
        assertRequestType(requestId, "additional_salon");
        approve(requestId, adminUserId);
    }//매장관리 "매장 추가 요청" 탭 전용

    @Transactional
    public void rejectAdditionalSalonRequest(int requestId, int adminUserId) {
        assertRequestType(requestId, "additional_salon");
        reject(requestId, adminUserId);
    }//매장관리 "매장 추가 요청" 탭 전용
}
