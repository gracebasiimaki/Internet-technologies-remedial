package com.mindbloom.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.time.LocalDate;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RegisterRequest {
    @NotBlank @Email
    private String email;

    @NotBlank @Size(min = 3, max = 30)
    private String username;

    @NotBlank @Size(min = 8)
    private String password;

    @NotBlank
    private String fullName;

    @NotNull @Past
    private LocalDate dateOfBirth;

    private String country;
    private String gender;
}
