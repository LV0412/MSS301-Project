package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateFavoriteRequest;
import com.mss301.userservice.dto.FavoriteResponse;
import com.mss301.userservice.dto.UpdateFavoriteRequest;
import java.util.List;

public interface FavoriteService {

    FavoriteResponse addFavorite(Long userId, CreateFavoriteRequest request);

    List<FavoriteResponse> getFavorites(Long userId);

    FavoriteResponse updateFavorite(Long userId, Long favoriteId, UpdateFavoriteRequest request);

    void deleteFavorite(Long userId, Long favoriteId);
}
