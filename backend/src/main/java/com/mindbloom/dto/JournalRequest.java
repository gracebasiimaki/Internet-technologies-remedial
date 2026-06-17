package com.mindbloom.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class JournalRequest {
    private String title;

    @NotBlank
    private String content;

    @Min(1) @Max(10)
    private int moodBefore;

    @Min(1) @Max(10)
    private int moodAfter;
}
