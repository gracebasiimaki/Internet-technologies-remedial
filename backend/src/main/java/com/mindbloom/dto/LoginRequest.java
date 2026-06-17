package com.mindbloom.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class LoginRequest {
    @NotBlank
    private String emailOrUsername;

    @NotBlank
    private String password;
}
