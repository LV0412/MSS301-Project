package com.mss301.recipeservice.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "nutrition_info")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "nutrition_id")
    private Long nutritionId;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recipe_id", nullable = false, unique = true)
    private Recipe recipe;

    @Column(name = "serving_size_grams", nullable = false, precision = 10, scale = 2)
    private BigDecimal servingSizeGrams;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal calories;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal protein;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal fat;

    @Column(name = "saturated_fat", nullable = false, precision = 10, scale = 2)
    private BigDecimal saturatedFat;

    @Column(name = "trans_fat", nullable = false, precision = 10, scale = 2)
    private BigDecimal transFat;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal cholesterol;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal carbs;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal fiber;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal sugar;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal sodium;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal potassium;

    @Column(name = "vitamin_a", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminA;

    @Column(name = "vitamin_d", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminD;

    @Column(name = "vitamin_e", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminE;

    @Column(name = "vitamin_k", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminK;

    @Column(name = "vitamin_b1", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminB1;

    @Column(name = "vitamin_b2", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminB2;

    @Column(name = "vitamin_b3", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminB3;

    @Column(name = "vitamin_b6", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminB6;

    @Column(name = "vitamin_b9", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminB9;

    @Column(name = "vitamin_b12", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminB12;

    @Column(name = "vitamin_c", nullable = false, precision = 10, scale = 2)
    private BigDecimal vitaminC;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal calcium;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal iron;
}
