package com.soldesk.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.soldesk.service.ReservationService;
import com.soldesk.service.UserService;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.UserVO;


@Controller
@RequestMapping("/reserve")
public class ReserveController {
    
    private static final Logger log = LoggerFactory.getLogger(RestController.class);

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private UserService userService;

    @GetMapping("/info")
    public String pageReserve(@RequestParam(defaultValue = "1") int category, Model model){

        String userEmail = SecurityContextHolder.getContext().getAuthentication().getName();
        UserVO user = userService.getUser(userEmail); //여기가 null뜨는중
        model.addAttribute("categoryIdx", category);
        if(category == 1){
            List<ReservationVO> list = reservationService.getRevList(user.getUserId()); //예약 완료된 정보
            model.addAttribute("reservs", list);//예약 정보
        }
        else if(category == 2){
            List<ReservationVO> list = reservationService.getClearRevList(user.getUserId()); //예약 완료된 정보
            model.addAttribute("reservs", list);//예약 정보

        }
        return "reserve/info";
    }
     
}
