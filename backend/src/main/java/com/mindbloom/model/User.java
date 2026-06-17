package com.mindbloom.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;

@Entity
@Table(name = "users")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false, unique = true)
    private String username;

    private String passwordHash;

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false)
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    private AgeGroup ageGroup;

    private String country;

    private String gender;

    private String photoUrl;

    private String bio;

    @Enumerated(EnumType.STRING)
    private OAuthProvider oauthProvider;

    private String oauthProviderId;

    private boolean notificationsEnabled = true;
    private boolean biometricEnabled = false;

    @Enumerated(EnumType.STRING)
    private SubscriptionTier subscriptionTier = SubscriptionTier.SEEDLING;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        ageGroup = AgeGroup.fromAge(getAge());
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public int getAge() {
        if (dateOfBirth == null) return 0;
        return Period.between(dateOfBirth, LocalDate.now()).getYears();
    }

    public enum AgeGroup {
        TEEN,           // 13-17
        GEN_Z,          // 18-25
        YOUNG_PROFESSIONAL, // 26-35
        PARENT,         // 36-45
        MIDDLE_JOURNEY, // 46-60
        ELDER;          // 60+

        public static AgeGroup fromAge(int age) {
            if (age <= 17) return TEEN;
            if (age <= 25) return GEN_Z;
            if (age <= 35) return YOUNG_PROFESSIONAL;
            if (age <= 45) return PARENT;
            if (age <= 60) return MIDDLE_JOURNEY;
            return ELDER;
        }
    }

    public enum OAuthProvider {
        LOCAL, GOOGLE, APPLE, FACEBOOK
    }

    public enum SubscriptionTier {
        SEEDLING, BLOOMING, FLOURISHING
    }
}
