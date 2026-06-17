package com.mindbloom.repository;

import com.mindbloom.model.MoodEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDateTime;
import java.util.List;

public interface MoodEntryRepository extends JpaRepository<MoodEntry, Long> {
    List<MoodEntry> findByUserIdOrderByCreatedAtDesc(Long userId);
    List<MoodEntry> findByUserIdAndCreatedAtBetweenOrderByCreatedAtAsc(
            Long userId, LocalDateTime start, LocalDateTime end);
}
