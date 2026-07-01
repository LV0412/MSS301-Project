package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateFavoriteRequest;
import com.mss301.userservice.dto.FavoriteResponse;
import com.mss301.userservice.dto.UpdateFavoriteRequest;
import com.mss301.userservice.service.FavoriteService;
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
@RequestMapping("/api/v1/users/{userId}/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;

    @PostMapping
    public ResponseEntity<FavoriteResponse> addFavorite(
            @PathVariable Long userId,
            @Valid @RequestBody CreateFavoriteRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(favoriteService.addFavorite(userId, request));
    }

    @GetMapping
    public ResponseEntity<List<FavoriteResponse>> getFavorites(@PathVariable Long userId) {
        return ResponseEntity.ok(favoriteService.getFavorites(userId));
    }

    @PutMapping("/{favoriteId}")
    public ResponseEntity<FavoriteResponse> updateFavorite(
            @PathVariable Long userId,
            @PathVariable Long favoriteId,
            @Valid @RequestBody UpdateFavoriteRequest request) {
        return ResponseEntity.ok(favoriteService.updateFavorite(userId, favoriteId, request));
    }

    @DeleteMapping("/{favoriteId}")
    public ResponseEntity<Void> deleteFavorite(
            @PathVariable Long userId,
            @PathVariable Long favoriteId) {
        favoriteService.deleteFavorite(userId, favoriteId);
        return ResponseEntity.noContent().build();
    }
}
