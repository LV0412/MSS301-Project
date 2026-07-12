from dataclasses import dataclass
from typing import Any

from dto.request import RecommendationRequest
from rag.vector_store import RecipeDocument


@dataclass(frozen=True)
class RuleEngineResult:
    candidates: list[RecipeDocument]
    warnings: list[str]


class RuleEngine:
    """Applies hard safety and nutrition constraints before RAG ranking."""

    def filter(
        self,
        candidates: list[RecipeDocument],
        request: RecommendationRequest,
        user_profile: dict[str, Any] | None = None,
    ) -> RuleEngineResult:
        accepted: list[RecipeDocument] = []
        warnings: list[str] = []
        rejected_count = 0

        for candidate in candidates:
            violations = self._violations(candidate, request)
            if violations:
                rejected_count += 1
                if len(warnings) < 5:
                    warnings.append(f"{candidate.name}: {', '.join(violations)}")
                continue
            accepted.append(candidate)

        if rejected_count > len(warnings):
            warnings.append(f"Da loai {rejected_count - len(warnings)} mon khac do vi pham rule engine.")
        if not accepted and candidates:
            warnings.append("Khong con mon nao sau khi loc di ung, diet va dinh duong.")
        if user_profile:
            warnings.extend(self._profile_warnings(user_profile))

        return RuleEngineResult(candidates=accepted, warnings=warnings)

    def _violations(self, candidate: RecipeDocument, request: RecommendationRequest) -> list[str]:
        violations: list[str] = []

        if self._has_allergy_match(candidate, request.allergies):
            violations.append("trung di ung")
        if request.diet and not self._matches_diet(candidate, request.diet):
            violations.append(f"khong dung diet {request.diet}")
        if request.max_calories and candidate.calories > request.max_calories:
            violations.append(f"vuot {request.max_calories} kcal")
        if request.min_protein and candidate.protein < request.min_protein:
            violations.append(f"duoi {request.min_protein}g protein")
        if request.max_carbs and self._metadata_int(candidate, "carbs") > request.max_carbs:
            violations.append(f"vuot {request.max_carbs}g carbs")
        if request.max_fat and self._metadata_int(candidate, "fat") > request.max_fat:
            violations.append(f"vuot {request.max_fat}g fat")
        if request.budget and candidate.estimated_cost and candidate.estimated_cost > request.budget:
            violations.append(f"vuot ngan sach {request.budget} VND")

        return violations

    def _has_allergy_match(self, candidate: RecipeDocument, allergies: list[str]) -> bool:
        if not allergies:
            return False
        allergy_terms = {item.strip().lower() for item in allergies if item.strip()}
        if not allergy_terms:
            return False

        metadata_allergens = candidate.metadata.get("allergens", [])
        if not isinstance(metadata_allergens, list):
            metadata_allergens = []
        metadata_terms = {str(item).lower() for item in metadata_allergens}
        document_text = f"{candidate.name} {candidate.text} {' '.join(candidate.tags)}".lower()

        return any(term in metadata_terms or term in document_text for term in allergy_terms)

    def _matches_diet(self, candidate: RecipeDocument, diet: str) -> bool:
        normalized_diet = diet.strip().lower()
        if not normalized_diet:
            return True

        diet_values = candidate.metadata.get("diet", [])
        if not isinstance(diet_values, list):
            diet_values = []
        candidate_terms = {str(item).lower() for item in [*candidate.tags, *diet_values]}

        if normalized_diet in {"normal", "balanced", "healthy"}:
            return True
        return normalized_diet in candidate_terms

    def _metadata_int(self, candidate: RecipeDocument, key: str) -> int:
        try:
            return int(candidate.metadata.get(key, 0) or 0)
        except (TypeError, ValueError):
            return 0

    def _profile_warnings(self, user_profile: dict[str, Any]) -> list[str]:
        warnings: list[str] = []
        medical_notes = user_profile.get("medicalNotes") or user_profile.get("medical_notes")
        if medical_notes:
            warnings.append(f"Luu y ho so suc khoe: {medical_notes}")
        return warnings
