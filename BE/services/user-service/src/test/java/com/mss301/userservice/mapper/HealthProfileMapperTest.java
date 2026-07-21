package com.mss301.userservice.mapper;

import static org.assertj.core.api.Assertions.assertThat;

import com.mss301.userservice.dto.CreateHealthProfileRequest;
import com.mss301.userservice.entity.ActivityLevel;
import com.mss301.userservice.entity.HealthProfile;
import com.mss301.userservice.entity.User;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class HealthProfileMapperTest {

    private final HealthProfileMapper mapper = new HealthProfileMapper();

    @Test
    void toEntityCalculatesBmiUsingWeightDividedByHeightInMetersSquared() {
        User user = User.builder().userId(7L).build();
        CreateHealthProfileRequest request = new CreateHealthProfileRequest(
                BigDecimal.valueOf(175),
                BigDecimal.valueOf(70),
                ActivityLevel.MODERATE);

        HealthProfile healthProfile = mapper.toEntity(request, user);

        assertThat(healthProfile.getBmi()).isEqualByComparingTo("22.86");
    }
}
