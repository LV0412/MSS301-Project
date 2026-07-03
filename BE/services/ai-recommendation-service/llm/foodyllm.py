import logging
from typing import Any

from config import settings


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

    def _load_model(self) -> None:
        if self._load_attempted:
            return
        self._load_attempted = True

        if settings.llm_provider.lower() not in {"foodyllm", "real", "huggingface"}:
            self._fallback_reason = f"AI_LLM_PROVIDER={settings.llm_provider}"
            return

        try:
            import torch
            from peft import PeftModel
            from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig

            if not torch.cuda.is_available():
                self._fallback_reason = "CUDA GPU is not available"
                logger.warning("FoodyLLM real model disabled: %s", self._fallback_reason)
                return

            quantization_config = None
            if settings.llm_load_in_4bit:
                quantization_config = BitsAndBytesConfig(
                    load_in_4bit=True,
                    bnb_4bit_quant_type="nf4",
                    bnb_4bit_compute_dtype=torch.float16,
                    bnb_4bit_use_double_quant=True,
                )

            self.tokenizer = AutoTokenizer.from_pretrained(
                settings.foody_base_model,
                token=settings.huggingface_token or None,
                use_fast=True,
            )
            base_model = AutoModelForCausalLM.from_pretrained(
                settings.foody_base_model,
                token=settings.huggingface_token or None,
                quantization_config=quantization_config,
                device_map="auto",
                trust_remote_code=True,
            )
            self.model = PeftModel.from_pretrained(
                base_model,
                settings.foody_adapter,
                token=settings.huggingface_token or None,
            )
            self.model.eval()
            logger.info(
                "FoodyLLM loaded with base model %s and adapter %s",
                settings.foody_base_model,
                settings.foody_adapter,
            )
        except Exception as exc:
            self.tokenizer = None
            self.model = None
            self._fallback_reason = str(exc)
            logger.exception("Failed to load FoodyLLM. Falling back to mock response: %s", exc)

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
        return (
            "He thong da ket hop hybrid search va RAG context de chon cac mon phu hop. "
            "Danh sach uu tien mon dung muc tieu dinh duong, tranh di ung va nam trong ngan sach."
        )


FoodyLLMClient = FoodyLLM
