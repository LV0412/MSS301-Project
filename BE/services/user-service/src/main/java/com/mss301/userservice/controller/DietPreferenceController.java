package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateDietPreferenceRequest;
import com.mss301.userservice.dto.DietPreferenceResponse;
import com.mss301.userservice.dto.UpdateDietPreferenceRequest;
import com.mss301.userservice.service.DietPreferenceService;
import jakarta.validation.Valid;
import java.util.List;
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
@RequestMapping("/api/v1/users/{userId}/diet-preferences")
@RequiredArgsConstructor
public class DietPreferenceController {

    private final DietPreferenceService dietPreferenceService;

    @PostMapping
    public ResponseEntity<DietPreferenceResponse> addDietPreference(
            @PathVariable Long userId,
            @Valid @RequestBody CreateDietPreferenceRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(dietPreferenceService.addDietPreference(userId, request));
    }

    @GetMapping
    public ResponseEntity<List<DietPreferenceResponse>> getDietPreferences(@PathVariable Long userId) {
        return ResponseEntity.ok(dietPreferenceService.getDietPreferences(userId));
    }

    @PutMapping("/{preferenceId}")
    public ResponseEntity<DietPreferenceResponse> updateDietPreference(
            @PathVariable Long userId,
            @PathVariable Long preferenceId,
            @Valid @RequestBody UpdateDietPreferenceRequest request) {
        return ResponseEntity.ok(dietPreferenceService.updateDietPreference(userId, preferenceId, request));
    }

    @DeleteMapping("/{preferenceId}")
    public ResponseEntity<Void> deleteDietPreference(
            @PathVariable Long userId,
            @PathVariable Long preferenceId) {
        dietPreferenceService.deleteDietPreference(userId, preferenceId);
        return ResponseEntity.noContent().build();
    }
}
