package com.mss301.userservice.dto;

import static org.assertj.core.api.Assertions.assertThat;

import com.mss301.userservice.entity.ActivityLevel;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class HealthProfileRequestValidationTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void createHealthProfileAcceptsRealisticHeightAndWeightRanges() {
        CreateHealthProfileRequest request = new CreateHealthProfileRequest(
                BigDecimal.valueOf(50),
                BigDecimal.valueOf(10),
                ActivityLevel.MODERATE);

        assertThat(validator.validate(request)).isEmpty();
    }

    @Test
    void createHealthProfileRejectsUnrealisticHeightAndWeightRanges() {
        CreateHealthProfileRequest request = new CreateHealthProfileRequest(
                BigDecimal.valueOf(49.99),
                BigDecimal.valueOf(300.01),
                ActivityLevel.MODERATE);

        assertThat(validator.validate(request))
                .extracting(violation -> violation.getPropertyPath().toString())
                .containsExactlyInAnyOrder("height", "weight");
    }
}
