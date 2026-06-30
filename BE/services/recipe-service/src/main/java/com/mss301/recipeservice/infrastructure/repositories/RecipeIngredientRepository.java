package com.mss301.recipeservice.infrastructure.repositories;

import com.mss301.recipeservice.domain.RecipeIngredient;
import com.mss301.recipeservice.domain.RecipeIngredientId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RecipeIngredientRepository extends JpaRepository<RecipeIngredient, RecipeIngredientId> {
    boolean existsByIngredientIngredientId(Long ingredientId);
}
