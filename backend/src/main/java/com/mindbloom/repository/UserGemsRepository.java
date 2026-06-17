package com.mindbloom.repository;

import com.mindbloom.model.UserGems;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserGemsRepository extends JpaRepository<UserGems, Long> {
}
