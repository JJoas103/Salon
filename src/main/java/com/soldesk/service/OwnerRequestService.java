package com.soldesk.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.OwnerRequestMapper;
import com.soldesk.mapper.UserMapper;
import com.soldesk.vo.OwnerRequestVO;

@Service
public class OwnerRequestService {

    @Autowired
    private OwnerRequestMapper ownerRequestMapper;

    @Autowired
    private UserMapper userMapper;

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
    }//승인: 요청 상태 변경 + 회원 user_type='owner' 전환

    @Transactional
    public void reject(int requestId, int adminUserId){
        OwnerRequestVO request = ownerRequestMapper.findById(requestId);
        if(request == null || !"pending".equals(request.getStatus())){
            throw new IllegalArgumentException("이미 처리된 요청입니다.");
        }
        ownerRequestMapper.reject(requestId, adminUserId);
    }//반려: 요청 상태 변경만
}
