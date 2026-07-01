package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateUserAllergyRequest;
import com.mss301.userservice.dto.UpdateUserAllergyRequest;
import com.mss301.userservice.dto.UserAllergyResponse;
import com.mss301.userservice.service.UserAllergyService;
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
@RequestMapping("/api/v1/users/{userId}/allergies")
@RequiredArgsConstructor
public class UserAllergyController {

    private final UserAllergyService userAllergyService;

    @PostMapping
    public ResponseEntity<UserAllergyResponse> addAllergy(
            @PathVariable Long userId,
            @Valid @RequestBody CreateUserAllergyRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(userAllergyService.addAllergy(userId, request));
    }

    @GetMapping
    public ResponseEntity<List<UserAllergyResponse>> getAllergies(@PathVariable Long userId) {
        return ResponseEntity.ok(userAllergyService.getAllergies(userId));
    }

    @PutMapping("/{allergyId}")
    public ResponseEntity<UserAllergyResponse> updateAllergy(
            @PathVariable Long userId,
            @PathVariable Long allergyId,
            @Valid @RequestBody UpdateUserAllergyRequest request) {
        return ResponseEntity.ok(userAllergyService.updateAllergy(userId, allergyId, request));
    }

    @DeleteMapping("/{allergyId}")
    public ResponseEntity<Void> deleteAllergy(
            @PathVariable Long userId,
            @PathVariable Long allergyId) {
        userAllergyService.deleteAllergy(userId, allergyId);
        return ResponseEntity.noContent().build();
    }
}
