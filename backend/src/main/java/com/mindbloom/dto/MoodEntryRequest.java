package com.mindbloom.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MoodEntryRequest {
    @Min(1) @Max(10)
    private int moodScore;

    @Min(1) @Max(10)
    private int energyLevel;

    @Min(1) @Max(10)
    private int sleepQuality;

    @Min(1) @Max(10)
    private int anxietyLevel;

    private String notes;
}
