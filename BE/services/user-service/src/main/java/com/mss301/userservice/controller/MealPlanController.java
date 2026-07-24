package com.mss301.userservice.controller;

import com.mss301.userservice.dto.MealPlanResponse;
import com.mss301.userservice.dto.SwapMealPlanEntryRequest;
import com.mss301.userservice.service.MealPlanService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.time.LocalDate;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/me/meal-plans")
@RequiredArgsConstructor
@Tag(name = "Meal Plans", description = "User meal plan APIs backed by AI recommendation generation")
public class MealPlanController {

    private final MealPlanService mealPlanService;

    @PostMapping("/generate")
    @Operation(summary = "Generate meal plan", description = "Generate a draft meal plan through AI and store it for the user.")
    public ResponseEntity<MealPlanResponse> generateMealPlan(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(mealPlanService.generateMealPlan(authenticatedUserId, date));
    }

    @GetMapping
    @Operation(summary = "Get meal plan by date", description = "Return the user's meal plan for a date when it exists.")
    public ResponseEntity<MealPlanResponse> getMealPlan(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(mealPlanService.getMealPlan(authenticatedUserId, date));
    }

    @PutMapping("/{mealPlanId}/entries/{entryId}/swap")
    @Operation(summary = "Swap meal plan entry", description = "Swap one draft entry after AI hard-constraint validation.")
    public ResponseEntity<MealPlanResponse> swapEntry(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @PathVariable Long mealPlanId,
            @PathVariable Long entryId,
            @Valid @RequestBody SwapMealPlanEntryRequest request) {
        return ResponseEntity.ok(mealPlanService.swapEntry(authenticatedUserId, mealPlanId, entryId, request));
    }

    @PostMapping("/{mealPlanId}/finalize")
    @Operation(summary = "Finalize meal plan", description = "Finalize a draft meal plan so goal changes do not affect it.")
    public ResponseEntity<MealPlanResponse> finalizeMealPlan(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @PathVariable Long mealPlanId) {
        return ResponseEntity.ok(mealPlanService.finalizeMealPlan(authenticatedUserId, mealPlanId));
    }
}
