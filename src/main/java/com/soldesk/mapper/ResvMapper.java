package com.soldesk.mapper;

import java.util.List;

import com.soldesk.vo.ReservationVO;

public interface ResvMapper {

    List<ReservationVO> getRevList(int userId);//예약 리스트 가져오기
    
    List<ReservationVO> getClearRevList(int userId);//완료된 예약정보 가져오기

    int countCompleted(int userId);//완료된 예약 건수
}