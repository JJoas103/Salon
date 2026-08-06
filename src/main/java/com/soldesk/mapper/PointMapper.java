package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.PointTransactionVO;

public interface PointMapper {

    /** @return 0 이면 잔액 부족 (조건과 갱신이 한 문장이라 이 값이 곧 판정이다) */
    int deductPoint(@Param("userId") int userId, @Param("amount") int amount);

    int addPoint(@Param("userId") int userId, @Param("amount") int amount);

    int findBalance(int userId);

    void insertTx(PointTransactionVO tx);

    /** 원복할 때 "얼마를 되돌릴지" 를 이 원장에서 읽는다 */
    PointTransactionVO findByReservationAndType(@Param("reservationId") Integer reservationId,
                                                @Param("txType") String txType);

    List<PointTransactionVO> findByUserId(int userId);
}
