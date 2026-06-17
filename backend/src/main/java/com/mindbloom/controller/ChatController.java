package com.mindbloom.controller;

import com.mindbloom.dto.ChatRequest;
import com.mindbloom.dto.ChatResponse;
import com.mindbloom.model.User;
import com.mindbloom.service.AiTherapyService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final AiTherapyService aiService;

    public ChatController(AiTherapyService aiService) {
        this.aiService = aiService;
    }

    @PostMapping
    public ResponseEntity<ChatResponse> chat(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody ChatRequest request) {
        return ResponseEntity.ok(aiService.chat(user, request));
    }
}
