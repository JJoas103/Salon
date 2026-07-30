package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.ReservationVO;

public interface ResvMapper {

    List<ReservationVO> getRevList(
            @Param("userId") int userId
    );

    List<ReservationVO> getClearRevList(
            @Param("userId") int userId
    );

    int countCompleted(@Param("userId") int userId);

}