package com.mss301.recipeservice.repository;

import com.mss301.recipeservice.entity.Recipe;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface RecipeRepository extends JpaRepository<Recipe, Long>, JpaSpecificationExecutor<Recipe> {
    @Override
    @EntityGraph(attributePaths = {
            "category",
            "recipeIngredients",
            "recipeIngredients.ingredient",
            "recipeIngredients.ingredient.allergens",
            "steps",
            "nutrition",
            "dietTypes"
    })
    Optional<Recipe> findById(Long recipeId);

    @Override
    @EntityGraph(attributePaths = {
            "category",
            "recipeIngredients",
            "recipeIngredients.ingredient",
            "recipeIngredients.ingredient.allergens",
            "steps",
            "nutrition",
            "dietTypes"
    })
    List<Recipe> findAll(Sort sort);

    @EntityGraph(attributePaths = {
            "category",
            "recipeIngredients",
            "recipeIngredients.ingredient",
            "recipeIngredients.ingredient.allergens",
            "steps",
            "nutrition",
            "dietTypes"
    })
    List<Recipe> findByRecipeIdIn(Set<Long> recipeIds);

    boolean existsByCategoryCategoryId(Long categoryId);
}
