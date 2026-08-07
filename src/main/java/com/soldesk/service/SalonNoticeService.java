package com.soldesk.service;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.soldesk.mapper.SalonNoticeMapper;
import com.soldesk.vo.SalonNoticeVO;

@Service
public class SalonNoticeService {

    @Autowired
    private SalonNoticeMapper salonNoticeMapper;

    @Autowired
    private FileService fileService;

    @Transactional(readOnly = true)
    public List<SalonNoticeVO> getBySalonId(int salonId) {
        return salonNoticeMapper.findBySalonId(salonId);
    }

    @Transactional
    public void create(SalonNoticeVO notice, MultipartFile imageFile) throws IOException {
        String title = trimToNull(notice.getTitle());
        String content = trimToNull(notice.getContent());
        if (title == null) {
            throw new IllegalArgumentException("제목을 입력해 주세요.");
        }
        if (title.length() > 255) {
            throw new IllegalArgumentException("제목은 255자 이하여야 합니다.");
        }
        if (content == null) {
            throw new IllegalArgumentException("내용을 입력해 주세요.");
        }
        notice.setTitle(title);
        notice.setContent(content);
        String saved = fileService.saveFile(imageFile);
        if (saved != null) {
            notice.setImageUrl("/upload/" + saved);
        }
        salonNoticeMapper.insert(notice);
    }

    @Transactional
    public void delete(int noticeId, int salonId) {
        SalonNoticeVO notice = salonNoticeMapper.findByIdAndSalonId(noticeId, salonId);
        if (notice == null) {
            throw new IllegalArgumentException("삭제할 공지사항을 찾을 수 없습니다.");
        }
        salonNoticeMapper.deleteByIdAndSalonId(noticeId, salonId);
        fileService.deleteFile(stripUploadPrefix(notice.getImageUrl()));
    }

    private String stripUploadPrefix(String imageUrl) {
        if (imageUrl != null && imageUrl.startsWith("/upload/")) {
            return imageUrl.substring("/upload/".length());
        }
        return null;
    }

    private String trimToNull(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }
}
