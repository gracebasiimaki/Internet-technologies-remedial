package com.mindbloom.controller;

import com.mindbloom.model.GemTransaction;
import com.mindbloom.model.User;
import com.mindbloom.model.UserGems;
import com.mindbloom.service.GemService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/gems")
public class GemController {

    private final GemService gemService;

    public GemController(GemService gemService) {
        this.gemService = gemService;
    }

    @GetMapping("/balance")
    public ResponseEntity<UserGems> getBalance(@AuthenticationPrincipal User user) {
        UserGems gems = gemService.getBalance(user.getId());
        return gems != null ? ResponseEntity.ok(gems) : ResponseEntity.noContent().build();
    }

    @GetMapping("/history")
    public ResponseEntity<List<GemTransaction>> getHistory(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(gemService.getHistory(user.getId()));
    }

    @PostMapping("/earn")
    public ResponseEntity<Map<String, Integer>> earn(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, String> body) {
        int earned = gemService.earnGems(user, body.get("action"));
        return ResponseEntity.ok(Map.of("gemsEarned", earned));
    }
}
