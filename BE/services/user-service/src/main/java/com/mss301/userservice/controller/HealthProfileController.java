package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateHealthProfileRequest;
import com.mss301.userservice.dto.HealthProfileResponse;
import com.mss301.userservice.dto.UpdateHealthProfileRequest;
import com.mss301.userservice.service.HealthProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/{userId}/health-profile")
@RequiredArgsConstructor
@Tag(name = "Health Profiles", description = "User health profile APIs")
public class HealthProfileController {

    private final HealthProfileService healthProfileService;

    @PostMapping
    @Operation(summary = "Create health profile", description = "Create a health profile for a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Health profile created"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "409", description = "Health profile already exists")
    })
    public ResponseEntity<HealthProfileResponse> createHealthProfile(
            @PathVariable Long userId,
            @Valid @RequestBody CreateHealthProfileRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(healthProfileService.createHealthProfile(userId, request));
    }

    @GetMapping
    @Operation(summary = "Get health profile", description = "Return the health profile of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Health profile found"),
            @ApiResponse(responseCode = "404", description = "Health profile not found")
    })
    public ResponseEntity<HealthProfileResponse> getHealthProfile(@PathVariable Long userId) {
        return ResponseEntity.ok(healthProfileService.getHealthProfile(userId));
    }

    @PutMapping
    @Operation(summary = "Update health profile", description = "Update the health profile of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Health profile updated"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Health profile not found")
    })
    public ResponseEntity<HealthProfileResponse> updateHealthProfile(
            @PathVariable Long userId,
            @Valid @RequestBody UpdateHealthProfileRequest request) {
        return ResponseEntity.ok(healthProfileService.updateHealthProfile(userId, request));
    }

    @DeleteMapping
    @Operation(summary = "Delete health profile", description = "Delete the health profile of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Health profile deleted"),
            @ApiResponse(responseCode = "404", description = "Health profile not found")
    })
    public ResponseEntity<Void> deleteHealthProfile(@PathVariable Long userId) {
        healthProfileService.deleteHealthProfile(userId);
        return ResponseEntity.noContent().build();
    }
}
