package com.mss301.userservice.infrastructure.repositories;

import com.mss301.userservice.domain.Favorite;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    List<Favorite> findAllByUserUserId(Long userId);

    Optional<Favorite> findByFavoriteIdAndUserUserId(Long favoriteId, Long userId);

    Optional<Favorite> findByUserUserIdAndRecipeId(Long userId, Long recipeId);
}
