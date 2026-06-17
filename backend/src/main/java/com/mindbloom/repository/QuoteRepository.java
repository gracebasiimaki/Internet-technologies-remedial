package com.mindbloom.repository;

import com.mindbloom.model.Quote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface QuoteRepository extends JpaRepository<Quote, Long> {
    @Query("SELECT q FROM Quote q WHERE q.ageGroups LIKE %:ageGroup%")
    List<Quote> findByAgeGroup(String ageGroup);

    List<Quote> findByCategory(String category);
}
