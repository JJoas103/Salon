package com.soldesk.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.soldesk.mapper.ReviewMapper;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.ReviewVO;

@Service
public class ReviewService {
    @Autowired private ReviewMapper reviewMapper;

    @Transactional(readOnly = true)
    public List<ReviewVO> getReviews(int salonId) { return reviewMapper.findBySalonId(salonId); }
    @Transactional(readOnly = true)
    public int countReviews(int salonId) { return reviewMapper.countBySalonId(salonId); }
    @Transactional(readOnly = true)
    public List<ReviewVO> getUserReviews(int userId) { return reviewMapper.findByUserId(userId); }
    @Transactional(readOnly = true)
    public int countUserReviews(int userId) { return reviewMapper.countByUserId(userId); }
    @Transactional(readOnly = true)
    public List<ReservationVO> getReviewableReservations(int userId, int salonId) {
        return reviewMapper.findReviewableReservations(userId, salonId);
    }

    @Transactional
    public void write(int userId, int salonId, int reservationId, int rating, String comment) {
        String cleanComment = comment == null ? "" : comment.trim();
        if (rating < 1 || rating > 5) throw new IllegalArgumentException("별점은 1점부터 5점까지 선택해 주세요.");
        if (cleanComment.isEmpty()) throw new IllegalArgumentException("리뷰 내용을 입력해 주세요.");
        if (cleanComment.length() > 1000) throw new IllegalArgumentException("리뷰 내용은 1,000자 이하로 입력해 주세요.");
        if (reviewMapper.countReviewableReservation(reservationId, userId, salonId) != 1) {
            throw new IllegalArgumentException("리뷰를 작성할 수 있는 완료된 예약이 아닙니다.");
        }
        ReviewVO review = new ReviewVO();
        review.setUserId(userId);
        review.setSalonId(salonId);
        review.setReservationId(reservationId);
        review.setRating(rating);
        review.setComment(cleanComment);
        reviewMapper.insert(review);
        reviewMapper.refreshSalonAverageRating(salonId);
    }
}
