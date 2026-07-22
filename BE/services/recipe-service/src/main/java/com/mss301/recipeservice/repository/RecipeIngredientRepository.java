package com.mss301.recipeservice.repository;

import com.mss301.recipeservice.entity.RecipeIngredient;
import com.mss301.recipeservice.entity.RecipeIngredientId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RecipeIngredientRepository extends JpaRepository<RecipeIngredient, RecipeIngredientId> {
    boolean existsByIngredientIngredientId(Long ingredientId);
}
