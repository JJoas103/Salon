package com.soldesk.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.soldesk.service.SalonService;
import com.soldesk.vo.ServiceVO;

/** ai-service(FastAPI)가 시술 검색 인덱스를 만들 때 가져가는 내부 카탈로그 API.
 *  브라우저 세션이 아니라 서버 간 호출이라 SecurityConfig 에서 permitAll 로 열어둔다. */
@Controller
@RequestMapping("/api")
public class ServiceApiController {

    @Autowired
    private SalonService salonService;

    @GetMapping("/services")
    @ResponseBody
    public List<ServiceVO> services() {
        return salonService.getAllServices();
    }
}
