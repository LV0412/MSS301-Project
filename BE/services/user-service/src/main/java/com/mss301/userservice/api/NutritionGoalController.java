package com.mss301.userservice.api;

import com.mss301.userservice.api.dto.CreateNutritionGoalRequest;
import com.mss301.userservice.api.dto.NutritionGoalResponse;
import com.mss301.userservice.api.dto.UpdateNutritionGoalRequest;
import com.mss301.userservice.application.NutritionGoalService;
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
public class NutritionGoalController {

    private final NutritionGoalService nutritionGoalService;

    @PostMapping
    public ResponseEntity<NutritionGoalResponse> createNutritionGoal(
            @PathVariable Long userId,
            @Valid @RequestBody CreateNutritionGoalRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(nutritionGoalService.createNutritionGoal(userId, request));
    }

    @GetMapping
    public ResponseEntity<NutritionGoalResponse> getNutritionGoal(@PathVariable Long userId) {
        return ResponseEntity.ok(nutritionGoalService.getNutritionGoal(userId));
    }

    @PutMapping
    public ResponseEntity<NutritionGoalResponse> updateNutritionGoal(
            @PathVariable Long userId,
            @Valid @RequestBody UpdateNutritionGoalRequest request) {
        return ResponseEntity.ok(nutritionGoalService.updateNutritionGoal(userId, request));
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteNutritionGoal(@PathVariable Long userId) {
        nutritionGoalService.deleteNutritionGoal(userId);
        return ResponseEntity.noContent().build();
    }
}
