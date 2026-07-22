#!/usr/bin/env bash

set -uo pipefail

FE_DIR="${1:-FE/FE_app}"
LIB_DIR="$FE_DIR/lib"

if [ ! -d "$LIB_DIR" ]; then
  echo "Flutter lib directory not found: $LIB_DIR"
  exit 1
fi

section() {
  printf '\n--- %s ---\n' "$1"
}

scan() {
  local pattern="$1"
  local result
  result=$(grep -rn -E "$pattern" "$LIB_DIR" --include='*.dart' 2>/dev/null || true)
  if [ -z "$result" ]; then
    echo "(none)"
  else
    echo "$result"
  fi
}

section "Nutrition goal legacy field access"
scan "nutritionGoal.*\['calories'\]|goal.*\['calories'\]"

section "Own-user routes containing userId"
scan "users/.*[Uu]serId"

section "Correct nutrition goal fields"
scan "dailyCaloriesGoal|recommendedCalories|goalConfigured"

section "Hardcoded 2000 calorie fallback"
scan "(calorie|Calories).*(2000|defaultCalories)|2000.*(calorie|Calories)"

section "HTTP 422 and 503 handling"
scan "statusCode.*(422|503)|case (422|503)"
