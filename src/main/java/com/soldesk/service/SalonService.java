package com.soldesk.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.SalonMapper;
import com.soldesk.vo.SalonVO;

@Service
public class SalonService {

    @Autowired
    private SalonMapper salonMapper;

    @Transactional
    public SalonVO getSalonByOwner(int ownerId){
        return salonMapper.findByOwnerId(ownerId);
    }//점주 소유 매장 조회
}
