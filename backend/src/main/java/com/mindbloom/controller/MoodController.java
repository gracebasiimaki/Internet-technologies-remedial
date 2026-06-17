package com.mindbloom.controller;

import com.mindbloom.dto.MoodEntryRequest;
import com.mindbloom.model.MoodEntry;
import com.mindbloom.model.User;
import com.mindbloom.service.GemService;
import com.mindbloom.service.MoodService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mood")
public class MoodController {

    private final MoodService moodService;
    private final GemService gemService;

    public MoodController(MoodService moodService, GemService gemService) {
        this.moodService = moodService;
        this.gemService = gemService;
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createEntry(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody MoodEntryRequest request) {
        MoodEntry entry = moodService.createEntry(user, request);
        int gems = gemService.earnGems(user, "daily_checkin");
        return ResponseEntity.ok(Map.of("entry", entry, "gemsEarned", gems));
    }

    @GetMapping
    public ResponseEntity<List<MoodEntry>> getEntries(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(moodService.getUserEntries(user.getId()));
    }
}
