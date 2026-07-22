ALTER TABLE nutrition_goals
    ADD COLUMN goal_configured BOOLEAN NOT NULL DEFAULT TRUE AFTER weekly_rate_kg;

UPDATE nutrition_goals
SET goal_configured = FALSE
WHERE goal_type = 'MAINTAIN'
  AND target_weight IS NULL
  AND duration_weeks IS NULL
  AND weekly_rate_kg IS NULL;
