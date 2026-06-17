package com.mindbloom.repository;

import com.mindbloom.model.Streak;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StreakRepository extends JpaRepository<Streak, Long> {
}
