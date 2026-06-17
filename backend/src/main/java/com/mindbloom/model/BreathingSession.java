package com.mindbloom.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "breathing_sessions")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BreathingSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String technique; // e.g. "4-7-8", "box", "deep"

    private int durationSeconds;

    private boolean triggeredBySos;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
