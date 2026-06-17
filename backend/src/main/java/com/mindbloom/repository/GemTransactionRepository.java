package com.mindbloom.repository;

import com.mindbloom.model.GemTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface GemTransactionRepository extends JpaRepository<GemTransaction, Long> {
    List<GemTransaction> findByUserIdOrderByCreatedAtDesc(Long userId);
}
