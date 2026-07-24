CREATE TABLE meal_plans (
    meal_plan_id BIGINT AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    nutrition_goal_id BIGINT NOT NULL,
    plan_date DATE NOT NULL,
    title VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL,
    match_score DECIMAL(10,2) NOT NULL,
    warnings_json JSON NOT NULL,
    created_at TIMESTAMP(6) NOT NULL,
    updated_at TIMESTAMP(6) NOT NULL,
    PRIMARY KEY (meal_plan_id),
    CONSTRAINT ck_meal_plans_status CHECK (status IN ('DRAFT','FINALIZED')),
    CONSTRAINT fk_meal_plans_user_id FOREIGN KEY (user_id) REFERENCES users (user_id),
    CONSTRAINT fk_meal_plans_nutrition_goal_id FOREIGN KEY (nutrition_goal_id) REFERENCES nutrition_goals (goal_id)
);

CREATE INDEX idx_meal_plans_user_date ON meal_plans (user_id, plan_date);
CREATE INDEX idx_meal_plans_goal_id ON meal_plans (nutrition_goal_id);

CREATE TABLE meal_plan_entries (
    entry_id BIGINT AUTO_INCREMENT,
    meal_plan_id BIGINT NOT NULL,
    recipe_id BIGINT NOT NULL,
    meal_type VARCHAR(20) NOT NULL,
    scheduled_time TIME NOT NULL,
    recipe_name VARCHAR(255) NOT NULL,
    calories INT NOT NULL,
    protein INT NOT NULL,
    carbs INT NOT NULL,
    fat INT NOT NULL,
    image_url TEXT,
    suitability_score DECIMAL(10,2) NOT NULL,
    reason TEXT,
    warnings_json JSON NOT NULL,
    manually_swapped BOOLEAN NOT NULL,
    PRIMARY KEY (entry_id),
    CONSTRAINT ck_meal_plan_entries_meal_type CHECK (meal_type IN ('BREAKFAST','LUNCH','DINNER','SNACK')),
    CONSTRAINT fk_meal_plan_entries_plan_id FOREIGN KEY (meal_plan_id) REFERENCES meal_plans (meal_plan_id)
);

CREATE INDEX idx_meal_plan_entries_plan_id ON meal_plan_entries (meal_plan_id);
CREATE INDEX idx_meal_plan_entries_recipe_id ON meal_plan_entries (recipe_id);
