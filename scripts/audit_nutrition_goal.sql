SELECT
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'nutrition_goals'
  AND COLUMN_NAME = 'goal_configured';

SELECT version, description, success
FROM flyway_schema_history
ORDER BY installed_rank;

SELECT COUNT(*) AS invalid_weight_change_plans
FROM nutrition_goals
WHERE goal_type <> 'MAINTAIN'
  AND (
      target_weight IS NULL
      OR target_weight <= 0
      OR duration_weeks IS NULL
      OR duration_weeks <= 0
      OR weekly_rate_kg IS NULL
      OR weekly_rate_kg < 0
  );

SELECT goal_type, goal_configured, COUNT(*) AS records
FROM nutrition_goals
GROUP BY goal_type, goal_configured
ORDER BY goal_type, goal_configured;

SELECT u.user_id AS user_without_goal
FROM users u
LEFT JOIN nutrition_goals ng ON ng.user_id = u.user_id
WHERE ng.goal_id IS NULL
ORDER BY u.user_id
LIMIT 5;
