package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateFoodLogRequest;
import com.mss301.userservice.dto.FoodLogResponse;
import com.mss301.userservice.dto.UpdateFoodLogRequest;
import com.mss301.userservice.entity.MealType;
import com.mss301.userservice.service.FoodLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.time.LocalDate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users/{userId}/food-logs")
@RequiredArgsConstructor
@Tag(name = "Food Logs", description = "User food log APIs")
public class FoodLogController {

    private final FoodLogService foodLogService;

    @PostMapping
    @Operation(summary = "Create food log", description = "Create a food log entry for a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Food log created"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<FoodLogResponse> createFoodLog(
            @PathVariable Long userId,
            @Valid @RequestBody CreateFoodLogRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(foodLogService.createFoodLog(userId, request));
    }

    @GetMapping
    @Operation(summary = "Get food log history", description = "Return paginated food logs with optional date and meal type filters.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Food logs returned"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<Page<FoodLogResponse>> getFoodLogHistory(
            @PathVariable Long userId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(required = false) MealType mealType,
            @PageableDefault(size = 20, sort = "logDate") Pageable pageable) {
        return ResponseEntity.ok(foodLogService.getFoodLogHistory(userId, date, mealType, pageable));
    }

    @PutMapping("/{logId}")
    @Operation(summary = "Update food log", description = "Update one food log entry.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Food log updated"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Food log not found")
    })
    public ResponseEntity<FoodLogResponse> updateFoodLog(
            @PathVariable Long userId,
            @PathVariable Long logId,
            @Valid @RequestBody UpdateFoodLogRequest request) {
        return ResponseEntity.ok(foodLogService.updateFoodLog(userId, logId, request));
    }

    @DeleteMapping("/{logId}")
    @Operation(summary = "Delete food log", description = "Delete one food log entry.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Food log deleted"),
            @ApiResponse(responseCode = "404", description = "Food log not found")
    })
    public ResponseEntity<Void> deleteFoodLog(
            @PathVariable Long userId,
            @PathVariable Long logId) {
        foodLogService.deleteFoodLog(userId, logId);
        return ResponseEntity.noContent().build();
    }
}
