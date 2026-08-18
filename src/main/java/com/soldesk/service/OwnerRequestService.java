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
        ownerRequestMapper.insertRequest(request);
    }//점주 승격 요청 등록

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
    }//승인: 요청 상태 변경 + 회원 user_type='owner' 전환 + 신청서의 매장명/연락처로 매장 생성(주소 등은 점주가 직접 입력) + 기본 영업시간 생성

    @Transactional
    public void reject(int requestId, int adminUserId){
        OwnerRequestVO request = ownerRequestMapper.findById(requestId);
        if(request == null || !"pending".equals(request.getStatus())){
            throw new IllegalArgumentException("이미 처리된 요청입니다.");
        }
        ownerRequestMapper.reject(requestId, adminUserId);
    }//반려: 요청 상태 변경만
}
