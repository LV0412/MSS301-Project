ALTER TABLE health_profiles
    ADD COLUMN created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ADD COLUMN updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6);

ALTER TABLE nutrition_goals
    ADD COLUMN status ENUM('CURRENT', 'OUTDATED') NOT NULL DEFAULT 'CURRENT',
    ADD COLUMN outdated_reason ENUM('HEALTH_PROFILE_CHANGED') DEFAULT NULL,
    ADD COLUMN calculated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ADD CONSTRAINT chk_nutrition_goal_freshness
        CHECK (
            (status = 'CURRENT' AND outdated_reason IS NULL)
            OR (status = 'OUTDATED' AND outdated_reason IS NOT NULL)
        );

-- Legacy rows have no historical profile/goal timestamps, so their freshness
-- cannot be proven. Mark configured goals outdated instead of falsely current.
UPDATE nutrition_goals
SET status = 'OUTDATED',
    outdated_reason = 'HEALTH_PROFILE_CHANGED'
WHERE goal_configured = TRUE;
