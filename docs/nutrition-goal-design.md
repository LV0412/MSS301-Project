# Nutrition Goal Design

## API state

- `GET /api/v1/users/me/nutrition-goal` always returns `200` for an authenticated user.
- A missing goal returns `goalConfigured: false`, nullable goal values, and an empty `warnings` list.
- `goalConfigured` is persisted and is the only source of truth for configured state.
- Configured goals expose `status: CURRENT | OUTDATED` and an optional `outdatedReason`.
- Own-user endpoints use the trusted `X-User-Id` header injected by the gateway. They do not accept a user ID in the path, query, or request body.

## Legacy data

- Invalid legacy plans are normalized to `MAINTAIN` with `targetWeight`, `durationWeeks`, and `weeklyRateKg` set to `NULL`.
- Such migrated records have `goalConfigured: false`.
- A new MAINTAIN goal can use the same nullable plan fields while remaining configured because the state is stored separately.

## Calculation and reads

- BMR uses Mifflin-St Jeor and TDEE uses the configured activity factor.
- Weight change uses 7,700 kcal per kilogram.
- POST and PUT calculate and validate the recommendation before saving it.
- GET returns the saved recommendation and manual daily-calorie override.
- Changing weight, height, activity level, date of birth, or gender marks the saved goal `OUTDATED` with reason `HEALTH_PROFILE_CHANGED`. It never recalculates silently.
- Preview followed by PUT is the confirmation path; a successful PUT stores the recalculated values and restores `CURRENT`.
- Structurally invalid legacy data falls back to an unconfigured maintain response instead of failing the read.

## Validation

- Daily calories cannot be below BMR.
- LOSE_WEIGHT and GAIN_WEIGHT require 0.25-1.0 kg/week and the correct target direction.
- A supplied MAINTAIN target must be within ±1 kg of current weight (inclusive); plan fields are normalized after validation.
- Target BMI outside 16-35 is rejected.
- Target BMI from 16 to below 18.5, or above 30 through 35, is saved with a warning.
- Nutrition-goal validation errors use `code: INVALID_NUTRITION_GOAL`.

## Frontend

- The UI checks `goalConfigured` before reading calorie or macro values.
- An unconfigured goal shows a setup CTA rather than zero or a hardcoded fallback.
- Weight-plan details are read-only in the current scope.
- Warnings remain visible in the Nutrition Goal profile section.
- Home Dashboard and Weekly Analysis show an update banner for an outdated goal.
- AI recommendation ignores calories and macros from an outdated goal while preserving constraints explicitly supplied in the request.

## Follow-up

TODO: Build a separate editable weight-plan flow for `goalType`, `targetWeight`, `durationWeeks`, `weeklyRateKg`, and an optional `dailyCaloriesGoal` override. The form must mirror backend safety rules without replacing backend validation.
