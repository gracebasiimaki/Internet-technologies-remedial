package com.mindbloom.controller;

import com.mindbloom.model.Quote;
import com.mindbloom.model.User;
import com.mindbloom.service.QuoteService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/quotes")
public class QuoteController {

    private final QuoteService quoteService;

    public QuoteController(QuoteService quoteService) {
        this.quoteService = quoteService;
    }

    @GetMapping("/daily")
    public ResponseEntity<Quote> getDailyQuote(@AuthenticationPrincipal User user) {
        Quote quote = (user != null) ? quoteService.getDailyQuote(user) : quoteService.getRandomQuote();
        return quote != null ? ResponseEntity.ok(quote) : ResponseEntity.noContent().build();
    }
}
