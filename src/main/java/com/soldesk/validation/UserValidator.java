package com.soldesk.validation;

import org.springframework.stereotype.Component;
import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.soldesk.vo.UserVO;

@Component
public class UserValidator implements Validator{
    
    @Override
    public boolean supports(Class<?> clazz) {
        return UserVO.class.isAssignableFrom(clazz);
    }//UserVO 타입의 객체를 검증

    @Override
    public void validate(Object target, Errors errors) {
        UserVO user = (UserVO)target;
        String beanName = errors.getObjectName();   //joinUser <- modelAttribute로 들어오는 값

        if(!beanName.equals("joinUser") && !beanName.equals("updateMember")){
            return;
        }//검증할 폼 객체가 아니면 건너뛰기

        //1) 필수값 체크(email, password, name)    
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "email", "email.required", "이메일은 필수입니다!");
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "password", "password.required", "비밀번호는 필수입니다!");
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "userName", "userName.required", "이름은 필수입니다!");

        // 2) 이메일 형식
        String email = user.getEmail();
        String emailRegex = "^[\\w.-]+@[\\w.-]+\\.[A-Za-z]{2,}$";
        if (email != null && !email.isBlank() && !email.matches(emailRegex)) {
            errors.rejectValue("email", "email.invalid", "이메일 형식이 올바르지 않습니다.");
        }

        // 3) 비밀번호 형식
        String password = user.getPassword();
        if(password != null && password.length() < 8){
            errors.rejectValue("password", "password.tooShort", "비밀번호가 너무 짧습니다");
        }
        
        // 4) phoneNumber
        String phone = user.getPhoneNumber();
        if (phone != null && !phone.isBlank() && !phone.matches("^01\\d-\\d{3,4}-\\d{4}$")) {
            errors.rejectValue("phoneNumber", "phone.invalid", "전화번호 형식이 올바르지 않습니다 (예: 010-1234-5678)");
        }
        
    }
}
