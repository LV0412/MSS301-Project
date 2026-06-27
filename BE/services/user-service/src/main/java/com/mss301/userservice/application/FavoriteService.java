package com.mss301.userservice.application;

import com.mss301.userservice.api.dto.CreateFavoriteRequest;
import com.mss301.userservice.api.dto.FavoriteResponse;
import com.mss301.userservice.domain.Favorite;
import com.mss301.userservice.domain.User;
import com.mss301.userservice.exception.DuplicateFavoriteException;
import com.mss301.userservice.exception.FavoriteNotFoundException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.infrastructure.repositories.FavoriteRepository;
import com.mss301.userservice.infrastructure.repositories.UserRepository;
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

    public FavoriteResponse addFavorite(Long userId, CreateFavoriteRequest request) {
        User user = findUser(userId);
        ensureRecipeIsAvailable(userId, request.recipeId());

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

    public void deleteFavorite(Long userId, Long favoriteId) {
        Favorite favorite = favoriteRepository.findByFavoriteIdAndUserUserId(favoriteId, userId)
                .orElseThrow(() -> new FavoriteNotFoundException(favoriteId, userId));
        favoriteRepository.delete(favorite);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private void ensureRecipeIsAvailable(Long userId, Long recipeId) {
        if (favoriteRepository.existsByUserUserIdAndRecipeId(userId, recipeId)) {
            throw new DuplicateFavoriteException(userId, recipeId);
        }
    }

    private FavoriteResponse toResponse(Favorite favorite) {
        return FavoriteResponse.builder()
                .favoriteId(favorite.getFavoriteId())
                .userId(favorite.getUser().getUserId())
                .recipeId(favorite.getRecipeId())
                .build();
    }
}
