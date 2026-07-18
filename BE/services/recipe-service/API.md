# Recipe Service API

Recipe Service is the domain owner for recipe content in this microservices project. It manages the recipe catalog and the supporting taxonomy needed to make recipes searchable, safe, and reusable across the platform.

## Why This Service Matters

This service is valuable because it centralizes the food domain into one source of truth:

- It keeps recipe, ingredient, category, allergen, step, diet, and nutrition data consistent.
- It enforces recipe business rules in one place instead of duplicating them in other services.
- It gives the UI and other backend services a stable API for browsing, creating, and filtering recipes.
- It supports allergen-aware and nutrition-aware search, which is important for personalized food experiences.
- It exposes read-only internal endpoints so services like AI Recommendation Service can reuse recipe data without owning it.

In short, this service is the catalog backbone of the application.

## Base URLs

Public APIs are available under both:

- `/api/...`
- `/api/v1/...`

Internal service-to-service APIs are available under:

- `/api/internal/...`

Default local port:

- `8002`

## Public APIs

### Categories

Base path:

```text
/api/categories
```

Endpoints:

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/categories` | Create a category |
| `GET` | `/api/categories` | List categories with pagination |
| `GET` | `/api/categories/{id}` | Get one category |
| `PUT` | `/api/categories/{id}` | Update a category |
| `DELETE` | `/api/categories/{id}` | Delete a category |

Value:

- Categories create the top-level organization for recipes, such as breakfast, lunch, dinner, or snack.
- They help users browse recipes by meal type or content group.
- They keep the catalog structured and easier to navigate.

### Allergens

Base path:

```text
/api/allergens
```

Endpoints:

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/allergens` | Create an allergen |
| `GET` | `/api/allergens` | List allergens with pagination |
| `GET` | `/api/allergens/{id}` | Get one allergen |
| `PUT` | `/api/allergens/{id}` | Update an allergen |
| `DELETE` | `/api/allergens/{id}` | Delete an allergen |

Value:

- Allergens make recipe filtering safer for users with dietary restrictions.
- They power exclusions like peanut-free, dairy-free, or gluten-free searches.
- They let the system describe ingredients accurately instead of hardcoding allergen logic in the frontend.

### Ingredients

Base path:

```text
/api/ingredients
```

Endpoints:

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/ingredients` | Create an ingredient |
| `GET` | `/api/ingredients` | List ingredients with pagination |
| `GET` | `/api/ingredients/{id}` | Get one ingredient |
| `PUT` | `/api/ingredients/{id}` | Update an ingredient |
| `DELETE` | `/api/ingredients/{id}` | Delete an ingredient |

Value:

- Ingredients are the reusable building blocks of recipes.
- A single ingredient can be used in many recipes, which avoids duplication.
- Ingredients can be linked to allergens, which helps support safety checks and smart search.

### Recipes

Base path:

```text
/api/recipes
```

Endpoints:

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/recipes` | Create a recipe |
| `POST` | `/api/recipes/upload-image` | Upload a recipe image to Cloudinary |
| `GET` | `/api/recipes/{recipeId}` | Get one recipe |
| `GET` | `/api/recipes` | Search recipes with filters and pagination |
| `PUT` | `/api/recipes/{recipeId}` | Update a recipe |
| `DELETE` | `/api/recipes/{recipeId}` | Delete a recipe |

Value:

- Recipes are the core business object of this service.
- They bundle category, ingredients, steps, diet tags, and nutrition into one aggregate.
- They are transactional, so a recipe is always created or updated as a complete unit.
- They support search filters that are useful for discovery and personalization:
  - text query
  - category
  - ingredient IDs
  - ingredient name search
  - calorie range
  - diet type
  - excluded allergen IDs

Example search:

```text
GET /api/recipes?query=noodles&categoryId=1&ingredientIds=2,3&minCalories=200&maxCalories=600&dietType=VEGETARIAN&excludedAllergenIds=4,5
```

### Upload Recipe Image To Cloudinary

Use this endpoint to upload an image file and receive the real Cloudinary `secure_url`. That URL can then be stored in the recipe payload's `imageUrl` field, which maps to the `image_url` column in the `recipes` table.

Request:

```text
POST /api/recipes/upload-image
Content-Type: multipart/form-data
Body: file=<image>
```

Example:

```bash
curl -X POST http://localhost:8002/api/recipes/upload-image \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/absolute/path/to/recipe-image.jpg"
```

Example response:

```json
{
  "imageUrl": "https://res.cloudinary.com/your-cloud/image/upload/v1721200000/mss301/recipes/recipe-image_abc123.jpg",
  "publicId": "mss301/recipes/recipe-image_abc123",
  "originalFilename": "recipe-image.jpg"
}
```

## Internal APIs

### Recipe Lookup For Other Services

Base path:

```text
/api/internal/recipes
```

Endpoints:

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/internal/recipes/snapshot` | Get a full catalog snapshot for AI indexing or offline recommendation jobs |
| `GET` | `/api/internal/recipes/batch?ids=1&ids=2` | Get many recipes in one call and report missing IDs |
| `GET` | `/api/internal/recipes/{recipeId}` | Get a recipe for service-to-service use |
| `GET` | `/api/internal/recipes` | Search recipes for service-to-service use |

Value:

- These endpoints let other microservices reuse recipe data without duplicating recipe logic.
- The AI Recommendation Service can query recipe information directly from the source of truth.
- This keeps internal integrations read-only and easier to reason about.
- `snapshot` is best for initial sync, embeddings, vector indexing, or nightly refresh jobs.
- `batch` is best when the AI service already knows recipe IDs and needs the latest full detail payloads.
- `search` is best for real-time filtering before ranking, for example by calories, diet type, ingredient, or excluded allergens.

Example snapshot response shape:

```json
{
  "generatedAt": "2026-07-18T10:30:00",
  "summary": {
    "totalRecipes": 50,
    "totalCategories": 6,
    "totalIngredients": 78,
    "totalAllergens": 10
  },
  "categories": [],
  "allergens": [],
  "ingredients": [],
  "recipes": []
}
```

Example batch response shape:

```json
{
  "requestedIds": [1, 2, 999],
  "missingIds": [999],
  "recipes": [
    {
      "recipeId": 1,
      "title": "Vegetable egg noodles"
    }
  ]
}
```

## Data Rules

The service enforces these rules:

- Every recipe must belong to exactly one category.
- Every recipe must have at least one ingredient.
- Recipe steps must start at `1` and remain consecutive.
- Every recipe must have exactly one nutrition record.
- Ingredients may contain allergens.
- Categories, ingredients, and allergens are shared catalog data that should not be deleted when referenced by recipes.

## Example Recipe Payload

After uploading the image, copy the returned `imageUrl` into the payload below.

```json
{
  "categoryId": 1,
  "title": "Vegetable egg noodles",
  "description": "Quick stir-fried noodles",
  "imageUrl": "https://example.com/noodles.jpg",
  "preparationTime": 10,
  "cookTime": 15,
  "difficulty": "EASY",
  "servings": 2,
  "dietTypes": ["OVO_VEGETARIAN"],
  "ingredients": [
    {"ingredientId": 2, "quantity": 200, "unit": "g"},
    {"ingredientId": 3, "quantity": 2, "unit": "piece"}
  ],
  "steps": [
    {"stepOrder": 1, "instruction": "Boil the noodles."},
    {"stepOrder": 2, "instruction": "Stir-fry all ingredients."}
  ],
  "nutrition": {
    "servingSizeGrams": 240,
    "calories": 430,
    "protein": 18,
    "fat": 12,
    "saturatedFat": 3.5,
    "transFat": 0.1,
    "cholesterol": 18,
    "carbs": 62,
    "fiber": 7,
    "sugar": 5,
    "sodium": 520,
    "potassium": 640,
    "vitaminA": 180,
    "vitaminD": 2.4,
    "vitaminE": 3.1,
    "vitaminK": 24,
    "vitaminB1": 0.18,
    "vitaminB2": 0.22,
    "vitaminB3": 6.8,
    "vitaminB6": 0.44,
    "vitaminB9": 52,
    "vitaminB12": 0.9,
    "vitaminC": 16,
    "calcium": 120,
    "iron": 3.4
  }
}
```

Unit note: `vitaminA`, `vitaminD`, `vitaminK`, `vitaminB9`, and `vitaminB12` are stored per serving in `mcg`. The remaining vitamin and mineral fields are stored in `mg`.

## Summary

Recipe Service is the platform’s recipe source of truth. It gives the rest of the system a clean API for catalog management, recipe discovery, allergen-aware filtering, and internal recipe lookup.

## env
APP_NAME=recipe-service
APP_ENV=local
APP_PORT=8002

DATABASE_URL=jdbc:mysql://localhost:3306/recipe_service?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
DATABASE_USERNAME=root
DATABASE_PASSWORD=root
JPA_SHOW_SQL=false
APP_CLOUDINARY_ENABLED=true
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_FOLDER=mss301/recipes
