package com.mss301.userservice.controller;

import com.mss301.userservice.dto.CreateFavoriteRequest;
import com.mss301.userservice.dto.FavoriteResponse;
import com.mss301.userservice.dto.UpdateFavoriteRequest;
import com.mss301.userservice.service.FavoriteService;
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
@RequestMapping({"/api/v1/users/me/favorites", "/api/v1/users/{userId:\\d+}/favorites"})
@RequiredArgsConstructor
@Tag(name = "Favorites", description = "User favorite recipe APIs")
public class FavoriteController {

    private final FavoriteService favoriteService;

    @PostMapping
    @Operation(summary = "Add favorite", description = "Add a recipe to a user's favorites.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Favorite added"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "409", description = "Duplicate favorite")
    })
    public ResponseEntity<FavoriteResponse> addFavorite(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @Valid @RequestBody CreateFavoriteRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(favoriteService.addFavorite(authenticatedUserId, request));
    }

    @GetMapping
    @Operation(summary = "Get favorites", description = "Return all favorite recipes of a user.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Favorites returned"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<List<FavoriteResponse>> getFavorites(
            @RequestHeader("X-User-Id") Long authenticatedUserId) {
        return ResponseEntity.ok(favoriteService.getFavorites(authenticatedUserId));
    }

    @PutMapping("/{favoriteId}")
    @Operation(summary = "Update favorite", description = "Update a favorite recipe record.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Favorite updated"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Favorite not found")
    })
    public ResponseEntity<FavoriteResponse> updateFavorite(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @PathVariable Long favoriteId,
            @Valid @RequestBody UpdateFavoriteRequest request) {
        return ResponseEntity.ok(favoriteService.updateFavorite(authenticatedUserId, favoriteId, request));
    }

    @DeleteMapping("/{favoriteId}")
    @Operation(summary = "Delete favorite", description = "Delete one favorite recipe record.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Favorite deleted"),
            @ApiResponse(responseCode = "404", description = "Favorite not found")
    })
    public ResponseEntity<Void> deleteFavorite(
            @RequestHeader("X-User-Id") Long authenticatedUserId,
            @PathVariable Long favoriteId) {
        favoriteService.deleteFavorite(authenticatedUserId, favoriteId);
        return ResponseEntity.noContent().build();
    }
}
