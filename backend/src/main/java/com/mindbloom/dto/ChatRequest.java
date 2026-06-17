package com.mindbloom.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class ChatRequest {
    @NotBlank
    private String message;

    private String sessionId;
}
