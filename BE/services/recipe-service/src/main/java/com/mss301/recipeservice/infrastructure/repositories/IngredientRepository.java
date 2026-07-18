package com.mss301.recipeservice.infrastructure.repositories;

import com.mss301.recipeservice.domain.Ingredient;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IngredientRepository extends JpaRepository<Ingredient, Long> {
    Optional<Ingredient> findByNameIgnoreCase(String name);

    @Override
    @EntityGraph(attributePaths = "allergens")
    List<Ingredient> findAll(Sort sort);

    @EntityGraph(attributePaths = "allergens")
    Page<Ingredient> findByNameContainingIgnoreCase(String name, Pageable pageable);

    boolean existsByAllergensAllergenId(Long allergenId);
}
