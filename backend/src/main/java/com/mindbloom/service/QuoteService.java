package com.mindbloom.service;

import com.mindbloom.model.Quote;
import com.mindbloom.model.User;
import com.mindbloom.repository.QuoteRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Random;

@Service
public class QuoteService {

    private final QuoteRepository quoteRepository;
    private final Random random = new Random();

    public QuoteService(QuoteRepository quoteRepository) {
        this.quoteRepository = quoteRepository;
    }

    @PostConstruct
    public void seedQuotes() {
        if (quoteRepository.count() > 0) return;

        List<Quote> quotes = List.of(
            buildQuote("You don't have to control your thoughts. You just have to stop letting them control you.", "Dan Millman", "mindfulness", "TEEN,GEN_Z,YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("The greatest glory in living lies not in never falling, but in rising every time we fall.", "Nelson Mandela", "resilience", "TEEN,GEN_Z,YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("You are not your illness. You have an individual story to tell. You have a name, a history, a personality. Staying yourself is part of the battle.", "Julian Seifter", "self-worth", "GEN_Z,YOUNG_PROFESSIONAL,PARENT"),
            buildQuote("It's okay to not be okay. It's okay to ask for help. You are enough, just as you are.", "MindBloom", "self-compassion", "TEEN,GEN_Z,YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("Healing is not linear. Some days will be harder than others, and that's perfectly normal.", "MindBloom", "healing", "TEEN,GEN_Z,YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("Your anxiety doesn't define you. Your courage to face each day does.", "MindBloom", "anxiety", "TEEN,GEN_Z"),
            buildQuote("The strongest people are not those who show strength in front of us, but those who win battles we know nothing about.", "Unknown", "strength", "YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY"),
            buildQuote("Be patient with yourself. Self-growth is tender; it's holy ground.", "Stephen Covey", "growth", "YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("Almost everything will work again if you unplug it for a few minutes, including you.", "Anne Lamott", "rest", "GEN_Z,YOUNG_PROFESSIONAL"),
            buildQuote("You have been assigned this mountain to show others it can be moved.", "Mel Robbins", "purpose", "TEEN,GEN_Z,YOUNG_PROFESSIONAL"),
            buildQuote("Breathe. You're going to be okay. Breathe and remember that you've been in this place before.", "Daniell Koepke", "anxiety", "TEEN,GEN_Z,YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("There is hope, even when your brain tells you there isn't.", "John Green", "hope", "TEEN,GEN_Z"),
            buildQuote("You don't have to see the whole staircase, just take the first step.", "Martin Luther King Jr.", "courage", "TEEN,GEN_Z,YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("Out of your vulnerabilities will come your strength.", "Sigmund Freud", "vulnerability", "YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("What lies behind us and what lies before us are tiny matters compared to what lies within us.", "Ralph Waldo Emerson", "inner-strength", "PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("The wound is the place where the light enters you.", "Rumi", "healing", "MIDDLE_JOURNEY,ELDER"),
            buildQuote("It's not the load that breaks you down, it's the way you carry it.", "Lou Holtz", "perspective", "YOUNG_PROFESSIONAL,PARENT"),
            buildQuote("Your mental health is a priority. Your happiness is essential. Your self-care is a necessity.", "MindBloom", "self-care", "TEEN,GEN_Z,YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER"),
            buildQuote("Not everything that is faced can be changed, but nothing can be changed until it is faced.", "James Baldwin", "courage", "GEN_Z,YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY"),
            buildQuote("Sometimes the bravest thing you can do is ask for help.", "MindBloom", "vulnerability", "TEEN,GEN_Z,YOUNG_PROFESSIONAL,PARENT,MIDDLE_JOURNEY,ELDER")
        );

        quoteRepository.saveAll(quotes);
    }

    private Quote buildQuote(String content, String author, String category, String ageGroups) {
        return Quote.builder()
                .content(content)
                .author(author)
                .category(category)
                .ageGroups(ageGroups)
                .build();
    }

    public Quote getDailyQuote(User user) {
        String ageGroup = user != null && user.getAgeGroup() != null ?
                user.getAgeGroup().name() : "";
        List<Quote> quotes = quoteRepository.findByAgeGroup(ageGroup);
        if (quotes.isEmpty()) {
            quotes = quoteRepository.findAll();
        }
        if (quotes.isEmpty()) return null;
        return quotes.get(random.nextInt(quotes.size()));
    }

    public Quote getRandomQuote() {
        List<Quote> all = quoteRepository.findAll();
        if (all.isEmpty()) return null;
        return all.get(random.nextInt(all.size()));
    }
}
