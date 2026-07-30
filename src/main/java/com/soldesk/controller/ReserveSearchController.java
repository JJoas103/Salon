package com.soldesk.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.soldesk.vo.SalonVO;

@Controller
@RequestMapping("/reserveSearch")
public class ReserveSearchController {
    
    @GetMapping("/reserveSearch/search")
    public String listReserveSearch(@RequestParam int salonId, Model model){
        //List<SalonVO> list = salonService.getSalonById(salonId);    //서비스에서 미용실 정보 가져오기
        //model.addAttribute("list", list);
        return "search";
    }
}
