# Recipe Service

Owns recipe catalog data and behavior.

## Domain Entities

- `RECIPE`
- `RECIPE_STEP`
- `NUTRITION_INFO`
- `INGREDIENT`
- `CATEGORY`

## Suggested Responsibilities

- Recipe CRUD and search.
- Recipe step management.
- Ingredient and category management.
- Nutrition information for recipes.

## MVC Package Layout

- `controller`: REST APIs for recipe catalog features.
- `dto`: request/response objects.
- `model`: JPA entities.
- `repository`: Spring Data repositories.
- `service`: recipe, ingredient, category, and nutrition business logic.
- `config`: service configuration.
