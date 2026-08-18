package com.soldesk.service;

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
    public void submit(int userId, String salonName, String salonPhone, String message){
        OwnerRequestVO request = new OwnerRequestVO();
        request.setUserId(userId);
        request.setSalonName(salonName);
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
        OwnerRequestVO request = new OwnerRequestVO();
        request.setUserId(ownerId);
        request.setSalonName(salonName);
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
        // 영업시간 행이 하나도 없으면 findOperatingHour 가 항상 휴무로 보므로,
        // 점주가 나중에 직접 조정할 때까지 쓸 기본값(월~토 10~20시, 일 휴무)을 같이 넣어둔다.
        salonMapper.insertDefaultOperatingHours(salon.getSalonId(), "10:00", "20:00");
    }//승인: 요청 상태 변경 + 회원 user_type='owner' 전환(이미 점주면 무해한 재실행) + 신청서의 매장명/연락처로 매장 생성(주소 등은 점주가 직접 입력) + 기본 영업시간 생성 — 승격/매장추가 요청 공통

    @Transactional
    public void reject(int requestId, int adminUserId){
        OwnerRequestVO request = ownerRequestMapper.findById(requestId);
        if(request == null || !"pending".equals(request.getStatus())){
            throw new IllegalArgumentException("이미 처리된 요청입니다.");
        }
        ownerRequestMapper.reject(requestId, adminUserId);
    }//반려: 요청 상태 변경만
}
