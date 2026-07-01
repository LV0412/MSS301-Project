package com.mss301.recipeservice.infrastructure.repositories;

import com.mss301.recipeservice.domain.Allergen;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AllergenRepository extends JpaRepository<Allergen, Long> {
    Optional<Allergen> findByNameIgnoreCase(String name);
}
