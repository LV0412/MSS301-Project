package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateHealthProfileRequest;
import com.mss301.userservice.dto.HealthProfileResponse;
import com.mss301.userservice.dto.UpdateHealthProfileRequest;
import com.mss301.userservice.service.HealthProfileService;
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
public class HealthProfileController {

    private final HealthProfileService healthProfileService;

    @PostMapping
    public ResponseEntity<HealthProfileResponse> createHealthProfile(
            @PathVariable Long userId,
            @Valid @RequestBody CreateHealthProfileRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(healthProfileService.createHealthProfile(userId, request));
    }

    @GetMapping
    public ResponseEntity<HealthProfileResponse> getHealthProfile(@PathVariable Long userId) {
        return ResponseEntity.ok(healthProfileService.getHealthProfile(userId));
    }

    @PutMapping
    public ResponseEntity<HealthProfileResponse> updateHealthProfile(
            @PathVariable Long userId,
            @Valid @RequestBody UpdateHealthProfileRequest request) {
        return ResponseEntity.ok(healthProfileService.updateHealthProfile(userId, request));
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteHealthProfile(@PathVariable Long userId) {
        healthProfileService.deleteHealthProfile(userId);
        return ResponseEntity.noContent().build();
    }
}
