# Recipe Service

Spring Boot microservice that owns the recipe catalog, categories, ingredients, allergens, recipe steps, diet tags, and nutrition data.

## Implemented rules

- Every recipe belongs to one category.
- Every recipe has at least one unique ingredient, one or more consecutive steps starting at `1`, and exactly one nutrition record.
- An ingredient can belong to many recipes and can contain many allergens.
- Recipe create/update is transactional, including ingredients, steps, and nutrition.
- Referenced categories, ingredients, and allergens cannot be deleted.
- Recipe search can exclude every recipe containing one of the supplied allergen IDs.

## API

Both `/api/...` and `/api/v1/...` public paths are supported.

| Resource | Endpoints |
| --- | --- |
| Categories | `POST/GET /api/categories`, `GET/PUT/DELETE /api/categories/{id}` |
| Allergens | `POST/GET /api/allergens`, `GET/PUT/DELETE /api/allergens/{id}` |
| Ingredients | `POST/GET /api/ingredients`, `GET/PUT/DELETE /api/ingredients/{id}` |
| Recipes | `POST/GET /api/recipes`, `GET/PUT/DELETE /api/recipes/{recipeId}` |

List endpoints are pageable using `page`, `size`, and `sort`.

Recipe search supports:

```text
GET /api/recipes?query=noodles
    &categoryId=1
    &ingredientIds=2,3
    &ingredient=egg
    &minCalories=200
    &maxCalories=600
    &dietType=VEGETARIAN
    &excludedAllergenIds=4,5
    &page=0&size=20&sort=createdAt,desc
```

`ingredientIds` matches recipes containing at least one supplied ingredient. `excludedAllergenIds` removes a recipe if any of its ingredients contains any supplied allergen.

Read-only service-to-service endpoints for the AI service use the same filters:

```text
GET /api/internal/recipes/{recipeId}
GET /api/internal/recipes?ingredientIds=2,3&excludedAllergenIds=4&size=10
```

### Create recipe example

Create category, allergens, and ingredients first, then submit their IDs:

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
    "calories": 430,
    "protein": 18,
    "fat": 12,
    "carbs": 62,
    "fiber": 7,
    "sugar": 5,
    "sodium": 520
  }
}
```

Difficulty values: `EASY`, `MEDIUM`, `HARD`.

Diet values: `NORMAL`, `VEGETARIAN`, `VEGAN`, `OVO_VEGETARIAN`, `LACTO_VEGETARIAN`, `KETO`, `LOW_CARB`. An omitted or empty diet list defaults to `NORMAL`.

OpenAPI JSON is available at `/v3/api-docs`; Swagger UI is at `/swagger-ui.html`.

## Database and local run

The service uses PostgreSQL. Flyway creates and validates the schema on startup.

```bash
export DATABASE_URL=jdbc:postgresql://localhost:5432/recipe_service
export DATABASE_USERNAME=postgres
export DATABASE_PASSWORD=postgres
mvn spring-boot:run
```

Default port: `8002`.

Run the integration suite (H2 in PostgreSQL compatibility mode):

```bash
mvn test
```
