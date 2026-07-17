#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DEFAULT_ENV_FILE="${SCRIPT_DIR}/../services/recipe-service/.env"
ENV_FILE="${ENV_FILE:-${DEFAULT_ENV_FILE}}"
APPLICATION_YML="${APPLICATION_YML:-${SCRIPT_DIR}/../services/recipe-service/src/main/resources/application.yml}"

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

if [[ -n "${CLOUDINARY_URL:-}" ]]; then
  cloudinary_url_without_scheme="${CLOUDINARY_URL#cloudinary://}"
  if [[ "${cloudinary_url_without_scheme}" != "${CLOUDINARY_URL}" ]]; then
    CLOUDINARY_API_KEY="${CLOUDINARY_API_KEY:-${cloudinary_url_without_scheme%%:*}}"
    cloudinary_secret_and_name="${cloudinary_url_without_scheme#*:}"
    CLOUDINARY_API_SECRET="${CLOUDINARY_API_SECRET:-${cloudinary_secret_and_name%@*}}"
    CLOUDINARY_CLOUD_NAME="${CLOUDINARY_CLOUD_NAME:-${cloudinary_secret_and_name#*@}}"
  fi
fi

extract_spring_default() {
  local property_name="$1"
  local line

  if [[ ! -f "${APPLICATION_YML}" ]]; then
    return 1
  fi

  line="$(grep -E "^[[:space:]]+${property_name}:" "${APPLICATION_YML}" | head -n 1 || true)"
  if [[ -z "${line}" ]]; then
    return 1
  fi

  sed -E 's/.*\$\{[^:]+:(.*)\}.*/\1/' <<<"${line}"
}

CLOUDINARY_CLOUD_NAME="${CLOUDINARY_CLOUD_NAME:-$(extract_spring_default "cloud-name" || true)}"
CLOUDINARY_API_KEY="${CLOUDINARY_API_KEY:-$(extract_spring_default "api-key" || true)}"
CLOUDINARY_API_SECRET="${CLOUDINARY_API_SECRET:-$(extract_spring_default "api-secret" || true)}"
CLOUDINARY_FOLDER="${CLOUDINARY_FOLDER:-$(extract_spring_default "folder" || true)}"
APP_CLOUDINARY_ENABLED="${APP_CLOUDINARY_ENABLED:-$(extract_spring_default "enabled" || true)}"

required_vars=(
  CLOUDINARY_CLOUD_NAME
  CLOUDINARY_API_KEY
  CLOUDINARY_API_SECRET
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required environment variable: ${var_name}" >&2
    exit 1
  fi
done

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required because this script updates MySQL through the running container." >&2
  exit 1
fi

DB_CONTAINER="${DB_CONTAINER:-mysql-local}"
DB_NAME="${DB_NAME:-recipe_service}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-root}"
CLOUDINARY_FOLDER="${CLOUDINARY_FOLDER:-mss301/recipes}"
DRY_RUN="${DRY_RUN:-false}"
VERIFY_ONLY="${VERIFY_ONLY:-false}"
ONLY_RECIPE_ID="${ONLY_RECIPE_ID:-}"

if [[ "${APP_CLOUDINARY_ENABLED:-true}" != "true" ]]; then
  echo "Cloudinary is disabled in configuration. Set APP_CLOUDINARY_ENABLED=true." >&2
  exit 1
fi

cloudinary_signature() {
  local public_id="$1"
  local timestamp="$2"
  local params_to_sign

  params_to_sign="folder=${CLOUDINARY_FOLDER}&overwrite=true&public_id=${public_id}&timestamp=${timestamp}"
  printf '%s' "${params_to_sign}${CLOUDINARY_API_SECRET}" | openssl dgst -sha1 -r | awk '{print $1}'
}

recipes=(
  "1|https://upload.wikimedia.org/wikipedia/commons/b/b0/Banana_blueberry_oatmeal.jpg"
  "2|https://upload.wikimedia.org/wikipedia/commons/b/b8/Spinach_omelette_%283278835124%29.jpg"
  "3|https://upload.wikimedia.org/wikipedia/commons/d/d1/Yogurt_fruit_bowl.jpg"
  "4|https://www.themealdb.com/images/media/meals/sywswr1511383814.jpg"
  "5|https://upload.wikimedia.org/wikipedia/commons/1/15/Fried_brown_rice_with_salmon%2C_egg%2C_and_various_vegetables_%E3%82%B5%E3%83%BC%E3%83%A2%E3%83%B3%E3%81%A8%E5%8D%B5%E3%80%81%E9%87%8E%E8%8F%9C%E3%81%84%E3%82%8D%E3%81%84%E3%82%8D%E5%85%A5%E3%82%8A%E7%8E%84%E7%B1%B3%E3%83%81%E3%83%A3%E3%83%BC%E3%83%8F%E3%83%B3.jpg"
  "6|https://www.themealdb.com/images/media/meals/wuyd2h1765655837.jpg"
  "7|https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Salmon_and_Quinoa_dish_%2839791934733%29.jpg/960px-Salmon_and_Quinoa_dish_%2839791934733%29.jpg"
  "8|https://www.themealdb.com/images/media/meals/yypwwq1511304979.jpg"
  "9|https://commons.wikimedia.org/wiki/Special:FilePath/Ground%20beef%20and%20avocado%20%28elderly%29%20on%20brown%20rice%20with%20black%20beans%20and%20tomato%20paste%20-%20Massachusetts.jpg"
  "10|https://upload.wikimedia.org/wikipedia/commons/1/1d/Royal_Tunisian_couscous.JPG"
  "11|https://upload.wikimedia.org/wikipedia/commons/8/82/Tomatoes_stew_with_chicken_lap_and_fishes.jpg"
  "12|https://upload.wikimedia.org/wikipedia/commons/1/12/Beef_-stew_with_-carrots%2C_-mushrooms%2C_-peas%2C_and_-potatoes_served_in_a_-sourdough_-bread_bowl.jpg"
  "13|https://upload.wikimedia.org/wikipedia/commons/9/9c/Yayoi-ken_ginger_pork_stir-fry_set.jpg"
  "14|https://upload.wikimedia.org/wikipedia/commons/9/96/4373Fried_tilapia_with_broccoli%2C_tomatoes_and_egg_02.jpg"
  "15|https://upload.wikimedia.org/wikipedia/commons/c/c7/Matsuya_Foods_Extra_Meat_Of_BBQ_Beef_Rice_Bowl_Garlic_soy_sauce.jpg"
  "16|https://upload.wikimedia.org/wikipedia/commons/c/c5/Apple_peanut_butter_caramel_bars_%2841368588400%29.jpg"
  "17|https://upload.wikimedia.org/wikipedia/commons/2/2d/Healthy_oat_and_fruit_nut_snack_bars_on_a_white_plate_next_to_a_personalized_baking_dish_with_dates_nuts_and_seeds_on_a_wood_table_%2816087466367%29.jpg"
  "18|https://upload.wikimedia.org/wikipedia/commons/3/38/Eating_Healthy_on_the_Run_Protein_Bites%2C_Roasted_Chickpeas_%2835527731653%29.jpg"
  "19|https://commons.wikimedia.org/wiki/Special:FilePath/Bowl%20of%20Edamame.jpg"
  "20|https://commons.wikimedia.org/wiki/Special:FilePath/Banana%20and%20yogurt.jpg"
  "21|https://www.themealdb.com/images/media/meals/c0gmo31766594751.jpg"
  "22|https://upload.wikimedia.org/wikipedia/commons/d/d7/Ice_Cream_Banana_%28Blue_Java%29.jpg"
  "23|https://upload.wikimedia.org/wikipedia/commons/7/7e/This_is_a_picture_of_Indian_rice_pudding_or_firni_which_has_been_set_in_a_shallow_earthen_dish.Strands_of_saffron_and_chopped_almonds_and_pistachios_have_been_used_for_garnishing.jpg"
  "24|https://commons.wikimedia.org/wiki/Special:FilePath/Sweet%20Potato%20Pie.png"
  "25|https://upload.wikimedia.org/wikipedia/commons/d/da/Baked_apple.JPG"
  "26|https://commons.wikimedia.org/wiki/Special:FilePath/Colorful%20healthy%20Chickpea%20Salad.jpg"
  "27|https://upload.wikimedia.org/wikipedia/commons/a/aa/Oak-Roasted_Salmon_With_Potato_Salad_%283119136452%29.jpg"
  "28|https://upload.wikimedia.org/wikipedia/commons/1/18/Shrimp_Salad.JPG"
  "29|https://www.themealdb.com/images/media/meals/ji3mho1782499823.jpg"
  "30|https://www.themealdb.com/images/media/meals/minfsc1763766806.jpg"
  "31|https://upload.wikimedia.org/wikipedia/commons/b/b5/Vegan_Arabian_Lentil_and_Rice_Soup_%287230462472%29.jpg"
  "32|https://commons.wikimedia.org/wiki/Special:FilePath/Miso%20Soup%20001.jpg"
  "33|https://upload.wikimedia.org/wikipedia/commons/9/95/Vegetable_pork_barley_soup_with_chicken_livers_and_sour_cream%2C_by_Silar_2010_I.JPG"
  "34|https://upload.wikimedia.org/wikipedia/commons/e/e0/Fish_Mulligatawny_Soup_-_Pollack_with_Yam_Sweet_Potatoes.jpg"
  "35|https://commons.wikimedia.org/wiki/Special:FilePath/Sweet%20potato%20chorizo%20soup%20%285058084454%29.jpg"
  "36|https://upload.wikimedia.org/wikipedia/commons/3/3f/Banna_Yogurt_Smoothie.jpg"
  "37|https://upload.wikimedia.org/wikipedia/commons/a/a0/Straberries%2C_blueberres%2C_raspberries%2C_goji_berries%2C_apple_juice%2C_agave_nectar_Smoothie_%283013386183%29.jpg"
  "38|https://commons.wikimedia.org/wiki/Special:FilePath/Smoothie%20%282580641628%29.jpg"
  "39|https://upload.wikimedia.org/wikipedia/commons/6/69/Odia_style_Lassi-Puri-Odisha-IMG_9776.jpg"
  "40|https://commons.wikimedia.org/wiki/Special:FilePath/Sinh%20t%E1%BB%91%20b%C6%A1.jpg"
  "41|https://upload.wikimedia.org/wikipedia/commons/8/8b/Curried_vegetables_with_tofu_and_rice_-_Verduras_al_curry_con_tofu_y_arroz_%284623676509%29.jpg"
  "42|https://commons.wikimedia.org/wiki/Special:FilePath/Grilled%20tempeh%20and%20vegetables%20%287603211410%29.jpg"
  "43|https://upload.wikimedia.org/wikipedia/commons/b/bd/Chickpea_Curry_-_Kolkata_2011-03-05_1910.JPG"
  "44|https://commons.wikimedia.org/wiki/Special:FilePath/Vegan%20Quinoa%20Bowl%20%2844040185371%29.jpg"
  "45|https://upload.wikimedia.org/wikipedia/commons/2/2c/Spicy_bean_burger.jpg"
  "46|https://upload.wikimedia.org/wikipedia/commons/c/cc/Quinoa_con_salteado_de_pollo_y_calabac%C3%ADn.jpg"
  "47|https://upload.wikimedia.org/wikipedia/commons/c/cb/Spicy_tuna_rice_bowl_%2835032450572%29.jpg"
  "48|https://upload.wikimedia.org/wikipedia/commons/7/77/North_coastal_salmon%2C_smoked_yoghurt_and_caviar_lentils.JPG"
  "49|https://commons.wikimedia.org/wiki/Special:FilePath/Sweet%20potatoes%20and%20za%27atar%20chickpeas%20with%20herby%20yogurt%20%2849803694683%29.jpg"
  "50|https://www.themealdb.com/images/media/meals/1529445434.jpg"
)

failures=0
updated=0

for entry in "${recipes[@]}"; do
  recipe_id="${entry%%|*}"
  source_url="${entry#*|}"
  public_id="recipe-${recipe_id}"

  if [[ -n "${ONLY_RECIPE_ID}" && "${recipe_id}" != "${ONLY_RECIPE_ID}" ]]; then
    continue
  fi

  if [[ "${VERIFY_ONLY}" == "true" ]]; then
    if curl -A "MSS301 recipe image backfill/1.0" -fsSLI --retry 3 --retry-all-errors --retry-delay 2 --max-time 30 "${source_url}" >/dev/null; then
      echo "Verified recipe ${recipe_id}: ${source_url}"
    else
      echo "Failed source URL for recipe ${recipe_id}: ${source_url}" >&2
      failures=$((failures + 1))
    fi
    sleep 1
    continue
  fi

  timestamp="$(date +%s)"
  signature="$(cloudinary_signature "${public_id}" "${timestamp}")"

  echo "Uploading recipe ${recipe_id} from ${source_url}"

  response="$(
    curl -sS \
      -X POST "https://api.cloudinary.com/v1_1/${CLOUDINARY_CLOUD_NAME}/image/upload" \
      -F "file=${source_url}" \
      -F "folder=${CLOUDINARY_FOLDER}" \
      -F "public_id=${public_id}" \
      -F "overwrite=true" \
      -F "timestamp=${timestamp}" \
      -F "api_key=${CLOUDINARY_API_KEY}" \
      -F "signature=${signature}"
  )"

  secure_url="$(jq -r '.secure_url // empty' <<<"${response}")"
  error_message="$(jq -r '.error.message // empty' <<<"${response}")"

  if [[ -z "${secure_url}" ]]; then
    echo "Failed recipe ${recipe_id}: ${error_message:-Cloudinary did not return secure_url}" >&2
    failures=$((failures + 1))
    continue
  fi

  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "DRY_RUN recipe ${recipe_id}: ${secure_url}"
    continue
  fi

  docker exec -e MYSQL_PWD="${DB_PASSWORD}" "${DB_CONTAINER}" \
    mysql --default-character-set=utf8mb4 -u"${DB_USER}" "${DB_NAME}" \
    -e "UPDATE recipes SET image_url='${secure_url}', updated_at=CURRENT_TIMESTAMP WHERE recipe_id=${recipe_id};"

  echo "Updated recipe ${recipe_id}: ${secure_url}"
  updated=$((updated + 1))
  sleep 1
done

echo "Updated ${updated} recipe images. Failures: ${failures}."

if [[ "${VERIFY_ONLY}" == "true" ]]; then
  echo "Verified $(( ${#recipes[@]} - failures )) source image URLs. Failures: ${failures}."
elif [[ "${DRY_RUN}" != "true" ]]; then
  docker exec -e MYSQL_PWD="${DB_PASSWORD}" "${DB_CONTAINER}" \
    mysql --default-character-set=utf8mb4 -u"${DB_USER}" "${DB_NAME}" \
    -e "SELECT COUNT(*) AS cloudinary_images FROM recipes WHERE image_url LIKE 'https://res.cloudinary.com/%';"
fi

if [[ "${failures}" -gt 0 ]]; then
  exit 1
fi
