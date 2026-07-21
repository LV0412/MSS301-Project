package com.mss301.userservice.exception;

import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(
            UserNotFoundException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.NOT_FOUND, exception.getMessage(), request, null);
    }

    @ExceptionHandler(HealthProfileNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleHealthProfileNotFound(
            HealthProfileNotFoundException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.NOT_FOUND, exception.getMessage(), request, null);
    }

    @ExceptionHandler(NutritionGoalNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNutritionGoalNotFound(
            NutritionGoalNotFoundException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.NOT_FOUND, exception.getMessage(), request, null);
    }

    @ExceptionHandler(DietPreferenceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleDietPreferenceNotFound(
            DietPreferenceNotFoundException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.NOT_FOUND, exception.getMessage(), request, null);
    }

    @ExceptionHandler(UserAllergyNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserAllergyNotFound(
            UserAllergyNotFoundException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.NOT_FOUND, exception.getMessage(), request, null);
    }

    @ExceptionHandler(FavoriteNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleFavoriteNotFound(
            FavoriteNotFoundException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.NOT_FOUND, exception.getMessage(), request, null);
    }

    @ExceptionHandler(FoodLogNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleFoodLogNotFound(
            FoodLogNotFoundException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.NOT_FOUND, exception.getMessage(), request, null);
    }

    @ExceptionHandler(DuplicateEmailException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateEmail(
            DuplicateEmailException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.CONFLICT, exception.getMessage(), request, null);
    }

    @ExceptionHandler(HealthProfileAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleHealthProfileAlreadyExists(
            HealthProfileAlreadyExistsException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.CONFLICT, exception.getMessage(), request, null);
    }

    @ExceptionHandler(NutritionGoalAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleNutritionGoalAlreadyExists(
            NutritionGoalAlreadyExistsException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.CONFLICT, exception.getMessage(), request, null);
    }

    @ExceptionHandler(DuplicateDietPreferenceException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateDietPreference(
            DuplicateDietPreferenceException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.CONFLICT, exception.getMessage(), request, null);
    }

    @ExceptionHandler(DuplicateUserAllergyException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateUserAllergy(
            DuplicateUserAllergyException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.CONFLICT, exception.getMessage(), request, null);
    }

    @ExceptionHandler(DuplicateFavoriteException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateFavorite(
            DuplicateFavoriteException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.CONFLICT, exception.getMessage(), request, null);
    }

    @ExceptionHandler({InvalidRecipeReferenceException.class, InvalidAllergenReferenceException.class})
    public ResponseEntity<ErrorResponse> handleInvalidCatalogReference(
            RuntimeException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.UNPROCESSABLE_ENTITY, exception.getMessage(), request, null);
    }

    @ExceptionHandler(RecipeCatalogUnavailableException.class)
    public ResponseEntity<ErrorResponse> handleRecipeCatalogUnavailable(
            RecipeCatalogUnavailableException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.SERVICE_UNAVAILABLE, exception.getMessage(), request, null);
    }

    @ExceptionHandler(InvalidDateOfBirthException.class)
    public ResponseEntity<ErrorResponse> handleInvalidDateOfBirth(
            InvalidDateOfBirthException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.BAD_REQUEST, exception.getMessage(), request, null);
    }

    @ExceptionHandler(InvalidNutritionGoalException.class)
    public ResponseEntity<ErrorResponse> handleInvalidNutritionGoal(
            InvalidNutritionGoalException exception,
            HttpServletRequest request) {
        return buildErrorResponse(HttpStatus.BAD_REQUEST, exception.getMessage(), request, null);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
            MethodArgumentNotValidException exception,
            HttpServletRequest request) {
        Map<String, String> validationErrors = new LinkedHashMap<>();
        exception.getBindingResult().getFieldErrors()
                .forEach(error -> validationErrors.put(error.getField(), error.getDefaultMessage()));

        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "Request validation failed",
                request,
                validationErrors);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleTypeMismatch(
            MethodArgumentTypeMismatchException exception,
            HttpServletRequest request) {
        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "Invalid value for parameter: " + exception.getName(),
                request,
                null);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleMessageNotReadable(
            HttpMessageNotReadableException exception,
            HttpServletRequest request) {
        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "Malformed request body or invalid enum value",
                request,
                null);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrityViolation(
            DataIntegrityViolationException exception,
            HttpServletRequest request) {
        return buildErrorResponse(
                HttpStatus.CONFLICT,
                "Data integrity violation",
                request,
                null);
    }

    private ResponseEntity<ErrorResponse> buildErrorResponse(
            HttpStatus status,
            String message,
            HttpServletRequest request,
            Map<String, String> validationErrors) {
        ErrorResponse body = ErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(status.value())
                .error(status.getReasonPhrase())
                .message(message)
                .path(request.getRequestURI())
                .validationErrors(validationErrors)
                .build();

        return ResponseEntity.status(status).body(body);
    }
}
