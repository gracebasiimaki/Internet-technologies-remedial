package com.mindbloom.repository;

import com.mindbloom.model.AiConversation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AiConversationRepository extends JpaRepository<AiConversation, Long> {
    List<AiConversation> findByUserIdAndSessionIdOrderByCreatedAtAsc(Long userId, String sessionId);
    List<AiConversation> findTop10ByUserIdOrderByCreatedAtDesc(Long userId);
}
