ALTER TABLE meal_plans
    ADD COLUMN nutrition_goal_version INT NOT NULL DEFAULT 1,
    ADD COLUMN finalized_at TIMESTAMP(6);

ALTER TABLE meal_plans
    DROP CHECK ck_meal_plans_status,
    ADD CONSTRAINT ck_meal_plans_status CHECK (status IN ('DRAFT','FINALIZED','OUTDATED'));

ALTER TABLE meal_plans
    MODIFY COLUMN warnings_json TEXT NOT NULL;

ALTER TABLE meal_plan_entries
    ADD COLUMN target_calories_for_slot INT;

ALTER TABLE meal_plan_entries RENAME COLUMN calories TO actual_calories;
ALTER TABLE meal_plan_entries RENAME COLUMN protein TO actual_protein;
ALTER TABLE meal_plan_entries RENAME COLUMN carbs TO actual_carbs;
ALTER TABLE meal_plan_entries RENAME COLUMN fat TO actual_fat;

ALTER TABLE meal_plan_entries
    MODIFY COLUMN warnings_json TEXT NOT NULL;
