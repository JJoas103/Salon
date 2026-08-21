package com.soldesk.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.soldesk.vo.NotificationVO;

public interface NotificationMapper {
    void insert(NotificationVO notification);
    List<NotificationVO> findRecentByUser(@Param("userId") int userId, @Param("limit") int limit);
    int countUnread(int userId);
    int markRead(@Param("notificationId") int notificationId, @Param("userId") int userId);
    int markAllRead(int userId);
}
