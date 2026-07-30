package com.soldesk.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.soldesk.service.ReservationService;
import com.soldesk.service.AdvertisementService;
import com.soldesk.service.SalonService;
import com.soldesk.service.UserService;
import com.soldesk.validation.PasswordChangeValidator;
import com.soldesk.vo.PasswordChangeVO;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/common")
public class CommonController {

    @Autowired
    private UserService userService;

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private SalonService salonService;

    @Autowired
    private PasswordChangeValidator passwordChangeValidator;

    @Autowired
    private AdvertisementService advertisementService;

    // 지도 마커용 미용실 목록을 JSP 안에서 JS 배열로 쓰기 위해 직접 만들어 쓴다 (빈으로 등록된 ObjectMapper 는 없다)
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${kakaoMapApiKey}")
    private String kakaoMapApiKey;


    @InitBinder("changePassword")
    public void initBinder(WebDataBinder binder){
        binder.addValidators(passwordChangeValidator);
    }

    //메인페이지
    @GetMapping("/home")
    public String home(Model model) {
        model.addAttribute("salons", salonService.getSalons());
        model.addAttribute("advertisements", advertisementService.getVisibleAdvertisements());
        return "common/home";   
    }

    //마이페이지
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

    //예약 내역 가져오기
    @GetMapping("/reserve")
    public String pageReserve(@RequestParam(defaultValue = "1") int category, Model model){

        String userEmail = SecurityContextHolder.getContext().getAuthentication().getName();
        UserVO user = userService.getUser(userEmail);
        model.addAttribute("categoryIdx", category);
        if(category == 1){
            List<ReservationVO> list = reservationService.getRevList(user.getUserId()); //예약 완료된 정보
            model.addAttribute("reservs", list);//예약 정보
        }
        else if(category == 2){
            List<ReservationVO> list = reservationService.getClearRevList(user.getUserId()); //예약 완료된 정보
            model.addAttribute("reservs", list);//예약 정보

        }
        return "common/reservations";
    }
    
    //미용실 지도 검색 (카카오맵)
    @GetMapping("/salonmap")
    public String salonMap(Model model) throws JsonProcessingException{

        model.addAttribute("salonsJson", objectMapper.writeValueAsString(salonService.getSalons()));
        model.addAttribute("kakaoMapApiKey", kakaoMapApiKey);
        return "common/salonmap";
    }

    /** 지도 페이지 검색창이 호출한다. 뷰가 아니라 JSON 을 돌려주므로 Model 이 아니라
     *  @ResponseBody + 반환값이 곧 응답 본문이 된다. JSON 키는 SalonVO 필드명 그대로 나가고,
     *  salonmap.jsp 의 renderSalons() 가 그 이름을 그대로 읽는다.
     *  (검색은 상태를 바꾸지 않는 조회라서 POST 가 아니라 GET) */
    @GetMapping("/salons/search")
    @ResponseBody
    public List<SalonVO> searchSalons(@RequestParam(defaultValue = "") String keyword) throws Exception{
        return salonService.searchSalons(keyword);
    }

    //미용실 검색하기
    @GetMapping("/search")
    public String search(@RequestParam(required = false) Integer salonId, Model model) {
        if (salonId == null) {
            //모든 미용실정보 가져오기
            java.util.List<com.soldesk.vo.SalonVO> salons = salonService.getSalons();
            if (salons.isEmpty()) {
                model.addAttribute("salonNotFound", true);
                return "common/search";
            }
            salonId = salons.get(0).getSalonId();
        }
        //id로 미용실 정보 가져오기
        com.soldesk.vo.SalonVO salon = salonService.getSalon(salonId);
        if (salon == null) {
            model.addAttribute("salonNotFound", true);
            return "common/search";
        }

        model.addAttribute("salon", salon);
        //시술정보 가져오기
        model.addAttribute("services", salonService.getServices(salonId));
        return "common/search";
    }

    //1:1채팅
    @GetMapping("/chat")
    public String chat(@RequestParam(required = true) int salonId, Model model){

        SalonVO salon = salonService.getSalon(salonId);
        model.addAttribute("salon", salon);
        return "common/chat";
    }
}
