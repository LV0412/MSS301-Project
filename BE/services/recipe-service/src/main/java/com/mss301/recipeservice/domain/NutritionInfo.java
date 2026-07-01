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

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal calories;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal protein;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal fat;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal carbs;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal fiber;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal sugar;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal sodium;
}
