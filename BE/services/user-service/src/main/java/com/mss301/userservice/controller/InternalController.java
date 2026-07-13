package com.mss301.userservice.controller;

import com.mss301.userservice.dto.internal.InternalAiProfileResponse;
import com.mss301.userservice.dto.internal.InternalDietPreferenceResponse;
import com.mss301.userservice.dto.internal.InternalFoodLogResponse;
import com.mss301.userservice.dto.internal.InternalHealthProfileResponse;
import com.mss301.userservice.dto.internal.InternalHealthProfileStatusResponse;
import com.mss301.userservice.dto.internal.InternalNutritionGoalResponse;
import com.mss301.userservice.dto.internal.InternalUserAllergyResponse;
import com.mss301.userservice.dto.internal.InternalUserResponse;
import com.mss301.userservice.dto.internal.InternalUserProvisionRequest;
import com.mss301.userservice.dto.UserResponse;
import com.mss301.userservice.service.InternalUserService;
import com.mss301.userservice.service.UserManagementService;
import jakarta.validation.Valid;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/internal")
@RequiredArgsConstructor
@Tag(name = "Internal User APIs", description = "Read-only user data APIs for service-to-service usage")
public class InternalController {

    private final InternalUserService internalUserService;
    private final UserManagementService userManagementService;

    @PostMapping("/users/provision")
    @Operation(summary = "Provision user from auth account", description = "Idempotently link or create a user profile for an auth account.")
    @ApiResponse(responseCode = "200", description = "User profile linked or created")
    public UserResponse provisionUser(@Valid @RequestBody InternalUserProvisionRequest request) {
        return userManagementService.provisionFromAuth(request);
    }

    @GetMapping("/users/{userId}")
    @Operation(summary = "Get internal user profile", description = "Return minimal user profile for internal services.")
    @ApiResponse(responseCode = "200", description = "Internal user profile returned")
    public InternalUserResponse getUser(@PathVariable Long userId) {
        return internalUserService.getUser(userId);
    }

    @GetMapping("/health-profiles/{userId}")
    @Operation(summary = "Get internal health profile", description = "Return health profile data for internal services.")
    @ApiResponse(responseCode = "200", description = "Internal health profile returned")
    public InternalHealthProfileResponse getHealthProfile(@PathVariable Long userId) {
        return internalUserService.getHealthProfile(userId);
    }

    @GetMapping("/health-profiles/{userId}/status")
    @Operation(summary = "Get health profile status", description = "Return health profile completion status.")
    @ApiResponse(responseCode = "200", description = "Health profile status returned")
    public InternalHealthProfileStatusResponse getHealthProfileStatus(@PathVariable Long userId) {
        return internalUserService.getHealthProfileStatus(userId);
    }

    @GetMapping("/nutrition-goals/{userId}")
    @Operation(summary = "Get internal nutrition goal", description = "Return nutrition goal data for internal services.")
    @ApiResponse(responseCode = "200", description = "Internal nutrition goal returned")
    public InternalNutritionGoalResponse getNutritionGoal(@PathVariable Long userId) {
        return internalUserService.getNutritionGoal(userId);
    }

    @GetMapping("/diet-preferences/{userId}")
    @Operation(summary = "Get internal diet preferences", description = "Return diet preferences for internal services.")
    @ApiResponse(responseCode = "200", description = "Internal diet preferences returned")
    public List<InternalDietPreferenceResponse> getDietPreferences(@PathVariable Long userId) {
        return internalUserService.getDietPreferences(userId);
    }

    @GetMapping("/user-allergies/{userId}")
    @Operation(summary = "Get internal allergies", description = "Return user allergies for internal services.")
    @ApiResponse(responseCode = "200", description = "Internal allergies returned")
    public List<InternalUserAllergyResponse> getUserAllergies(@PathVariable Long userId) {
        return internalUserService.getUserAllergies(userId);
    }

    @GetMapping("/food-logs/{userId}")
    @Operation(summary = "Get internal food logs", description = "Return user food logs for internal services.")
    @ApiResponse(responseCode = "200", description = "Internal food logs returned")
    public List<InternalFoodLogResponse> getFoodLogs(@PathVariable Long userId) {
        return internalUserService.getFoodLogs(userId);
    }

    @GetMapping("/ai-profile/{userId}")
    @Operation(summary = "Get AI profile", description = "Return aggregated user profile data for AI services.")
    @ApiResponse(responseCode = "200", description = "AI profile returned")
    public InternalAiProfileResponse getAiProfile(@PathVariable Long userId) {
        return internalUserService.getAiProfile(userId);
    }
}
