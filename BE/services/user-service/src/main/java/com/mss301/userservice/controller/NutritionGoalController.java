package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateNutritionGoalRequest;
import com.mss301.userservice.dto.NutritionGoalResponse;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/{userId}/nutrition-goal")
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
            @PathVariable Long userId,
            @Valid @RequestBody CreateNutritionGoalRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(nutritionGoalService.createNutritionGoal(userId, request));
    }

    @GetMapping
    @Operation(summary = "Get nutrition goal", description = "Return the nutrition goal of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Nutrition goal found"),
            @ApiResponse(responseCode = "404", description = "Nutrition goal not found")
    })
    public ResponseEntity<NutritionGoalResponse> getNutritionGoal(@PathVariable Long userId) {
        return ResponseEntity.ok(nutritionGoalService.getNutritionGoal(userId));
    }

    @PutMapping
    @Operation(summary = "Update nutrition goal", description = "Update the nutrition goal of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Nutrition goal updated"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Nutrition goal not found")
    })
    public ResponseEntity<NutritionGoalResponse> updateNutritionGoal(
            @PathVariable Long userId,
            @Valid @RequestBody UpdateNutritionGoalRequest request) {
        return ResponseEntity.ok(nutritionGoalService.updateNutritionGoal(userId, request));
    }

    @DeleteMapping
    @Operation(summary = "Delete nutrition goal", description = "Delete the nutrition goal of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Nutrition goal deleted"),
            @ApiResponse(responseCode = "404", description = "Nutrition goal not found")
    })
    public ResponseEntity<Void> deleteNutritionGoal(@PathVariable Long userId) {
        nutritionGoalService.deleteNutritionGoal(userId);
        return ResponseEntity.noContent().build();
    }
}
