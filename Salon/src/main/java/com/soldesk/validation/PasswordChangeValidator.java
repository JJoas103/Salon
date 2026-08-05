package com.soldesk.validation;

import org.springframework.stereotype.Component;
import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

import com.soldesk.vo.PasswordChangeVO;

@Component
public class PasswordChangeValidator implements Validator {

    @Override
    public boolean supports(Class<?> clazz) {
        return PasswordChangeVO.class.isAssignableFrom(clazz);
    }

    @Override
    public void validate(Object target, Errors errors) {
        PasswordChangeVO form = (PasswordChangeVO) target;

        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "currentPassword", "currentPassword.required", "현재 비밀번호를 입력해주세요.");
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "newPassword", "newPassword.required", "새 비밀번호를 입력해주세요.");

        String newPassword = form.getNewPassword();
        if (newPassword != null && newPassword.length() < 8) {
            errors.rejectValue("newPassword", "newPassword.tooShort", "비밀번호가 너무 짧습니다");
        }

        if (newPassword != null && !newPassword.equals(form.getConfirmPassword())) {
            errors.rejectValue("confirmPassword", "password.mismatch", "비밀번호가 일치하지 않습니다");
        }
    }
}
