package com.soldesk.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.soldesk.service.SalonService;


@Controller
public class HomeController {

    @Autowired
    private SalonService salonService;

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("salons", salonService.getSalons());
        return "home";   
    }

    @GetMapping("/search")
    public String search(@RequestParam(required = false) Integer salonId, Model model) {
        if (salonId == null) {
            java.util.List<com.soldesk.vo.SalonVO> salons = salonService.getSalons();
            if (salons.isEmpty()) {
                model.addAttribute("salonNotFound", true);
                return "search";
            }
            salonId = salons.get(0).getSalonId();
        }

        com.soldesk.vo.SalonVO salon = salonService.getSalon(salonId);
        if (salon == null) {
            model.addAttribute("salonNotFound", true);
            return "search";
        }

        model.addAttribute("salon", salon);
        model.addAttribute("services", salonService.getServices(salonId));
        return "search";
    }
    
    
}
