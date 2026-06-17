package com.mindbloom.controller;

import com.mindbloom.dto.JournalRequest;
import com.mindbloom.model.JournalEntry;
import com.mindbloom.model.User;
import com.mindbloom.service.GemService;
import com.mindbloom.service.JournalService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/journal")
public class JournalController {

    private final JournalService journalService;
    private final GemService gemService;

    public JournalController(JournalService journalService, GemService gemService) {
        this.journalService = journalService;
        this.gemService = gemService;
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createEntry(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody JournalRequest request) {
        JournalEntry entry = journalService.createEntry(user, request);
        int gems = gemService.earnGems(user, "journal_entry");
        return ResponseEntity.ok(Map.of("entry", entry, "gemsEarned", gems));
    }

    @GetMapping
    public ResponseEntity<List<JournalEntry>> getEntries(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(journalService.getUserEntries(user.getId()));
    }
}
