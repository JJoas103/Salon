package com.soldesk.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.StylistMapper;
import com.soldesk.vo.StylistVO;

@Service
public class StylistService {
    
    @Autowired
    private StylistMapper stylistMapper;

    @Transactional
    public List<StylistVO> findBySalonId(int salonId){
        return stylistMapper.findBySalonId(salonId);
    }

    @Transactional
    public StylistVO findByStylistId(int stylistId){
        return stylistMapper.findById(stylistId);
    }
}
