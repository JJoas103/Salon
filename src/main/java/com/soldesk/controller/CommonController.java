package com.soldesk.controller;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.soldesk.service.ReservationService;
import com.soldesk.service.UserService;
import com.soldesk.validation.PasswordChangeValidator;
import com.soldesk.vo.PasswordChangeVO;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/common")
public class CommonController {

    @Autowired
    private UserService userService;

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private PasswordChangeValidator passwordChangeValidator;

    @InitBinder("changePassword")
    public void initBinder(WebDataBinder binder){
        binder.addValidators(passwordChangeValidator);
    }

    @GetMapping("/home")
    public String home() {
        return "common/home";
    }


    @GetMapping("/mypage")
    public String mypage(Authentication authentication, Model model){

    UserVO user = userService.getUser(authentication.getName());

    model.addAttribute("user", user);
    model.addAttribute("reservationCount", reservationService.countCompleted(user.getUserId()));

    return "common/mypage";
    }

    /** 비밀번호 변경 (마이페이지 모달에서 AJAX로 호출) */
    @PostMapping("/mypage/password")
    @ResponseBody
    public Map<String, Object> passwordSubmit(Authentication authentication,
                                  @Validated @ModelAttribute("changePassword") PasswordChangeVO changePassword,
                                  BindingResult result){
        if(!result.hasErrors()){
            try{
                userService.changePassword(authentication.getName(), changePassword.getCurrentPassword(), changePassword.getNewPassword());
            } catch(IllegalArgumentException e){
                result.rejectValue("currentPassword", "currentPassword.mismatch", e.getMessage());
            }
        }

        if(result.hasErrors()){
            Map<String, String> errors = new LinkedHashMap<>();
            for(FieldError fieldError : result.getFieldErrors()){
                errors.put(fieldError.getField(), fieldError.getDefaultMessage());
            }
            return Map.of("success", false, "errors", errors);
        }
        return Map.of("success", true);
    }
}