# AI Recommendation Service

Python AI module for the recommendation pipeline:

1. Receive user profile and recommendation intent through FastAPI.
2. Search Recipe Service through its internal recipe API.
3. Fall back to the local recipe knowledge base when Recipe Service is unavailable.
4. Embed query text and run hybrid retrieval over the recipe candidates.
5. Build a RAG prompt from retrieved candidates.
6. Use FoodyLLM as the food and nutrition foundation model to score candidates.
7. Optimize meal choices against calories, diet, allergy, and budget constraints.

## Run Locally

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app:app --reload --port 8004
```

## Endpoints

- `GET /health`
- `POST /api/ai/recommendations`

Swagger UI:

```text
http://localhost:8004/docs
```

OpenAPI JSON:

```text
http://localhost:8004/openapi.json
```

When `POST /api/ai/recommendations` runs, the service first calls Recipe Service:

```text
GET ${RECIPE_SERVICE_URL}/api/internal/recipes
GET ${RECIPE_SERVICE_URL}/api/internal/recipes/{recipeId}
```

Set the downstream URL in `.env`:

```env
RECIPE_SERVICE_URL=http://localhost:8002
```

The service keeps deterministic fallbacks so local development can run before GPU/model access is configured, but the target design is FoodyLLM-based.

## FoodyLLM

This AI service uses FoodyLLM as the model foundation, then applies it to the app's recommendation workflow.

The original FoodyLLM project is a Meta-Llama-3-8B-Instruct model fine-tuned with the `Matej/FoodyLLM` LoRA adapter for food and nutrition analysis tasks such as nutrition profile assessment, traffic-light nutrition labeling, food entity extraction, and food ontology linking.

In this service, FoodyLLM is not used as a standalone chatbot. It is applied after the app-specific retrieval and rule layers:

```text
user request/profile
-> Recipe Service or local recipe corpus
-> rule filtering for diet, allergy, budget, and nutrition constraints
-> hybrid retrieval and RAG context
-> FoodyLLM JSON suitability scoring
-> meal optimization
-> API response
```

For local development, you can force the deterministic fallback:

```env
AI_LLM_PROVIDER=local
```

To enable real Hugging Face FoodyLLM inference on a GPU machine:

```env
AI_LLM_PROVIDER=foodyllm
FOODY_BASE_MODEL=meta-llama/Meta-Llama-3-8B-Instruct
FOODY_ADAPTER=Matej/FoodyLLM
HUGGINGFACE_TOKEN=your_huggingface_token
LLM_MAX_NEW_TOKENS=512
LLM_TEMPERATURE=0.3
LLM_LOAD_IN_4BIT=true
FOODY_MODEL_SOURCE=FoodyLLM: FAIR-aligned specialized LLM for food and nutrition analysis
FOODY_SUPPORTED_TASKS=nutrition_profile,traffic_light_label,food_ner,food_ontology_linking
```

The model is lazy-loaded on the first recommendation request. If CUDA, dependencies, model access, or generation fails, the service falls back to the deterministic local explanation instead of failing the API request.

The reference FoodyLLM files kept in `../FoodyLLM` are the model/research source. This service wraps that foundation model inside the production recommendation API instead of replacing the app-specific retrieval, rules, and optimizer layers.

## Nutrition Prompt Evaluation

Run the zero-shot, one-shot, and five-shot nutrition prompt cases through the local
`hybrid_search -> rag_prompt_builder -> foodyllm_generation` flow:

```powershell
.\.venv\Scripts\python.exe .\scripts\run_nutrition_prompt_eval.py --shots all
```

Machine-readable output for reports or notebooks:

```powershell
.\.venv\Scripts\python.exe .\scripts\run_nutrition_prompt_eval.py --shots all --json
```

Use `--shots zero`, `--shots one`, or `--shots five` to run only one prompt setup.
With `AI_LLM_PROVIDER=local`, the generated answer is the deterministic fallback;
set `AI_LLM_PROVIDER=foodyllm` and the Hugging Face settings above to test the real
FoodyLLM generation path.

## FoodyLLM-Based AI Service Evaluation

The original `../FoodyLLM/datasets` folder contains dataset generation code for FoodyLLM tasks, not ready-to-run train/test files. For reporting this service, use the curated evaluation set at:

```text
data/evaluation/foodyllm_ai_eval.json
```

It maps FoodyLLM task families to the app recommendation pipeline:

```text
assessing_recipe_nutritional_profile
traffic_light_nutrition_labeling
food_entity_extraction_and_safety_filtering
```

Run the benchmark with deterministic local FoodyLLM fallback:

```powershell
.\.venv\Scripts\python.exe .\scripts\run_foodyllm_ai_eval.py
```

On EC2 with the PyTorch environment:

```bash
python scripts/run_foodyllm_ai_eval.py
```

To benchmark the real GPU-backed FoodyLLM path, set the Hugging Face model environment variables and add:

```bash
python scripts/run_foodyllm_ai_eval.py --use-real-foodyllm
```

The script writes report-ready outputs:

```text
reports/foodyllm_ai_eval_predictions.jsonl
reports/foodyllm_ai_eval_metrics.json
reports/foodyllm_ai_eval_report.md
```
