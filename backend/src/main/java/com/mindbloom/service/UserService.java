package com.mindbloom.service;

import com.mindbloom.dto.*;
import com.mindbloom.model.User;
import com.mindbloom.model.UserGems;
import com.mindbloom.model.Streak;
import com.mindbloom.repository.UserRepository;
import com.mindbloom.repository.UserGemsRepository;
import com.mindbloom.repository.StreakRepository;
import com.mindbloom.security.JwtTokenProvider;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserGemsRepository gemsRepository;
    private final StreakRepository streakRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;

    public UserService(UserRepository userRepository,
                       UserGemsRepository gemsRepository,
                       StreakRepository streakRepository,
                       PasswordEncoder passwordEncoder,
                       JwtTokenProvider tokenProvider) {
        this.userRepository = userRepository;
        this.gemsRepository = gemsRepository;
        this.streakRepository = streakRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered");
        }
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already taken");
        }

        User user = User.builder()
                .email(request.getEmail())
                .username(request.getUsername())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .dateOfBirth(request.getDateOfBirth())
                .country(request.getCountry())
                .gender(request.getGender())
                .oauthProvider(User.OAuthProvider.LOCAL)
                .subscriptionTier(User.SubscriptionTier.SEEDLING)
                .build();

        user = userRepository.save(user);

        // Initialize gems
        UserGems gems = UserGems.builder()
                .user(user)
                .balance(50)   // welcome bonus
                .totalEarned(50)
                .totalSpent(0)
                .build();
        gemsRepository.save(gems);

        // Initialize streak
        Streak streak = Streak.builder()
                .user(user)
                .currentStreak(0)
                .longestStreak(0)
                .build();
        streakRepository.save(streak);

        return buildAuthResponse(user);
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmailOrUsername())
                .or(() -> userRepository.findByUsername(request.getEmailOrUsername()))
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Invalid credentials");
        }

        return buildAuthResponse(user);
    }

    private AuthResponse buildAuthResponse(User user) {
        String accessToken = tokenProvider.generateAccessToken(user.getId(), user.getEmail());
        String refreshToken = tokenProvider.generateRefreshToken(user.getId(), user.getEmail());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .user(UserProfileDto.fromUser(user))
                .build();
    }
}
