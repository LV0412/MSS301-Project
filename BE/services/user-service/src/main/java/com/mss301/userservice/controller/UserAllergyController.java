package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateUserAllergyRequest;
import com.mss301.userservice.dto.UpdateUserAllergyRequest;
import com.mss301.userservice.dto.UserAllergyResponse;
import com.mss301.userservice.service.UserAllergyService;
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
@RequestMapping("/api/v1/users/me/allergies")
@RequiredArgsConstructor
@Tag(name = "User Allergies", description = "User allergy APIs")
public class UserAllergyController {

    private final UserAllergyService userAllergyService;

    @PostMapping
    @Operation(summary = "Add allergy", description = "Add an allergy record for a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Allergy added"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "409", description = "Duplicate allergy")
    })
    public ResponseEntity<UserAllergyResponse> addAllergy(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @Valid @RequestBody CreateUserAllergyRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(userAllergyService.addAllergy(authenticatedUserId, request));
    }

    @GetMapping
    @Operation(summary = "Get allergies", description = "Return all allergies of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Allergies returned"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<List<UserAllergyResponse>> getAllergies(
            @RequestHeader("X-User-Id") Long authenticatedUserId) {
        return ResponseEntity.ok(userAllergyService.getAllergies(authenticatedUserId));
    }

    @PutMapping("/{allergyId}")
    @Operation(summary = "Update allergy", description = "Update one allergy record of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Allergy updated"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Allergy not found")
    })
    public ResponseEntity<UserAllergyResponse> updateAllergy(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @PathVariable Long allergyId,
            @Valid @RequestBody UpdateUserAllergyRequest request) {
        return ResponseEntity.ok(userAllergyService.updateAllergy(authenticatedUserId, allergyId, request));
    }

    @DeleteMapping("/{allergyId}")
    @Operation(summary = "Delete allergy", description = "Delete one allergy record of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Allergy deleted"),
            @ApiResponse(responseCode = "404", description = "Allergy not found")
    })
    public ResponseEntity<Void> deleteAllergy(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @PathVariable Long allergyId) {
        userAllergyService.deleteAllergy(authenticatedUserId, allergyId);
        return ResponseEntity.noContent().build();
    }
}
