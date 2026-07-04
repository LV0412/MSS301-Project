# AI Recommendation Service

Python AI module for the recommendation pipeline:

1. Receive user profile and recommendation intent through FastAPI.
2. Search Recipe Service through its internal recipe API.
3. Fall back to the local recipe knowledge base when Recipe Service is unavailable.
4. Embed query text and run hybrid retrieval over the recipe candidates.
5. Build a RAG prompt from retrieved candidates.
6. Generate a deterministic FoodyLLM-style answer for local development.
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

The current implementation is intentionally lightweight and deterministic so the service can run before real embeddings, vector database, or LLM provider keys are configured.

## FoodyLLM

By default, local development uses a deterministic fallback explanation:

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
```

The model is lazy-loaded on the first recommendation request. If CUDA, dependencies, model access, or generation fails, the service falls back to the deterministic local explanation instead of failing the API request.
