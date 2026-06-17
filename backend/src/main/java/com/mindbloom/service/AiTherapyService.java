package com.mindbloom.service;

import com.mindbloom.dto.ChatRequest;
import com.mindbloom.dto.ChatResponse;
import com.mindbloom.model.AiConversation;
import com.mindbloom.model.User;
import com.mindbloom.repository.AiConversationRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class AiTherapyService {

    private final AiConversationRepository conversationRepository;
    private final RestTemplate restTemplate;

    @Value("${mindbloom.claude.api-key:}")
    private String claudeApiKey;

    @Value("${mindbloom.claude.model}")
    private String claudeModel;

    @Value("${mindbloom.claude.max-tokens}")
    private int maxTokens;

    public AiTherapyService(AiConversationRepository conversationRepository) {
        this.conversationRepository = conversationRepository;
        this.restTemplate = new RestTemplate();
    }

    public ChatResponse chat(User user, ChatRequest request) {
        String sessionId = request.getSessionId() != null ?
                request.getSessionId() : UUID.randomUUID().toString();

        // Save user message
        AiConversation userMsg = AiConversation.builder()
                .user(user)
                .sessionId(sessionId)
                .role(AiConversation.Role.USER)
                .contentEncrypted(request.getMessage())
                .build();
        conversationRepository.save(userMsg);

        // Get AI response
        String aiResponse = callClaudeApi(user, request.getMessage(), sessionId);
        String emotion = detectEmotion(request.getMessage());

        // Save AI message
        AiConversation aiMsg = AiConversation.builder()
                .user(user)
                .sessionId(sessionId)
                .role(AiConversation.Role.ASSISTANT)
                .contentEncrypted(aiResponse)
                .emotionDetected(emotion)
                .build();
        conversationRepository.save(aiMsg);

        return ChatResponse.builder()
                .message(aiResponse)
                .sessionId(sessionId)
                .emotionDetected(emotion)
                .gemsEarned(0)
                .build();
    }

    private String callClaudeApi(User user, String message, String sessionId) {
        if (claudeApiKey == null || claudeApiKey.isBlank()) {
            return getOfflineResponse(user, message);
        }

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-api-key", claudeApiKey);
            headers.set("anthropic-version", "2023-06-01");

            // Build conversation history
            List<AiConversation> history = conversationRepository
                    .findTop10ByUserIdOrderByCreatedAtDesc(user.getId());

            List<Map<String, String>> messages = new ArrayList<>();
            Collections.reverse(history);
            for (AiConversation conv : history) {
                messages.add(Map.of(
                        "role", conv.getRole() == AiConversation.Role.USER ? "user" : "assistant",
                        "content", conv.getContentEncrypted()
                ));
            }
            messages.add(Map.of("role", "user", "content", message));

            Map<String, Object> body = Map.of(
                    "model", claudeModel,
                    "max_tokens", maxTokens,
                    "system", buildSystemPrompt(user),
                    "messages", messages
            );

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            ResponseEntity<Map> response = restTemplate.exchange(
                    "https://api.anthropic.com/v1/messages",
                    HttpMethod.POST, entity, Map.class);

            if (response.getBody() != null) {
                List<Map<String, String>> content = (List<Map<String, String>>) response.getBody().get("content");
                if (content != null && !content.isEmpty()) {
                    return content.get(0).get("text");
                }
            }
        } catch (Exception e) {
            // Fall back to offline mode
        }

        return getOfflineResponse(user, message);
    }

    private String buildSystemPrompt(User user) {
        String agePersonality = switch (user.getAgeGroup()) {
            case TEEN -> "You speak casually, use relatable language, and feel like a cool older sibling. Use occasional emojis.";
            case GEN_Z -> "You're trendy, direct, understand hustle culture and social media pressure. Keep it real.";
            case YOUNG_PROFESSIONAL -> "You're professional, balanced, understand career and relationship pressures.";
            case PARENT -> "You're warm, parenting-aware, focused on work-life balance.";
            case MIDDLE_JOURNEY -> "You're mature, respectful, health-conscious and reflective.";
            case ELDER -> "You're patient, use simple language, deeply warm and unhurried.";
            default -> "You're warm, empathetic, and thoughtful.";
        };

        return String.format("""
            You are MindBloom's AI therapy companion. Your name is Bloom.
            
            User: %s (age group: %s)
            
            Personality: %s
            
            Core rules:
            - You are NOT a licensed therapist. Always remind users of this when appropriate.
            - Listen deeply before responding. Validate feelings first.
            - Never judge, never rush to solutions.
            - If crisis language is detected (suicidal ideation, self-harm), stay calm,
              validate feelings, and provide crisis hotline numbers.
            - Remember context from this conversation.
            - Be warm, genuine, and human.
            - Keep responses concise but meaningful (2-4 paragraphs max).
            """, user.getFullName(), user.getAgeGroup().name(), agePersonality);
    }

    private String getOfflineResponse(User user, String message) {
        String name = user.getFullName().split(" ")[0];
        String lowerMsg = message.toLowerCase();

        if (lowerMsg.contains("anxious") || lowerMsg.contains("anxiety") || lowerMsg.contains("worried")) {
            return String.format(
                "I hear you, %s. Anxiety can feel overwhelming, but you're not alone in this. " +
                "Take a slow breath with me — in for 4, hold for 7, out for 8. " +
                "What's weighing on your mind the most right now?", name);
        }
        if (lowerMsg.contains("sad") || lowerMsg.contains("depressed") || lowerMsg.contains("down")) {
            return String.format(
                "Thank you for sharing that with me, %s. It takes courage to name what you're feeling. " +
                "Your sadness is valid, and I'm here to sit with you in it. " +
                "Would you like to tell me more about what's been going on?", name);
        }
        if (lowerMsg.contains("angry") || lowerMsg.contains("frustrated") || lowerMsg.contains("mad")) {
            return String.format(
                "%s, anger is a natural response and it's telling you something important. " +
                "Let's take a moment to breathe and then explore what's underneath it. " +
                "What triggered this feeling?", name);
        }
        if (lowerMsg.contains("lonely") || lowerMsg.contains("alone")) {
            return String.format(
                "I'm here with you, %s. Loneliness can be one of the heaviest feelings, " +
                "but reaching out like this shows real strength. " +
                "Tell me — when did you start feeling this way?", name);
        }
        if (lowerMsg.contains("happy") || lowerMsg.contains("good") || lowerMsg.contains("great")) {
            return String.format(
                "That's wonderful to hear, %s! I'm genuinely happy for you. " +
                "Let's hold onto this feeling — what's been contributing to your good mood?", name);
        }

        return String.format(
            "Thank you for sharing, %s. I'm here and I'm listening. " +
            "There's no rush — take your time and tell me what's on your mind. " +
            "Whatever you're feeling right now is completely valid.", name);
    }

    private String detectEmotion(String message) {
        String lower = message.toLowerCase();
        if (lower.contains("anxious") || lower.contains("anxiety") || lower.contains("worried") || lower.contains("nervous"))
            return "ANXIETY";
        if (lower.contains("sad") || lower.contains("depressed") || lower.contains("cry") || lower.contains("down"))
            return "SADNESS";
        if (lower.contains("angry") || lower.contains("frustrated") || lower.contains("mad") || lower.contains("furious"))
            return "ANGER";
        if (lower.contains("lonely") || lower.contains("alone") || lower.contains("isolated"))
            return "LONELINESS";
        if (lower.contains("happy") || lower.contains("joy") || lower.contains("great") || lower.contains("good"))
            return "JOY";
        if (lower.contains("scared") || lower.contains("afraid") || lower.contains("fear"))
            return "FEAR";
        if (lower.contains("confused") || lower.contains("lost") || lower.contains("uncertain"))
            return "CONFUSION";
        if (lower.contains("numb") || lower.contains("empty") || lower.contains("nothing"))
            return "NUMBNESS";
        if (lower.contains("shame") || lower.contains("guilty") || lower.contains("ashamed"))
            return "SHAME";
        return "NEUTRAL";
    }
}
