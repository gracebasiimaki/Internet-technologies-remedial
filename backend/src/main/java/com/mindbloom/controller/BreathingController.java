package com.mindbloom.controller;

import com.mindbloom.model.BreathingSession;
import com.mindbloom.model.User;
import com.mindbloom.repository.BreathingSessionRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/breathing")
public class BreathingController {

    private final BreathingSessionRepository breathingRepository;

    public BreathingController(BreathingSessionRepository breathingRepository) {
        this.breathingRepository = breathingRepository;
    }

    @PostMapping
    public ResponseEntity<BreathingSession> logSession(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, Object> body) {
        BreathingSession session = BreathingSession.builder()
                .user(user)
                .technique((String) body.getOrDefault("technique", "4-7-8"))
                .durationSeconds((Integer) body.getOrDefault("durationSeconds", 60))
                .triggeredBySos(Boolean.TRUE.equals(body.get("triggeredBySos")))
                .build();
        return ResponseEntity.ok(breathingRepository.save(session));
    }

    @GetMapping
    public ResponseEntity<List<BreathingSession>> getHistory(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(breathingRepository.findByUserIdOrderByCreatedAtDesc(user.getId()));
    }
}
