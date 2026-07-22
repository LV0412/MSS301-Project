package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateDietPreferenceRequest;
import com.mss301.userservice.dto.DietPreferenceResponse;
import com.mss301.userservice.dto.UpdateDietPreferenceRequest;
import com.mss301.userservice.service.DietPreferenceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
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
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/me/diet-preferences")
@RequiredArgsConstructor
@Tag(name = "Diet Preferences", description = "User diet preference APIs")
public class DietPreferenceController {

    private final DietPreferenceService dietPreferenceService;

    @PostMapping
    @Operation(summary = "Add diet preference", description = "Add a diet preference for a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Diet preference added"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "409", description = "Duplicate diet preference")
    })
    public ResponseEntity<DietPreferenceResponse> addDietPreference(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @Valid @RequestBody CreateDietPreferenceRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(dietPreferenceService.addDietPreference(authenticatedUserId, request));
    }

    @GetMapping
    @Operation(summary = "Get diet preferences", description = "Return all diet preferences of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Diet preferences returned"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<List<DietPreferenceResponse>> getDietPreferences(
            @RequestHeader("X-User-Id") Long authenticatedUserId) {
        return ResponseEntity.ok(dietPreferenceService.getDietPreferences(authenticatedUserId));
    }

    @PutMapping("/{preferenceId}")
    @Operation(summary = "Update diet preference", description = "Update one diet preference of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Diet preference updated"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Diet preference not found")
    })
    public ResponseEntity<DietPreferenceResponse> updateDietPreference(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @PathVariable Long preferenceId,
            @Valid @RequestBody UpdateDietPreferenceRequest request) {
        return ResponseEntity.ok(dietPreferenceService.updateDietPreference(authenticatedUserId, preferenceId, request));
    }

    @DeleteMapping("/{preferenceId}")
    @Operation(summary = "Delete diet preference", description = "Delete one diet preference of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Diet preference deleted"),
            @ApiResponse(responseCode = "404", description = "Diet preference not found")
    })
    public ResponseEntity<Void> deleteDietPreference(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @PathVariable Long preferenceId) {
        dietPreferenceService.deleteDietPreference(authenticatedUserId, preferenceId);
        return ResponseEntity.noContent().build();
    }
}
