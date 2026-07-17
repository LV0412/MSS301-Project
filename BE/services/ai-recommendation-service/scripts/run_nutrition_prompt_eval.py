import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path


SERVICE_ROOT = Path(__file__).resolve().parents[1]
if str(SERVICE_ROOT) not in sys.path:
    sys.path.insert(0, str(SERVICE_ROOT))

from dto.request import RecommendationRequest
from llm.foodyllm import FoodyLLM
from rag.hybrid_search import HybridSearch
from rag.vector_store import RecipeDocument


TARGET_INGREDIENTS = (
    "180 g wheat flour, bread, unenriched, 180 g wheat flour, white, cake, enriched, "
    "200 ml sugars, granulated, 200 g butter, without salt, 200 ml water, bottled, "
    "generic, 1 pinch salt, table"
)
TARGET_QUESTION = (
    "Review the nutrient values per 100 g in a recipe using these ingredients: "
    f"{TARGET_INGREDIENTS}"
)
EXPECTED_ANSWER = (
    "Nutritional values in each 100 g: energy - 364.03, fat - 17.96, "
    "protein - 4.09, salt - 0.05, saturates - 10.95, sugars - 18.33."
)


@dataclass(frozen=True)
class NutritionExample:
    question: str
    answer: str


ONE_SHOT_EXAMPLE = NutritionExample(
    question=(
        "Determine the nutritional profile per 100 g in a recipe that uses these "
        "ingredients: 1 cup cheese, gouda, 4 tablespoon butter, without salt, "
        "3/4 cup wheat flour, white, all-purpose, unenriched, 1/2 teaspoon salt, "
        "table, 1/2 teaspoon spices, pepper, red or cayenne, 1 tablespoon cream, "
        "fluid, heavy whipping"
    ),
    answer=(
        "Nutrient values highlighted for 100 g: energy - 426.12, fat - 29.33, "
        "protein - 14.52, salt - 1.92, saturates - 18.33, sugars - 1.18"
    ),
)

FIVE_SHOT_EXAMPLES = [
    NutritionExample(
        question=(
            "Gauge the nutrient values per 100 g in a recipe prepared with the following "
            "ingredients: 2 cup cream, fluid, heavy whipping, 1 tablespoon spices, cardamom"
        ),
        answer=(
            "Per 100 g, the nutrient values are: energy - 339.02, fat - 35.36, "
            "protein - 3.04, salt - 0.07, saturates - 22.49, sugars - 2.85"
        ),
    ),
    NutritionExample(
        question=(
            "Establish the nutrient profile per 100 g in a recipe containing these "
            "ingredients: 1 tablespoon shallots, raw, 2 teaspoon spices, garlic powder, "
            "12 cup peanut butter, smooth style, without salt, 3 tablespoon oil, sesame, "
            "salad or cooking, 2 tablespoon soy sauce made from soy (tamari), "
            "1 teaspoon spices, ginger, ground, 1 teaspoon roland, seasoned rice wine "
            "vinegar, upc: 041224705142, 1/4-1/2 teaspoon spices, pepper, red or cayenne, "
            "13 cup soup, chicken broth or bouillon, dry"
        ),
        answer=(
            "Nutrient profile for every 100 g: energy - 494.83, fat - 40.58, "
            "protein - 20.22, salt - 17.01, saturates - 8.28, sugars - 12.29"
        ),
    ),
    NutritionExample(
        question=(
            "Verify the nutrient values per 100 g in a recipe prepared with these "
            "ingredients: 16 ounce milk, fluid, 1% fat, without added vitamin a and "
            "vitamin d, 8 ounce beverages, almond milk, unsweetened, shelf stable, "
            "13 cup sugars, granulated, 14 cup cornstarch, 12 teaspoon vanilla extract, "
            "14 teaspoon shortening confectionery, coconut (hydrogenated) and or palm "
            "kernel (hydrogenated)"
        ),
        answer=(
            "Nutrient facts per 100 g: energy - 340.40, fat - 1.30, protein - 0.41, "
            "salt - 0.03, saturates - 1.11, sugars - 50.82"
        ),
    ),
    NutritionExample(
        question=(
            "Identify the nutritional composition per 100 g in a recipe with these "
            "ingredients: 500 g ground turkey, raw, 1 cup onions, raw, 12 cup bread "
            "crumbs, dry, grated, plain, 12 cup carrots, raw, 12 cup sauce, barbecue, "
            "2 teaspoon sauce, worcestershire, 1 teaspoon spices, garlic powder, "
            "34 teaspoon spices, pepper, black"
        ),
        answer=(
            "Nutrient profile for each 100 g: energy - 180.22, fat - 1.96, protein - 4.72, "
            "salt - 1.63, saturates - 0.42, sugars - 18.20"
        ),
    ),
    NutritionExample(
        question=(
            "Find the nutritional breakdown per 100 g in a recipe that uses the following "
            "ingredients: 12 pound pretzels, soft, unsalted, 21 ounce corn, sweet, white, "
            "raw, 12 ounce cookies, graham crackers, plain or honey, lowfat, 32 ounce nuts, "
            "walnuts, english, 7 ounce cookies, graham crackers, plain or honey, lowfat, "
            "12 ounce cookies, graham crackers, plain or honey, lowfat, 1 pound butter, "
            "without salt, 12 drop sauce, ready-to-serve, pepper, tabasco, 8 tablespoon "
            "sugars, brown, 2 teaspoon spices, chili powder, 2 teaspoon sauce, "
            "worcestershire, 2-3 tablespoon spices, garlic powder"
        ),
        answer=(
            "The nutrient breakdown per 100 g is: energy - 383.98, fat - 14.10, "
            "protein - 7.92, salt - 0.59, saturates - 3.85, sugars - 3.92"
        ),
    ),
]


def build_documents(shot_mode: str) -> list[RecipeDocument]:
    examples = [ONE_SHOT_EXAMPLE] if shot_mode == "one" else FIVE_SHOT_EXAMPLES
    documents = []
    for index, example in enumerate(examples, start=1):
        documents.append(
            RecipeDocument(
                recipe_id=f"nutrition-example-{index}",
                name=f"Nutrition QA Example {index}",
                tags=["nutrition", "per-100g", "few-shot"],
                calories=0,
                protein=0,
                estimated_cost=0,
                text=f"Question: {example.question}\nAnswer: {example.answer}",
                metadata={"answer": example.answer},
            )
        )
    return documents


def build_prompt(shot_mode: str, retrieved: list[RecipeDocument]) -> str:
    if shot_mode == "zero":
        return f"[INST]{TARGET_QUESTION}.[/INST]"

    examples = retrieved[:1] if shot_mode == "one" else retrieved[:5]
    example_text = " ".join(
        f"Question: {document.text.split('Answer:', 1)[0].replace('Question:', '').strip()} "
        f"Answer: {document.metadata.get('answer', '')}"
        for document in examples
    )
    return (
        "[INST]The following are examples of questions (with answers) about nutrition. "
        f"{example_text} "
        "Respond to the following question in the same manner as seen in the examples above. "
        f"Question: {TARGET_QUESTION} [/INST]"
    )


def run_case(shot_mode: str) -> dict[str, object]:
    request = RecommendationRequest(query=TARGET_QUESTION, goal="nutrition_per_100g")
    retriever = HybridSearch(build_documents(shot_mode))
    retrieved = retriever.search(request, top_k=5)
    prompt = build_prompt(shot_mode, retrieved)
    output = FoodyLLM().generate(prompt)
    return {
        "shot_mode": shot_mode,
        "stages": [
            "request_validation",
            "hybrid_search",
            "rag_prompt_builder",
            "foodyllm_generation",
        ],
        "retrieved_examples": [document.recipe_id for document in retrieved],
        "prompt": prompt,
        "expected_answer": EXPECTED_ANSWER,
        "generated_answer": output,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Run nutrition prompt tests through hybrid -> RAG -> FoodyLLM.")
    parser.add_argument("--shots", choices=["zero", "one", "five", "all"], default="all")
    parser.add_argument("--json", action="store_true", help="Print machine-readable JSON output.")
    args = parser.parse_args()

    shot_modes = ["zero", "one", "five"] if args.shots == "all" else [args.shots]
    results = [run_case(shot_mode) for shot_mode in shot_modes]

    if args.json:
        print(json.dumps(results, indent=2))
        return

    for result in results:
        print(f"=== {result['shot_mode'].upper()} SHOT ===")
        print("Stages:", " -> ".join(result["stages"]))
        print("Retrieved:", ", ".join(result["retrieved_examples"]))
        print("Prompt:")
        print(result["prompt"])
        print("Generated:")
        print(result["generated_answer"])
        print("Expected:")
        print(result["expected_answer"])
        print()


if __name__ == "__main__":
    main()
