package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateNutritionGoalRequest;
import com.mss301.userservice.dto.NutritionGoalResponse;
import com.mss301.userservice.dto.NutritionGoalPreviewResponse;
import com.mss301.userservice.dto.UpdateNutritionGoalRequest;
import com.mss301.userservice.service.NutritionGoalService;
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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/me/nutrition-goal")
@RequiredArgsConstructor
@Tag(name = "Nutrition Goals", description = "User nutrition goal APIs")
public class NutritionGoalController {

    private final NutritionGoalService nutritionGoalService;

    @PostMapping
    @Operation(summary = "Create nutrition goal", description = "Create a nutrition goal for a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Nutrition goal created"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "409", description = "Nutrition goal already exists")
    })
    public ResponseEntity<NutritionGoalResponse> createNutritionGoal(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @Valid @RequestBody CreateNutritionGoalRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(nutritionGoalService.createNutritionGoal(authenticatedUserId, request));
    }

    @GetMapping
    @Operation(summary = "Get nutrition goal", description = "Return the nutrition goal of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Nutrition goal state returned")
    })
    public ResponseEntity<NutritionGoalResponse> getNutritionGoal(
            @RequestHeader("X-User-Id") Long authenticatedUserId) {
        return ResponseEntity.ok(nutritionGoalService.getNutritionGoal(authenticatedUserId));
    }

    @PutMapping
    @Operation(summary = "Update nutrition goal", description = "Update the nutrition goal of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Nutrition goal updated"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Nutrition goal not found")
    })
    public ResponseEntity<NutritionGoalResponse> updateNutritionGoal(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @Valid @RequestBody UpdateNutritionGoalRequest request) {
        return ResponseEntity.ok(nutritionGoalService.updateNutritionGoal(authenticatedUserId, request));
    }

    @PostMapping("/preview")
    @Operation(summary = "Preview nutrition goal", description = "Calculate a nutrition goal without saving it.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Nutrition goal preview calculated"),
            @ApiResponse(responseCode = "400", description = "Invalid request or unsafe goal"),
            @ApiResponse(responseCode = "404", description = "User or health profile not found")
    })
    public ResponseEntity<NutritionGoalPreviewResponse> previewNutritionGoal(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @Valid @RequestBody UpdateNutritionGoalRequest request) {
        return ResponseEntity.ok(nutritionGoalService.previewNutritionGoal(authenticatedUserId, request));
    }

    @DeleteMapping
    @Operation(summary = "Delete nutrition goal", description = "Delete the nutrition goal of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Nutrition goal deleted"),
            @ApiResponse(responseCode = "404", description = "Nutrition goal not found")
    })
    public ResponseEntity<Void> deleteNutritionGoal(
            @RequestHeader("X-User-Id") Long authenticatedUserId) {
        nutritionGoalService.deleteNutritionGoal(authenticatedUserId);
        return ResponseEntity.noContent().build();
    }
}
