package com.mindbloom.dto;

import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ChatResponse {
    private String message;
    private String sessionId;
    private String emotionDetected;
    private int gemsEarned;
}
