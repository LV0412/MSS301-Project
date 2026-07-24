package com.mss301.userservice.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "meal_plan_entries")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "entry_id")
    private Long entryId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "meal_plan_id", nullable = false)
    private MealPlan mealPlan;

    @Column(name = "recipe_id", nullable = false)
    private Long recipeId;

    @Enumerated(EnumType.STRING)
    @Column(name = "meal_type", nullable = false, length = 20)
    private MealType mealType;

    @Column(name = "scheduled_time", nullable = false)
    private LocalTime scheduledTime;

    @Column(name = "recipe_name", nullable = false)
    private String recipeName;

    @Column(name = "target_calories_for_slot")
    private Integer targetCaloriesForSlot;

    @Column(name = "actual_calories", nullable = false)
    private Integer actualCalories;

    @Column(name = "actual_protein", nullable = false)
    private Integer actualProtein;

    @Column(name = "actual_carbs", nullable = false)
    private Integer actualCarbs;

    @Column(name = "actual_fat", nullable = false)
    private Integer actualFat;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "suitability_score", nullable = false, precision = 10, scale = 2)
    private BigDecimal suitabilityScore;

    @Column(name = "reason")
    private String reason;

    @Column(name = "warnings_json", nullable = false, columnDefinition = "TEXT")
    private String warningsJson;

    @Column(name = "manually_swapped", nullable = false)
    private boolean manuallySwapped;
}
