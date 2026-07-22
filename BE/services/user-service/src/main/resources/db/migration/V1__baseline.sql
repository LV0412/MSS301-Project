CREATE TABLE users (
    user_id BIGINT NOT NULL AUTO_INCREMENT,
    created_at DATETIME(6) NOT NULL,
    dob DATE DEFAULT NULL,
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    gender ENUM('MALE','FEMALE','OTHER') NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    updated_at DATETIME(6) NOT NULL,
    auth_account_id BIGINT DEFAULT NULL,
    PRIMARY KEY (user_id),
    UNIQUE KEY uk_users_email (email),
    UNIQUE KEY uk_users_auth_account_id (auth_account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE health_profiles (
    profile_id BIGINT NOT NULL AUTO_INCREMENT,
    activity_level ENUM('ACTIVE','LIGHT','MODERATE','SEDENTARY','VERY_ACTIVE') NOT NULL,
    bmi DECIMAL(5,2) NOT NULL,
    height DECIMAL(5,2) NOT NULL,
    weight DECIMAL(5,2) NOT NULL,
    user_id BIGINT NOT NULL,
    PRIMARY KEY (profile_id),
    UNIQUE KEY uk_health_profiles_user_id (user_id),
    CONSTRAINT fk_health_profiles_user_id FOREIGN KEY (user_id) REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE nutrition_goals (
    goal_id BIGINT NOT NULL AUTO_INCREMENT,
    calories DECIMAL(8,2) NOT NULL,
    carbs DECIMAL(8,2) NOT NULL,
    fat DECIMAL(8,2) NOT NULL,
    protein DECIMAL(8,2) NOT NULL,
    user_id BIGINT NOT NULL,
    daily_calories_goal DECIMAL(8,2) NOT NULL,
    duration_weeks INT NOT NULL,
    goal_type ENUM('GAIN_WEIGHT','LOSE_WEIGHT','MAINTAIN') NOT NULL,
    recommended_calories DECIMAL(8,2) NOT NULL,
    target_weight DECIMAL(5,2) NOT NULL,
    weekly_rate_kg DECIMAL(4,2) NOT NULL,
    PRIMARY KEY (goal_id),
    UNIQUE KEY uk_nutrition_goals_user_id (user_id),
    CONSTRAINT fk_nutrition_goals_user_id FOREIGN KEY (user_id) REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE diet_preferences (
    preference_id BIGINT NOT NULL AUTO_INCREMENT,
    diet_type VARCHAR(100) NOT NULL,
    user_id BIGINT NOT NULL,
    PRIMARY KEY (preference_id),
    UNIQUE KEY uk_diet_preferences_user_diet_type (user_id, diet_type),
    CONSTRAINT fk_diet_preferences_user_id FOREIGN KEY (user_id) REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE user_allergies (
    allergy_id BIGINT NOT NULL AUTO_INCREMENT,
    allergen_id BIGINT NOT NULL,
    severity ENUM('HIGH','LOW','MEDIUM') NOT NULL,
    user_id BIGINT NOT NULL,
    PRIMARY KEY (allergy_id),
    UNIQUE KEY uk_user_allergies_user_allergen (user_id, allergen_id),
    CONSTRAINT fk_user_allergies_user_id FOREIGN KEY (user_id) REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE favorites (
    favorite_id BIGINT NOT NULL AUTO_INCREMENT,
    recipe_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    PRIMARY KEY (favorite_id),
    UNIQUE KEY uk_favorites_user_recipe (user_id, recipe_id),
    CONSTRAINT fk_favorites_user_id FOREIGN KEY (user_id) REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE food_logs (
    log_id BIGINT NOT NULL AUTO_INCREMENT,
    log_date DATE NOT NULL,
    meal_type ENUM('BREAKFAST','DINNER','LUNCH','SNACK') NOT NULL,
    quantity DECIMAL(8,2) NOT NULL,
    recipe_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    PRIMARY KEY (log_id),
    KEY idx_food_logs_user_id (user_id),
    CONSTRAINT fk_food_logs_user_id FOREIGN KEY (user_id) REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
