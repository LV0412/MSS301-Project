package com.mss301.userservice.service;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.mss301.userservice.client.RecipeCatalogReferenceValidator;
import com.mss301.userservice.dto.CreateFavoriteRequest;
import com.mss301.userservice.entity.Favorite;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.InvalidRecipeReferenceException;
import com.mss301.userservice.repository.FavoriteRepository;
import com.mss301.userservice.repository.UserRepository;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class FavoriteServiceTest {

    @Mock
    private FavoriteRepository favoriteRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private RecipeCatalogReferenceValidator recipeCatalogReferenceValidator;

    @InjectMocks
    private FavoriteService favoriteService;

    @Test
    void addFavoriteVerifiesRecipeBeforeSaving() {
        Long userId = 7L;
        Long recipeId = 42L;
        User user = User.builder().userId(userId).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(favoriteRepository.findByUserUserIdAndRecipeId(userId, recipeId)).thenReturn(Optional.empty());
        when(favoriteRepository.save(any(Favorite.class))).thenAnswer(invocation -> {
            Favorite favorite = invocation.getArgument(0);
            favorite.setFavoriteId(1L);
            return favorite;
        });

        favoriteService.addFavorite(userId, new CreateFavoriteRequest(recipeId));

        InOrder ordered = inOrder(favoriteRepository, recipeCatalogReferenceValidator);
        ordered.verify(favoriteRepository).findByUserUserIdAndRecipeId(userId, recipeId);
        ordered.verify(recipeCatalogReferenceValidator).requireRecipeExists(recipeId);
        verify(favoriteRepository).save(any(Favorite.class));
    }

    @Test
    void addFavoriteDoesNotSaveWhenRecipeDoesNotExist() {
        Long userId = 7L;
        Long recipeId = 404L;
        User user = User.builder().userId(userId).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(favoriteRepository.findByUserUserIdAndRecipeId(userId, recipeId)).thenReturn(Optional.empty());
        doThrow(new InvalidRecipeReferenceException(recipeId))
                .when(recipeCatalogReferenceValidator).requireRecipeExists(recipeId);

        assertThatThrownBy(() -> favoriteService.addFavorite(userId, new CreateFavoriteRequest(recipeId)))
                .isInstanceOf(InvalidRecipeReferenceException.class);

        verify(favoriteRepository, never()).save(any(Favorite.class));
    }
}
