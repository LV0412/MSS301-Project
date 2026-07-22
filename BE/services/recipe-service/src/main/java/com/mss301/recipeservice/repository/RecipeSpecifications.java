package com.mss301.recipeservice.repository;

import com.mss301.recipeservice.dto.RecipeSearchCriteria;
import com.mss301.recipeservice.entity.Allergen;
import com.mss301.recipeservice.entity.Ingredient;
import com.mss301.recipeservice.entity.NutritionInfo;
import com.mss301.recipeservice.entity.Recipe;
import com.mss301.recipeservice.entity.RecipeIngredient;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import java.util.ArrayList;
import java.util.List;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

public final class RecipeSpecifications {

    private RecipeSpecifications() {
    }

    public static Specification<Recipe> matches(RecipeSearchCriteria criteria) {
        return (root, criteriaQuery, builder) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (StringUtils.hasText(criteria.query())) {
                String pattern = "%" + criteria.query().trim().toLowerCase() + "%";
                predicates.add(builder.or(
                        builder.like(builder.lower(root.get("title")), pattern),
                        builder.like(builder.lower(root.get("description")), pattern)));
            }
            if (criteria.categoryId() != null) {
                predicates.add(builder.equal(root.get("category").get("categoryId"), criteria.categoryId()));
            }
            if (criteria.ingredientIds() != null && !criteria.ingredientIds().isEmpty()) {
                Join<Recipe, RecipeIngredient> recipeIngredients = root.join("recipeIngredients");
                predicates.add(recipeIngredients.get("ingredient").get("ingredientId").in(criteria.ingredientIds()));
            }
            if (StringUtils.hasText(criteria.ingredient())) {
                Join<Recipe, RecipeIngredient> recipeIngredients = root.join("recipeIngredients");
                Join<RecipeIngredient, Ingredient> ingredient = recipeIngredients.join("ingredient");
                predicates.add(builder.like(
                        builder.lower(ingredient.get("name")),
                        "%" + criteria.ingredient().trim().toLowerCase() + "%"));
            }
            if (criteria.minCalories() != null || criteria.maxCalories() != null) {
                Join<Recipe, NutritionInfo> nutrition = root.join("nutrition", JoinType.INNER);
                if (criteria.minCalories() != null) {
                    predicates.add(builder.greaterThanOrEqualTo(nutrition.get("calories"), criteria.minCalories()));
                }
                if (criteria.maxCalories() != null) {
                    predicates.add(builder.lessThanOrEqualTo(nutrition.get("calories"), criteria.maxCalories()));
                }
            }
            if (criteria.dietType() != null) {
                predicates.add(builder.equal(root.join("dietTypes"), criteria.dietType()));
            }
            if (criteria.excludedAllergenIds() != null && !criteria.excludedAllergenIds().isEmpty()) {
                Subquery<Long> allergenicRecipeIds = criteriaQuery.subquery(Long.class);
                Root<RecipeIngredient> recipeIngredient = allergenicRecipeIds.from(RecipeIngredient.class);
                Join<RecipeIngredient, Ingredient> ingredient = recipeIngredient.join("ingredient");
                Join<Ingredient, Allergen> allergen = ingredient.join("allergens");
                allergenicRecipeIds.select(recipeIngredient.get("recipe").get("recipeId"))
                        .where(allergen.get("allergenId").in(criteria.excludedAllergenIds()));
                predicates.add(builder.not(root.get("recipeId").in(allergenicRecipeIds)));
            }

            criteriaQuery.distinct(true);
            return builder.and(predicates.toArray(Predicate[]::new));
        };
    }
}
