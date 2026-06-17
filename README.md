# 🌸 MindBloom

**"Grow through what you go through"**

MindBloom is an AI-powered mental health and soul healing application available on **Web**, **Android**, and **iOS**. It delivers personalized, age-adaptive therapy and wellness tools powered by Claude AI.

## Architecture

```
mindbloom/
├── backend/          # Spring Boot REST API (Java 17)
│   ├── src/main/java/com/mindbloom/
│   └── src/main/resources/
├── frontend/         # Flutter app (Web + Android + iOS)
│   ├── lib/
│   └── pubspec.yaml
└── README.md
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile + Web | Flutter 3.x (Dart) with Riverpod |
| Backend | Spring Boot 3.x (Java 17) |
| Database | PostgreSQL 14+ |
| Cache | Redis |
| AI Engine | Claude API (Anthropic) |
| Auth | JWT + Spring Security + OAuth2 |
| Push Notifications | Firebase Cloud Messaging |
| Payments | RevenueCat + Stripe |
| Ads | Google AdMob |
| Storage | AWS S3 |
| CI/CD | GitHub Actions |

## MVP Features (Phase 1)

1. **User Authentication** — Email/password, Google, Apple, Facebook OAuth
2. **Age Detection & Profile** — Age-adaptive UI and AI personality
3. **AI Therapy Companion** — Claude-powered 24/7 therapy chat
4. **Daily Mood Tracking** — Mood, energy, sleep quality with charts
5. **Daily Quotes** — Age-personalized, shareable quotes
6. **Basic Journal** — Encrypted journal with AI mood analysis
7. **Breathing SOS** — One-button panic calm-down with animations
8. **Gems System** — Virtual currency gamification
9. **Blooming Subscription** — $9.99/mo premium tier via RevenueCat
10. **AdMob Ads** — Monetize free-tier users
11. **Push Notifications** — Daily check-ins via FCM
12. **Morning Ritual** — Personalized morning routine

## Getting Started

### Backend
```bash
cd backend
./mvnw spring-boot:run
```
The API runs at `http://localhost:8080`

### Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

## Brand Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Calm Blue | `#4A90D9` | Primary — trust, clarity |
| Healing Green | `#6DBF82` | Secondary — growth |
| Warm Purple | `#7B68EE` | Accent — spirituality |

## License

Confidential — All rights reserved © 2026 MindBloom
