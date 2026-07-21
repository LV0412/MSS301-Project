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

For development and tests, install `requirements-dev.txt` instead.
Install `requirements-llm.txt` only on the machine that will run real FoodyLLM inference.

## Endpoints

- `GET /health`
- `POST /api/ai/recommendations`

The recommendation endpoint accepts a user ID plus ingredient names or Recipe Service ingredient IDs. `query` is optional:

```json
{
  "user_id": "1",
  "available_ingredients": ["ức gà", "gạo lứt", "cà chua"],
  "ingredient_ids": [2, 3],
  "meal_type": "lunch",
  "goal": "muscle_gain",
  "strict_ingredients": false,
  "use_user_profile": true,
  "limit": 5
}
```

The response contains ranked catalog recipes with nutrition (including micronutrients supplied by Recipe Service), ingredient quantities, cooking steps, missing ingredients, FoodyLLM reasons, and explicit `llm_mode`. A value of `foodyllm` means real model output was parsed; `fallback` means deterministic local scoring was used.

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

The request path currently uses the in-memory hybrid vector store. ChromaDB indexing utilities are experimental and intentionally excluded from the production Docker dependencies because older ChromaDB releases conflict with FoodyLLM's Transformers/tokenizers versions.

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

The model is lazy-loaded on the first recommendation request. Set `AI_LLM_STRICT=true` when a failed model load must return HTTP 503 instead of deterministic fallback. Real deployment needs a Hugging Face token authorized for the gated base model. GPU inference is strongly recommended; CPU loading is supported for compatibility but is not suitable for normal API latency.

## Docker

From the repository root:

```powershell
docker compose up --build ai-recommendation-service api-gateway-service
```

The gateway exposes the same endpoint at `http://localhost:8080/api/ai/recommendations`. The default lightweight image uses `AI_LLM_PROVIDER=local` and intentionally excludes PyTorch/CUDA so the integration flow can be tested quickly. The GPU override uses `Dockerfile.gpu` and installs `requirements-llm.txt` for real FoodyLLM inference.

On a Docker host with NVIDIA Container Toolkit, use the GPU override:

```powershell
$env:HUGGINGFACE_TOKEN="hf_token_with_llama_access"
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up --build ai-recommendation-service api-gateway-service
```

## EC2 GPU Deployment

For a `g4dn.xlarge` EC2 instance, prefer Ubuntu 22.04/24.04 or an AWS Deep Learning AMI with NVIDIA drivers already installed. Open inbound ports only from your IP where possible: `22` for SSH, `8004` for direct AI service testing, and `8080` if you expose the API gateway.

SSH into the instance:

```bash
ssh -i /path/to/key.pem ubuntu@EC2_PUBLIC_IP
```

Install Docker Engine if the AMI does not already include it:

```bash
sudo apt update
sudo apt install -y ca-certificates curl git
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
newgrp docker
```

Verify that the host can see the GPU:

```bash
nvidia-smi
```

If `nvidia-smi` is missing, install an NVIDIA driver first or rebuild the instance with a GPU Deep Learning AMI. After the host GPU works, install NVIDIA Container Toolkit:

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
  | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

Clone the repository and start the AI service with the GPU override:

```bash
git clone REPO_URL
cd MSS301-Project
export HUGGINGFACE_TOKEN="hf_token_with_llama_access"
export AI_DATABASE_PASSWORD="change-me"
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d --build ai-postgres ai-recommendation-service
docker compose -f docker-compose.yml -f docker-compose.gpu.yml logs -f ai-recommendation-service
```

Smoke test:

```bash
curl http://localhost:8004/health
```

The first real recommendation request downloads and loads the model, so it can take several minutes. Model files are cached in the `hf_model_cache` Docker volume.

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
