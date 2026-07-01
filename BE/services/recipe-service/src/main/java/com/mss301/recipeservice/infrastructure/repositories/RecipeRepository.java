package com.mss301.recipeservice.infrastructure.repositories;

import com.mss301.recipeservice.domain.Recipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface RecipeRepository extends JpaRepository<Recipe, Long>, JpaSpecificationExecutor<Recipe> {
    boolean existsByCategoryCategoryId(Long categoryId);
}
