package com.mindbloom.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "gem_transactions")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class GemTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private int amount;

    @Enumerated(EnumType.STRING)
    private TransactionType type;

    private String action; // e.g. "daily_checkin", "journal_entry"

    private String referenceId;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public enum TransactionType {
        EARN, SPEND, PURCHASE
    }
}
