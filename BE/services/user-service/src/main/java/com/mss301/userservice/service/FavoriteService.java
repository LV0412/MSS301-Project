package com.mss301.userservice.service;

import com.mss301.userservice.client.RecipeCatalogReferenceValidator;
import com.mss301.userservice.dto.CreateFavoriteRequest;
import com.mss301.userservice.dto.FavoriteResponse;
import com.mss301.userservice.dto.UpdateFavoriteRequest;
import com.mss301.userservice.entity.Favorite;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.DuplicateFavoriteException;
import com.mss301.userservice.exception.FavoriteNotFoundException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.FavoriteRepository;
import com.mss301.userservice.repository.UserRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final RecipeCatalogReferenceValidator recipeCatalogReferenceValidator;

    public FavoriteResponse addFavorite(Long userId, CreateFavoriteRequest request) {
        User user = findUser(userId);
        ensureRecipeIsAvailable(userId, request.recipeId(), null);
        recipeCatalogReferenceValidator.requireRecipeExists(request.recipeId());

        Favorite favorite = Favorite.builder()
                .user(user)
                .recipeId(request.recipeId())
                .build();

        return toResponse(favoriteRepository.save(favorite));
    }

    @Transactional(readOnly = true)
    public List<FavoriteResponse> getFavorites(Long userId) {
        findUser(userId);
        return favoriteRepository.findAllByUserUserId(userId).stream()
                .map(this::toResponse)
                .toList();
    }

    public FavoriteResponse updateFavorite(Long userId, Long favoriteId, UpdateFavoriteRequest request) {
        Favorite favorite = findFavorite(userId, favoriteId);
        ensureRecipeIsAvailable(userId, request.recipeId(), favoriteId);
        recipeCatalogReferenceValidator.requireRecipeExists(request.recipeId());

        favorite.setRecipeId(request.recipeId());
        return toResponse(favoriteRepository.save(favorite));
    }

    public void deleteFavorite(Long userId, Long favoriteId) {
        Favorite favorite = findFavorite(userId, favoriteId);
        favoriteRepository.delete(favorite);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private Favorite findFavorite(Long userId, Long favoriteId) {
        return favoriteRepository.findByFavoriteIdAndUserUserId(favoriteId, userId)
                .orElseThrow(() -> new FavoriteNotFoundException(favoriteId, userId));
    }

    private void ensureRecipeIsAvailable(Long userId, Long recipeId, Long currentFavoriteId) {
        favoriteRepository.findByUserUserIdAndRecipeId(userId, recipeId)
                .filter(existing -> !existing.getFavoriteId().equals(currentFavoriteId))
                .ifPresent(existing -> {
                    throw new DuplicateFavoriteException(userId, recipeId);
                });
    }

    private FavoriteResponse toResponse(Favorite favorite) {
        return FavoriteResponse.builder()
                .favoriteId(favorite.getFavoriteId())
                .userId(favorite.getUser().getUserId())
                .recipeId(favorite.getRecipeId())
                .build();
    }
}
