package com.soldesk.mapper;

import java.util.List;

import com.soldesk.vo.AdvertisementVO;

public interface AdvertisementMapper {

    List<AdvertisementVO> findVisible();
    List<AdvertisementVO> findAllForAdmin();
    AdvertisementVO findById(int advertisementId);
    int insert(AdvertisementVO advertisement);
    int update(AdvertisementVO advertisement);
    int delete(int advertisementId);
}
