package com.soldesk.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.soldesk.mapper.UserMapper;

@Controller
public class HomeController {

    @Autowired
    private UserMapper userMapper;

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("message", "Salu 프로젝트 세팅 완료!");
        return "home";   // -> /WEB-INF/views/home.jsp
    }

    /** MyBatis / DB 연동 확인용 (확인 후 삭제 예정) */
    @GetMapping("/db-check")
    @ResponseBody
    public String dbCheck() {
        return "DB OK - Users count = " + userMapper.countAll();
    }
}
