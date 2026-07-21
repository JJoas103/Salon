package com.soldesk.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.soldesk.mapper.UserMapper;
import com.soldesk.service.UserService;
import com.soldesk.validation.UserValidator;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/user")
public class UserController {
    
    private final Logger log = LoggerFactory.getLogger(UserController.class);
    @Autowired
    private UserService userService;

    @Autowired
    private UserValidator userValidator;

    @InitBinder("joinUser")
    public void initBinder(WebDataBinder binder){
        binder.addValidators(userValidator);
    }

    @GetMapping("/join")
    public String joinForm(@ModelAttribute("joinUser") UserVO joinUser){
        return "user/join";
    }//회원가입 페이지

    
    @PostMapping("/join")
    public String joinSubmit(@Validated
                             @ModelAttribute("joinUser") UserVO user, 
                             BindingResult result){
        log.debug(user.getPassword());
        if(result.hasErrors()){
            return "user/join"; // 검증 실패 -> 폼으로 돌아가기
        }
        userService.join(user);
        return "redirect:/user/login";
    }
    
    @GetMapping("/login")
    public String loginForm() {
        return "user/login";
    }//로그인 페이지
    
}
