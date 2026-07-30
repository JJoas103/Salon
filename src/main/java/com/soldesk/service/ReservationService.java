package com.soldesk.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.ResvMapper;
import com.soldesk.vo.ReservationVO;

@Service
public class ReservationService {
    
    @Autowired
    private ResvMapper resvMapper;

    @Transactional
    public List<ReservationVO> getRevList(int userId){
        List<ReservationVO> list = resvMapper.getRevList(userId);
        return list;
    }

    @Transactional
    public List<ReservationVO> getClearRevList(int userId){
        List<ReservationVO> list = resvMapper.getClearRevList(userId);
        return list;
    }

    @Transactional
    public int countCompleted(int userId){
        return resvMapper.countCompleted(userId);
    }

}
