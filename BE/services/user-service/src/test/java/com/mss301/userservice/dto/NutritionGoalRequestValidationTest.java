package com.mss301.userservice.dto;

import static org.assertj.core.api.Assertions.assertThat;

import com.mss301.userservice.entity.GoalType;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class NutritionGoalRequestValidationTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void createNutritionGoalRequiresWeightGoalPlanFields() {
        CreateNutritionGoalRequest request = new CreateNutritionGoalRequest(
                null,
                null,
                null,
                null,
                BigDecimal.valueOf(2000),
                BigDecimal.valueOf(120),
                BigDecimal.valueOf(250),
                BigDecimal.valueOf(70));

        assertThat(validator.validate(request))
                .extracting(violation -> violation.getPropertyPath().toString())
                .contains("goalType", "targetWeight", "durationWeeks", "weeklyRateKg");
    }

    @Test
    void createNutritionGoalRejectsUnrealisticWeightPlanRanges() {
        CreateNutritionGoalRequest request = new CreateNutritionGoalRequest(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(9.99),
                0,
                BigDecimal.valueOf(1.01),
                BigDecimal.valueOf(2000),
                BigDecimal.valueOf(120),
                BigDecimal.valueOf(250),
                BigDecimal.valueOf(70));

        assertThat(validator.validate(request))
                .extracting(violation -> violation.getPropertyPath().toString())
                .containsExactlyInAnyOrder("targetWeight", "durationWeeks", "weeklyRateKg");
    }
}
