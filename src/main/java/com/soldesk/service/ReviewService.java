package com.soldesk.service;

import java.io.IOException;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import com.soldesk.mapper.ReviewMapper;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.ReviewVO;

@Service
public class ReviewService {
    @Autowired private ReviewMapper reviewMapper;
    @Autowired private FileService fileService;

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
    public void write(int userId, int salonId, int reservationId, int rating, String comment,
            MultipartFile imageFile, MultipartFile imageFile2) throws IOException {
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
        String saved = fileService.saveFile(imageFile);
        if (saved != null) {
            review.setImageUrl("/upload/" + saved);
        }
        String saved2 = fileService.saveFile(imageFile2);
        if (saved2 != null) {
            review.setImageUrl2("/upload/" + saved2);
        }
        reviewMapper.insert(review);
        reviewMapper.refreshSalonAverageRating(salonId);
    }

    @Transactional(readOnly = true)
    public ReviewVO getReview(int reviewId) {
        return reviewMapper.findById(reviewId);
    }

    @Transactional
    public void update(int reviewId, int userId, int rating, String comment,
            MultipartFile imageFile, MultipartFile imageFile2) throws IOException {
        ReviewVO existing = reviewMapper.findById(reviewId);
        if (existing == null || existing.getUserId() != userId) {
            throw new IllegalArgumentException("본인이 작성한 리뷰만 수정할 수 있습니다.");
        }
        String cleanComment = comment == null ? "" : comment.trim();
        if (rating < 1 || rating > 5) throw new IllegalArgumentException("별점은 1점부터 5점까지 선택해 주세요.");
        if (cleanComment.isEmpty()) throw new IllegalArgumentException("리뷰 내용을 입력해 주세요.");
        if (cleanComment.length() > 1000) throw new IllegalArgumentException("리뷰 내용은 1,000자 이하로 입력해 주세요.");

        existing.setRating(rating);
        existing.setComment(cleanComment);
        String saved = fileService.saveFile(imageFile);
        if (saved != null) {
            fileService.deleteFile(stripUploadPrefix(existing.getImageUrl()));
            existing.setImageUrl("/upload/" + saved);
        }
        String saved2 = fileService.saveFile(imageFile2);
        if (saved2 != null) {
            fileService.deleteFile(stripUploadPrefix(existing.getImageUrl2()));
            existing.setImageUrl2("/upload/" + saved2);
        }
        reviewMapper.update(existing);
        reviewMapper.refreshSalonAverageRating(existing.getSalonId());
    }

    private String stripUploadPrefix(String imageUrl) {
        if (imageUrl != null && imageUrl.startsWith("/upload/")) {
            return imageUrl.substring("/upload/".length());
        }
        return null;
    }
}
