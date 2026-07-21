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
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "nutrition_goals")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionGoal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "goal_id")
    private Long goalId;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "goal_type", nullable = false, length = 20)
    private GoalType goalType;

    @Column(name = "target_weight", nullable = false, precision = 5, scale = 2)
    private BigDecimal targetWeight;

    @Column(name = "duration_weeks", nullable = false)
    private Integer durationWeeks;

    @Column(name = "weekly_rate_kg", nullable = false, precision = 4, scale = 2)
    private BigDecimal weeklyRateKg;

    @Column(name = "recommended_calories", nullable = false, precision = 8, scale = 2)
    private BigDecimal recommendedCalories;

    @Column(name = "daily_calories_goal", nullable = false, precision = 8, scale = 2)
    private BigDecimal dailyCaloriesGoal;

    @Column(name = "protein", nullable = false, precision = 8, scale = 2)
    private BigDecimal protein;

    @Column(name = "carbs", nullable = false, precision = 8, scale = 2)
    private BigDecimal carbs;

    @Column(name = "fat", nullable = false, precision = 8, scale = 2)
    private BigDecimal fat;
}
