package com.soldesk.controller;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.soldesk.service.AdvertisementService;
import com.soldesk.service.FileService;
import com.soldesk.vo.AdvertisementVO;

@Controller
@RequestMapping("/admin/advertisements")
public class AdminAdvertisementController {

    @Autowired
    private AdvertisementService advertisementService;

    @Autowired
    private FileService fileService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("advertisements", advertisementService.getAllForAdmin());
        return "admin/advertisements/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        if (!model.containsAttribute("advertisement")) {
            AdvertisementVO advertisement = new AdvertisementVO();
            advertisement.setActive(true);
            model.addAttribute("advertisement", advertisement);
        }
        model.addAttribute("formMode", "create");
        return "admin/advertisements/form";
    }

    @PostMapping
    public String create(@ModelAttribute("advertisement") AdvertisementVO advertisement,
                         BindingResult bindingResult,
                         @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                         Model model,
                         RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return formWithError(model, advertisement, "create", "날짜 형식을 확인해 주세요.");
        }

        String savedFile = null;
        try {
            savedFile = fileService.saveAdvertisementImage(imageFile);
            if (savedFile != null) {
                advertisement.setImageUrl("/upload/" + savedFile);
            }
            advertisementService.create(advertisement);
            redirectAttributes.addFlashAttribute("message", "광고가 등록되었습니다.");
            return "redirect:/admin/advertisements";
        } catch (IOException | RuntimeException e) {
            if (savedFile != null) {
                fileService.deleteFile(savedFile);
            }
            return formWithError(model, advertisement, "create", userMessage(e));
        }
    }

    @GetMapping("/{advertisementId}/edit")
    public String editForm(@PathVariable int advertisementId,
                           Model model,
                           RedirectAttributes redirectAttributes) {
        AdvertisementVO advertisement = advertisementService.getById(advertisementId);
        if (advertisement == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "광고를 찾을 수 없습니다.");
            return "redirect:/admin/advertisements";
        }
        model.addAttribute("advertisement", advertisement);
        model.addAttribute("formMode", "edit");
        return "admin/advertisements/form";
    }

    @PostMapping("/{advertisementId}")
    public String update(@PathVariable int advertisementId,
                         @ModelAttribute("advertisement") AdvertisementVO advertisement,
                         BindingResult bindingResult,
                         @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                         Model model,
                         RedirectAttributes redirectAttributes) {
        AdvertisementVO stored = advertisementService.getById(advertisementId);
        if (stored == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "광고를 찾을 수 없습니다.");
            return "redirect:/admin/advertisements";
        }

        advertisement.setAdvertisementId(advertisementId);
        advertisement.setImageUrl(stored.getImageUrl());
        if (bindingResult.hasErrors()) {
            return formWithError(model, advertisement, "edit", "날짜 형식을 확인해 주세요.");
        }

        String savedFile = null;
        try {
            savedFile = fileService.saveAdvertisementImage(imageFile);
            if (savedFile != null) {
                advertisement.setImageUrl("/upload/" + savedFile);
            }
            advertisementService.update(advertisement);
            if (savedFile != null) {
                deleteUploadedUrl(stored.getImageUrl());
            }
            redirectAttributes.addFlashAttribute("message", "광고가 수정되었습니다.");
            return "redirect:/admin/advertisements";
        } catch (IOException | RuntimeException e) {
            if (savedFile != null) {
                fileService.deleteFile(savedFile);
                advertisement.setImageUrl(stored.getImageUrl());
            }
            return formWithError(model, advertisement, "edit", userMessage(e));
        }
    }

    @PostMapping("/{advertisementId}/delete")
    public String delete(@PathVariable int advertisementId,
                         RedirectAttributes redirectAttributes) {
        AdvertisementVO stored = advertisementService.getById(advertisementId);
        if (stored == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "광고를 찾을 수 없습니다.");
            return "redirect:/admin/advertisements";
        }
        try {
            advertisementService.delete(advertisementId);
            deleteUploadedUrl(stored.getImageUrl());
            redirectAttributes.addFlashAttribute("message", "광고가 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/admin/advertisements";
    }

    private String formWithError(Model model, AdvertisementVO advertisement,
                                 String formMode, String errorMessage) {
        model.addAttribute("advertisement", advertisement);
        model.addAttribute("formMode", formMode);
        model.addAttribute("errorMessage", errorMessage);
        return "admin/advertisements/form";
    }

    private void deleteUploadedUrl(String imageUrl) {
        if (imageUrl != null && imageUrl.startsWith("/upload/")) {
            fileService.deleteFile(imageUrl.substring("/upload/".length()));
        }
    }

    private String userMessage(Exception e) {
        return e instanceof IllegalArgumentException
                ? e.getMessage()
                : "광고 저장 중 오류가 발생했습니다. DB 테이블과 업로드 경로를 확인해 주세요.";
    }
}
