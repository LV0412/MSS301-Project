# AI Recommendation Service

Python AI module for the recommendation pipeline:

1. Receive user profile and recommendation intent through FastAPI.
2. Embed query text and run hybrid retrieval over the recipe knowledge base.
3. Build a RAG prompt from retrieved candidates.
4. Generate a deterministic FoodyLLM-style answer for local development.
5. Optimize meal choices against calories, diet, allergy, and budget constraints.

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

The current implementation is intentionally lightweight and deterministic so the service can run before real embeddings, vector database, or LLM provider keys are configured.
