package com.mindbloom.repository;

import com.mindbloom.model.BreathingSession;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BreathingSessionRepository extends JpaRepository<BreathingSession, Long> {
    List<BreathingSession> findByUserIdOrderByCreatedAtDesc(Long userId);
}
