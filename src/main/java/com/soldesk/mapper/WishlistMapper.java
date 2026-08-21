package com.soldesk.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.soldesk.vo.SalonVO;

public interface WishlistMapper {
    boolean exists(@Param("userId") int userId, @Param("salonId") int salonId);
    void insert(@Param("userId") int userId, @Param("salonId") int salonId);
    void delete(@Param("userId") int userId, @Param("salonId") int salonId);
    int countByUserId(int userId);
    List<Integer> findSalonIdsByUserId(int userId);
    List<SalonVO> findSalonsByUserId(int userId);
    List<Integer> findUserIdsBySalonId(int salonId);
}
