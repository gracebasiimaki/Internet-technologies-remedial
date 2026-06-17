package com.mindbloom.service;

import com.mindbloom.dto.MoodEntryRequest;
import com.mindbloom.model.MoodEntry;
import com.mindbloom.model.User;
import com.mindbloom.repository.MoodEntryRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class MoodService {

    private final MoodEntryRepository moodRepository;

    public MoodService(MoodEntryRepository moodRepository) {
        this.moodRepository = moodRepository;
    }

    public MoodEntry createEntry(User user, MoodEntryRequest request) {
        MoodEntry entry = MoodEntry.builder()
                .user(user)
                .moodScore(request.getMoodScore())
                .energyLevel(request.getEnergyLevel())
                .sleepQuality(request.getSleepQuality())
                .anxietyLevel(request.getAnxietyLevel())
                .notes(request.getNotes())
                .build();
        return moodRepository.save(entry);
    }

    public List<MoodEntry> getUserEntries(Long userId) {
        return moodRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<MoodEntry> getEntriesBetween(Long userId, LocalDateTime start, LocalDateTime end) {
        return moodRepository.findByUserIdAndCreatedAtBetweenOrderByCreatedAtAsc(userId, start, end);
    }
}
