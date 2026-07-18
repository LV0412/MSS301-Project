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

Detailed API documentation:

- [API.md](./API.md)

| Resource | Endpoints |
| --- | --- |
| Categories | `POST/GET /api/categories`, `GET/PUT/DELETE /api/categories/{id}` |
| Allergens | `POST/GET /api/allergens`, `GET/PUT/DELETE /api/allergens/{id}` |
| Ingredients | `POST/GET /api/ingredients`, `GET/PUT/DELETE /api/ingredients/{id}` |
| Recipes | `POST/GET /api/recipes`, `GET/PUT/DELETE /api/recipes/{recipeId}` |

List endpoints are pageable using `page`, `size`, and `sort`.

Recipe image upload endpoint:

- `POST /api/recipes/upload-image`

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
GET /api/internal/recipes/snapshot
GET /api/internal/recipes/batch?ids=1&ids=2&ids=3
GET /api/internal/recipes/{recipeId}
GET /api/internal/recipes?ingredientIds=2,3&excludedAllergenIds=4&size=10
```

Recommended internal usage:

- `snapshot`: full catalog sync for embeddings, feature generation, or scheduled AI refresh.
- `batch`: refresh many known recipe IDs in one round trip and detect missing records.
- `search`: pre-filter candidates by allergen, diet, ingredient, and calories before AI ranking.

### Create recipe example

Create category, allergens, and ingredients first, then submit their IDs. If you want to store the real Cloudinary URL in the `recipes.image_url` column, upload the file to Cloudinary first, then pass the returned `imageUrl` into the recipe payload:

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

Then submit the returned `imageUrl` when creating or updating a recipe:

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

Difficulty values: `EASY`, `MEDIUM`, `HARD`.

Diet values: `NORMAL`, `VEGETARIAN`, `VEGAN`, `OVO_VEGETARIAN`, `LACTO_VEGETARIAN`, `KETO`, `LOW_CARB`. An omitted or empty diet list defaults to `NORMAL`.

OpenAPI JSON is available at `/v3/api-docs`; Swagger UI is at `/swagger-ui.html`.

## Database and local run

The service uses MySQL. Hibernate manages the schema directly on startup via JPA.

```bash
export DATABASE_URL=jdbc:mysql://localhost:3306/recipe_service?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
export DATABASE_USERNAME=root
export DATABASE_PASSWORD=root
export APP_CLOUDINARY_ENABLED=true
export CLOUDINARY_CLOUD_NAME=your_cloud_name
export CLOUDINARY_API_KEY=your_api_key
export CLOUDINARY_API_SECRET=your_api_secret
export CLOUDINARY_FOLDER=mss301/recipes
mvn spring-boot:run
```

Default port: `8002`.

Run the integration suite (H2 in MySQL compatibility mode):

```bash
mvn test
```
