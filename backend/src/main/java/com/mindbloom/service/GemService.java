package com.mindbloom.service;

import com.mindbloom.model.GemTransaction;
import com.mindbloom.model.User;
import com.mindbloom.model.UserGems;
import com.mindbloom.repository.GemTransactionRepository;
import com.mindbloom.repository.UserGemsRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class GemService {

    private final UserGemsRepository gemsRepository;
    private final GemTransactionRepository transactionRepository;

    @Value("${mindbloom.gems.daily-checkin}") private int dailyCheckin;
    @Value("${mindbloom.gems.journal-entry}") private int journalEntry;
    @Value("${mindbloom.gems.meditation}") private int meditation;
    @Value("${mindbloom.gems.weekly-streak}") private int weeklyStreak;
    @Value("${mindbloom.gems.challenge}") private int challenge;
    @Value("${mindbloom.gems.quote-share}") private int quoteShare;
    @Value("${mindbloom.gems.letter}") private int letter;
    @Value("${mindbloom.gems.ritual}") private int ritual;
    @Value("${mindbloom.gems.referral}") private int referral;

    public GemService(UserGemsRepository gemsRepository,
                      GemTransactionRepository transactionRepository) {
        this.gemsRepository = gemsRepository;
        this.transactionRepository = transactionRepository;
    }

    @Transactional
    public int earnGems(User user, String action) {
        int amount = getRewardForAction(action);
        if (amount <= 0) return 0;

        // Apply subscription multiplier
        int multiplier = switch (user.getSubscriptionTier()) {
            case BLOOMING -> 2;
            case FLOURISHING -> 3;
            default -> 1;
        };
        amount *= multiplier;

        UserGems gems = gemsRepository.findById(user.getId())
                .orElseGet(() -> UserGems.builder()
                        .user(user)
                        .balance(0)
                        .totalEarned(0)
                        .totalSpent(0)
                        .build());

        gems.setBalance(gems.getBalance() + amount);
        gems.setTotalEarned(gems.getTotalEarned() + amount);
        gemsRepository.save(gems);

        GemTransaction tx = GemTransaction.builder()
                .user(user)
                .amount(amount)
                .type(GemTransaction.TransactionType.EARN)
                .action(action)
                .build();
        transactionRepository.save(tx);

        return amount;
    }

    public UserGems getBalance(Long userId) {
        return gemsRepository.findById(userId).orElse(null);
    }

    public List<GemTransaction> getHistory(Long userId) {
        return transactionRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    private int getRewardForAction(String action) {
        return switch (action) {
            case "daily_checkin" -> dailyCheckin;
            case "journal_entry" -> journalEntry;
            case "meditation" -> meditation;
            case "weekly_streak" -> weeklyStreak;
            case "challenge" -> challenge;
            case "quote_share" -> quoteShare;
            case "letter" -> letter;
            case "ritual" -> ritual;
            case "referral" -> referral;
            default -> 0;
        };
    }
}
