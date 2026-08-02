package com.soldesk.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.ReviewVO;

public interface ReviewMapper {
    List<ReviewVO> findBySalonId(int salonId);
    List<ReviewVO> findByUserId(int userId);
    int countByUserId(int userId);
    int countBySalonId(int salonId);
    List<ReservationVO> findReviewableReservations(@Param("userId") int userId,
                                                    @Param("salonId") int salonId);
    int countReviewableReservation(@Param("reservationId") int reservationId,
                                   @Param("userId") int userId,
                                   @Param("salonId") int salonId);
    void insert(ReviewVO review);
    void refreshSalonAverageRating(int salonId);
}
