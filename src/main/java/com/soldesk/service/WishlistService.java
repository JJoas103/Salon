package com.soldesk.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.soldesk.mapper.WishlistMapper;
import com.soldesk.vo.SalonVO;

@Service
public class WishlistService {
    @Autowired private WishlistMapper wishlistMapper;

    @Transactional
    public boolean toggle(int userId, int salonId) {
        if (wishlistMapper.exists(userId, salonId)) {
            wishlistMapper.delete(userId, salonId);
            return false;
        }
        wishlistMapper.insert(userId, salonId);
        return true;
    }
    @Transactional(readOnly = true)
    public boolean isWishlisted(int userId, int salonId) { return wishlistMapper.exists(userId, salonId); }
    @Transactional(readOnly = true)
    public int count(int userId) { return wishlistMapper.countByUserId(userId); }
    @Transactional(readOnly = true)
    public List<Integer> getSalonIds(int userId) { return wishlistMapper.findSalonIdsByUserId(userId); }
    @Transactional(readOnly = true)
    public List<SalonVO> getSalons(int userId) { return wishlistMapper.findSalonsByUserId(userId); }
}
