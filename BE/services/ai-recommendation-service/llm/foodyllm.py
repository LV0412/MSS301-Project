import json
import logging
import os
import re
from typing import Any

from config import settings
from dto.request import RecommendationRequest
from rag.vector_store import RecipeDocument


logger = logging.getLogger(__name__)


class FoodyLLM:
    def __init__(self) -> None:
        self.tokenizer: Any | None = None
        self.model: Any | None = None
        self._load_attempted = False
        self._fallback_reason: str | None = None

    def generate(self, prompt: str) -> str:
        self._load_model()
        if self.model is None or self.tokenizer is None:
            return self._mock_generate(prompt)

        try:
            import torch

            input_ids = self._build_input_ids(prompt)
            with torch.inference_mode():
                output_ids = self.model.generate(
                    input_ids=input_ids,
                    max_new_tokens=settings.llm_max_new_tokens,
                    temperature=settings.llm_temperature,
                    do_sample=settings.llm_temperature > 0,
                    pad_token_id=self.tokenizer.eos_token_id,
                )

            generated_ids = output_ids[0][input_ids.shape[-1] :]
            generated_text = self.tokenizer.decode(generated_ids, skip_special_tokens=True).strip()
            return generated_text or self._mock_generate(prompt)
        except Exception as exc:
            self._fallback_reason = str(exc)
            logger.exception("FoodyLLM generation failed. Falling back to mock response: %s", exc)
            return self._mock_generate(prompt)

    def score_recipes(
        self,
        prompt: str,
        candidates: list[RecipeDocument],
        request: RecommendationRequest,
        rule_warnings: list[str] | None = None,
    ) -> list[dict[str, Any]]:
        self._load_model()
        if self.model is not None and self.tokenizer is not None:
            try:
                payload = json.loads(self.generate(prompt))
                recommendations = payload.get("recommendations")
                if isinstance(recommendations, list):
                    return [item for item in recommendations if isinstance(item, dict)]
            except (json.JSONDecodeError, AttributeError, TypeError) as exc:
                logger.warning("FoodyLLM did not return valid recommendation JSON: %s", exc)

        return self._mock_score_recipes(candidates, request, rule_warnings or [])

    def _load_model(self) -> None:
        if self._load_attempted:
            return
        self._load_attempted = True

        provider = settings.llm_provider.lower()
        if provider in {"local", "mock", "fallback", "deterministic"}:
            self._fallback_reason = f"AI_LLM_PROVIDER={settings.llm_provider}"
            return
        if provider not in {"foodyllm", "real", "huggingface"}:
            self._fallback_reason = f"AI_LLM_PROVIDER={settings.llm_provider}"
            return

        try:
            import torch
            from peft import PeftModel
            from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig

            self._fallback_reason = None
            quantization_config = None
            if settings.llm_load_in_4bit:
                quantization_config = BitsAndBytesConfig(
                    load_in_4bit=True,
                    bnb_4bit_quant_type="nf4",
                    bnb_4bit_compute_dtype=torch.float16,
                    bnb_4bit_use_double_quant=True,
                )

            model_kwargs: dict[str, Any] = {
                "pretrained_model_name_or_path": settings.foody_base_model,
                "token": settings.huggingface_token or None,
                "trust_remote_code": True,
                "attn_implementation": "eager",
                "low_cpu_mem_usage": True,
            }
            if quantization_config is not None and torch.cuda.is_available():
                model_kwargs["quantization_config"] = quantization_config
                model_kwargs["device_map"] = "auto"
            else:
                if torch.cuda.is_available():
                    model_kwargs["device_map"] = "auto"
                else:
                    logger.warning("CUDA GPU not available; FoodyLLM will try CPU inference")
                    model_kwargs["device_map"] = {"": "cpu"}
                    model_kwargs["torch_dtype"] = torch.float32

            self.tokenizer = AutoTokenizer.from_pretrained(
                settings.foody_base_model,
                token=settings.huggingface_token or None,
                use_fast=True,
            )
            if getattr(self.tokenizer, "pad_token", None) is None and getattr(self.tokenizer, "eos_token", None) is not None:
                self.tokenizer.pad_token = self.tokenizer.eos_token

            base_model = AutoModelForCausalLM.from_pretrained(**model_kwargs)
            adapter_source = self._resolve_adapter_source()
            if adapter_source and os.path.isdir(adapter_source):
                self.model = PeftModel.from_pretrained(base_model, adapter_source, token=settings.huggingface_token or None)
            elif adapter_source:
                self.model = PeftModel.from_pretrained(base_model, adapter_source, token=settings.huggingface_token or None)
            else:
                self.model = base_model

            self.model.config.use_cache = True
            self.model.eval()
            logger.info(
                "FoodyLLM loaded with base model %s and adapter %s",
                settings.foody_base_model,
                adapter_source or "base-model-only",
            )
        except Exception as exc:
            self.tokenizer = None
            self.model = None
            self._fallback_reason = str(exc)
            logger.exception("Failed to load FoodyLLM. Falling back to mock response: %s", exc)

    def _resolve_adapter_source(self) -> str | None:
        if settings.foody_adapter_path:
            return settings.foody_adapter_path
        return settings.foody_adapter or None

    def _build_input_ids(self, prompt: str) -> Any:
        messages = [{"role": "user", "content": prompt}]
        if hasattr(self.tokenizer, "apply_chat_template"):
            return self.tokenizer.apply_chat_template(
                messages,
                add_generation_prompt=True,
                return_tensors="pt",
            ).to(self.model.device)
        return self.tokenizer(prompt, return_tensors="pt").input_ids.to(self.model.device)

    def _mock_generate(self, prompt: str) -> str:
        if self._fallback_reason:
            logger.warning("Using FoodyLLM fallback: %s", self._fallback_reason)
        if "No matching recipe found" in prompt:
            return "Chua tim thay mon phu hop voi rang buoc hien tai. Hay noi long calories, ngan sach hoac di ung."

        recipes = self._extract_recipe_names(prompt)
        query = self._extract_query(prompt)
        if recipes:
            names = ", ".join(recipes[:3])
            return (
                f"Voi yeu cau '{query}', he thong uu tien {names}. "
                "Cac mon nay duoc chon tu ket qua hybrid search, sau do sap xep lai nhe theo calories, "
                "protein va ngan sach de phu hop hon voi muc tieu cua ban."
            )

        return (
            "He thong da ket hop hybrid search va RAG context de chon cac mon phu hop. "
            "Danh sach uu tien mon dung muc tieu dinh duong, tranh di ung va nam trong ngan sach."
        )

    def _mock_score_recipes(
        self,
        candidates: list[RecipeDocument],
        request: RecommendationRequest,
        rule_warnings: list[str],
    ) -> list[dict[str, Any]]:
        return [
            {
                "recipe_id": candidate.recipe_id,
                "suitability_score": round(self._deterministic_score(candidate, request), 2),
                "reason": self._build_reason(candidate, request),
                "warnings": self._candidate_warnings(candidate, request, rule_warnings),
            }
            for candidate in candidates
        ]

    def _deterministic_score(self, candidate: RecipeDocument, request: RecommendationRequest) -> float:
        score = 70.0
        if request.diet and request.diet.lower() in {tag.lower() for tag in candidate.tags}:
            score += 8.0
        if request.goal and request.goal.lower() in {tag.lower() for tag in candidate.tags}:
            score += 8.0
        if request.target_calories:
            diff_ratio = abs(request.target_calories - candidate.calories) / max(request.target_calories, 1)
            score += max(0.0, 10.0 - (diff_ratio * 10.0))
        elif request.max_calories and candidate.calories <= request.max_calories:
            score += 6.0
        if request.min_protein and candidate.protein >= request.min_protein:
            score += 5.0
        elif candidate.protein >= 25:
            score += 3.0
        if request.budget and candidate.estimated_cost and candidate.estimated_cost <= request.budget:
            score += 4.0
        return max(0.0, min(score, 100.0))

    def _build_reason(self, candidate: RecipeDocument, request: RecommendationRequest) -> str:
        reasons = [
            f"{candidate.name} phu hop voi yeu cau '{request.query}'",
            f"co {candidate.calories} kcal va {candidate.protein}g protein",
        ]
        if request.goal:
            reasons.append(f"gan voi muc tieu {request.goal}")
        if request.diet:
            reasons.append(f"da qua loc diet {request.diet}")
        return ", ".join(reasons) + "."

    def _candidate_warnings(
        self,
        candidate: RecipeDocument,
        request: RecommendationRequest,
        rule_warnings: list[str],
    ) -> list[str]:
        warnings: list[str] = []
        if request.target_calories and abs(candidate.calories - request.target_calories) > request.target_calories * 0.25:
            warnings.append("Calories lech hon 25% so voi muc tieu.")
        if request.budget and not candidate.estimated_cost:
            warnings.append("Recipe Service chua cung cap estimated_cost.")
        warnings.extend(warning for warning in rule_warnings if warning.startswith(f"{candidate.name}:"))
        return warnings

    def _extract_query(self, prompt: str) -> str:
        match = re.search(r"User query:\s*(.+)", prompt)
        return match.group(1).strip() if match else "goi y mon an"

    def _extract_recipe_names(self, prompt: str) -> list[str]:
        names: list[str] = []
        for line in prompt.splitlines():
            if not line.startswith("- "):
                continue
            name = line[2:].split(":", 1)[0].strip()
            if name:
                names.append(name)
        return names


FoodyLLMClient = FoodyLLM
