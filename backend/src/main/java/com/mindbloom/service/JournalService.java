package com.mindbloom.service;

import com.mindbloom.dto.JournalRequest;
import com.mindbloom.model.JournalEntry;
import com.mindbloom.model.User;
import com.mindbloom.repository.JournalEntryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class JournalService {

    private final JournalEntryRepository journalRepository;

    public JournalService(JournalEntryRepository journalRepository) {
        this.journalRepository = journalRepository;
    }

    public JournalEntry createEntry(User user, JournalRequest request) {
        JournalEntry entry = JournalEntry.builder()
                .user(user)
                .title(request.getTitle())
                .contentEncrypted(request.getContent()) // TODO: encrypt in production
                .moodBefore(request.getMoodBefore())
                .moodAfter(request.getMoodAfter())
                .build();
        return journalRepository.save(entry);
    }

    public List<JournalEntry> getUserEntries(Long userId) {
        return journalRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }
}
