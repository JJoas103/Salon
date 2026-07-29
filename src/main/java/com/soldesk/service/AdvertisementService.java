package com.soldesk.service;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.AdvertisementMapper;
import com.soldesk.vo.AdvertisementVO;

@Service
public class AdvertisementService {

    @Autowired
    private AdvertisementMapper advertisementMapper;

    @Transactional(readOnly = true)
    public List<AdvertisementVO> getVisibleAdvertisements() {
        return advertisementMapper.findVisible();
    }

    @Transactional(readOnly = true)
    public List<AdvertisementVO> getAllForAdmin() {
        return advertisementMapper.findAllForAdmin();
    }

    @Transactional(readOnly = true)
    public AdvertisementVO getById(int advertisementId) {
        return advertisementMapper.findById(advertisementId);
    }

    @Transactional
    public void create(AdvertisementVO advertisement) {
        validateAndNormalize(advertisement, true);
        advertisementMapper.insert(advertisement);
    }

    @Transactional
    public void update(AdvertisementVO advertisement) {
        validateAndNormalize(advertisement, false);
        if (advertisementMapper.update(advertisement) != 1) {
            throw new IllegalArgumentException("수정할 광고를 찾을 수 없습니다.");
        }
    }

    @Transactional
    public void delete(int advertisementId) {
        if (advertisementMapper.delete(advertisementId) != 1) {
            throw new IllegalArgumentException("삭제할 광고를 찾을 수 없습니다.");
        }
    }

    private void validateAndNormalize(AdvertisementVO advertisement, boolean imageRequired) {
        if (advertisement == null) {
            throw new IllegalArgumentException("광고 정보가 없습니다.");
        }
        advertisement.setTitle(trimToNull(advertisement.getTitle()));
        advertisement.setDescription(trimToNull(advertisement.getDescription()));
        advertisement.setTargetUrl(trimToNull(advertisement.getTargetUrl()));

        if (advertisement.getTitle() == null) {
            throw new IllegalArgumentException("광고 제목을 입력해 주세요.");
        }
        if (advertisement.getTitle().length() > 200) {
            throw new IllegalArgumentException("광고 제목은 200자 이하여야 합니다.");
        }
        if (advertisement.getDescription() != null && advertisement.getDescription().length() > 500) {
            throw new IllegalArgumentException("광고 설명은 500자 이하여야 합니다.");
        }
        if (imageRequired && trimToNull(advertisement.getImageUrl()) == null) {
            throw new IllegalArgumentException("배너 이미지를 선택해 주세요.");
        }
        if (advertisement.getStartAt() != null && advertisement.getEndAt() != null
                && advertisement.getEndAt().isBefore(advertisement.getStartAt())) {
            throw new IllegalArgumentException("노출 종료일시는 시작일시보다 빠를 수 없습니다.");
        }
        validateTargetUrl(advertisement.getTargetUrl());
    }

    private void validateTargetUrl(String targetUrl) {
        if (targetUrl == null) {
            return;
        }
        if (targetUrl.length() > 1000) {
            throw new IllegalArgumentException("연결 URL은 1000자 이하여야 합니다.");
        }
        if (targetUrl.startsWith("/") && !targetUrl.startsWith("//")) {
            return;
        }
        try {
            URI uri = new URI(targetUrl);
            String scheme = uri.getScheme();
            if (uri.getHost() == null || scheme == null
                    || (!"http".equalsIgnoreCase(scheme) && !"https".equalsIgnoreCase(scheme))) {
                throw new IllegalArgumentException("연결 URL은 /로 시작하는 내부 경로 또는 http(s) URL만 가능합니다.");
            }
        } catch (URISyntaxException e) {
            throw new IllegalArgumentException("연결 URL 형식이 올바르지 않습니다.");
        }
    }

    private String trimToNull(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }
}
