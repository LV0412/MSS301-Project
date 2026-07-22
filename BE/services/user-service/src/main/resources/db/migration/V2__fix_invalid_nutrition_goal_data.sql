ALTER TABLE nutrition_goals
    MODIFY target_weight DECIMAL(5,2) NULL,
    MODIFY duration_weeks INT NULL,
    MODIFY weekly_rate_kg DECIMAL(4,2) NULL;

UPDATE nutrition_goals
SET goal_type = 'MAINTAIN',
    target_weight = NULL,
    duration_weeks = NULL,
    weekly_rate_kg = NULL
WHERE target_weight IS NULL
   OR target_weight <= 0
   OR duration_weeks IS NULL
   OR duration_weeks <= 0
   OR weekly_rate_kg IS NULL
   OR weekly_rate_kg < 0;

ALTER TABLE nutrition_goals
    DROP COLUMN calories;

ALTER TABLE nutrition_goals
    ADD CONSTRAINT chk_nutrition_goal_plan
        CHECK (
            (target_weight IS NULL OR target_weight > 0)
            AND (duration_weeks IS NULL OR duration_weeks > 0)
            AND (weekly_rate_kg IS NULL OR weekly_rate_kg >= 0)
            AND (
                goal_type = 'MAINTAIN'
                OR (
                    target_weight IS NOT NULL
                    AND duration_weeks IS NOT NULL
                    AND weekly_rate_kg IS NOT NULL
                )
            )
        );
