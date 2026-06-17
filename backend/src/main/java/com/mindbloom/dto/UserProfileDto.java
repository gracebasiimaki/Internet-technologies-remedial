package com.mindbloom.dto;

import com.mindbloom.model.User;
import lombok.*;
import java.time.LocalDate;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class UserProfileDto {
    private Long id;
    private String email;
    private String username;
    private String fullName;
    private LocalDate dateOfBirth;
    private String ageGroup;
    private String country;
    private String gender;
    private String photoUrl;
    private String bio;
    private String subscriptionTier;

    public static UserProfileDto fromUser(User user) {
        return UserProfileDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .dateOfBirth(user.getDateOfBirth())
                .ageGroup(user.getAgeGroup() != null ? user.getAgeGroup().name() : null)
                .country(user.getCountry())
                .gender(user.getGender())
                .photoUrl(user.getPhotoUrl())
                .bio(user.getBio())
                .subscriptionTier(user.getSubscriptionTier().name())
                .build();
    }
}
