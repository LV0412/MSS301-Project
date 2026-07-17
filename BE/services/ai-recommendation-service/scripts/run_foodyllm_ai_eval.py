import argparse
import json
import os
import statistics
import sys
import time
from pathlib import Path
from typing import Any


SERVICE_ROOT = Path(__file__).resolve().parents[1]
if str(SERVICE_ROOT) not in sys.path:
    sys.path.insert(0, str(SERVICE_ROOT))


DATASET_PATH = SERVICE_ROOT / "data" / "evaluation" / "foodyllm_ai_eval.json"
REPORTS_DIR = SERVICE_ROOT / "reports"


def _configure_provider(use_real_foodyllm: bool) -> None:
    if not use_real_foodyllm:
        os.environ["AI_LLM_PROVIDER"] = "local"


def _load_cases(path: Path) -> list[dict[str, Any]]:
    with path.open("r", encoding="utf-8") as dataset_file:
        cases = json.load(dataset_file)
    if not isinstance(cases, list):
        raise ValueError(f"Evaluation dataset must be a JSON list: {path}")
    return cases


def _run_case(case: dict[str, Any]) -> dict[str, Any]:
    from api import recommendation as recommendation_api
    from dto.request import RecommendationRequest

    # Keep this benchmark focused on the AI service layer. If Recipe Service is
    # not running, avoid spending retries on localhost and use the local corpus.
    recommendation_api.recipe_service_client.search_recipe_documents = lambda **_kwargs: []

    request = RecommendationRequest(**case["request"])
    started_at = time.perf_counter()
    response = recommendation_api.recommend(request)
    latency_ms = round((time.perf_counter() - started_at) * 1000, 2)
    recommendations = [item.model_dump() for item in response.recommendations]
    predicted_ids = [str(item["recipe_id"]) for item in recommendations]
    expected_ids = [str(item) for item in case.get("expected_recipe_ids", [])]

    return {
        "id": case["id"],
        "foodyllm_task": case["foodyllm_task"],
        "description": case["description"],
        "request": case["request"],
        "expected_recipe_ids": expected_ids,
        "predicted_recipe_ids": predicted_ids,
        "recommendations": recommendations,
        "stages": response.stages,
        "explanation": response.explanation,
        "latency_ms": latency_ms,
        "metrics": _case_metrics(case, recommendations, response.stages),
    }


def _case_metrics(case: dict[str, Any], recommendations: list[dict[str, Any]], stages: list[str]) -> dict[str, Any]:
    expected_ids = [str(item) for item in case.get("expected_recipe_ids", [])]
    predicted_ids = [str(item["recipe_id"]) for item in recommendations]
    top1_id = predicted_ids[0] if predicted_ids else None
    reciprocal_rank = 0.0
    for index, recipe_id in enumerate(predicted_ids, start=1):
        if recipe_id in expected_ids:
            reciprocal_rank = 1.0 / index
            break

    top_items = recommendations[:3]
    return {
        "has_recommendations": bool(recommendations),
        "hit_at_1": top1_id in expected_ids if top1_id else False,
        "hit_at_3": any(recipe_id in expected_ids for recipe_id in predicted_ids[:3]),
        "reciprocal_rank": reciprocal_rank,
        "foodyllm_stage_present": "foodyllm_json_scoring" in stages,
        "top3_constraints_ok": _top_items_constraints_ok(case["request"], top_items),
        "top1_suitability_score": _float_value(top_items[0].get("suitability_score")) if top_items else 0.0,
    }


def _top_items_constraints_ok(request: dict[str, Any], items: list[dict[str, Any]]) -> dict[str, bool]:
    return {
        "calories": all(
            request.get("max_calories") is None or item["calories"] <= int(request["max_calories"])
            for item in items
        ),
        "protein": all(
            request.get("min_protein") is None or item["protein"] >= int(request["min_protein"])
            for item in items
        ),
        "budget": all(
            request.get("budget") is None or item["estimated_cost"] <= int(request["budget"])
            for item in items
        ),
        "diet": all(_diet_ok(request.get("diet"), item) for item in items),
        "allergy": all(_allergy_ok(request.get("allergies", []), item) for item in items),
    }


def _diet_ok(diet: str | None, item: dict[str, Any]) -> bool:
    if not diet or diet in {"normal", "balanced", "healthy"}:
        return True
    return diet.lower() in {str(tag).lower() for tag in item.get("tags", [])}


def _allergy_ok(allergies: list[str], item: dict[str, Any]) -> bool:
    if not allergies:
        return True
    haystack = " ".join([item.get("name", ""), *item.get("tags", []), *item.get("warnings", [])]).lower()
    return not any(str(allergy).strip().lower() in haystack for allergy in allergies if str(allergy).strip())


def _float_value(value: Any) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


def _aggregate(results: list[dict[str, Any]]) -> dict[str, Any]:
    total = len(results)
    metric_rows = [result["metrics"] for result in results]
    constraint_keys = ["calories", "protein", "budget", "diet", "allergy"]
    by_task: dict[str, list[dict[str, Any]]] = {}
    for result in results:
        by_task.setdefault(result["foodyllm_task"], []).append(result["metrics"])

    return {
        "dataset": str(DATASET_PATH.relative_to(SERVICE_ROOT)),
        "total_cases": total,
        "hit_at_1": _rate(metric_rows, "hit_at_1"),
        "hit_at_3": _rate(metric_rows, "hit_at_3"),
        "mean_reciprocal_rank": round(statistics.mean(row["reciprocal_rank"] for row in metric_rows), 4),
        "recommendation_coverage": _rate(metric_rows, "has_recommendations"),
        "foodyllm_stage_coverage": _rate(metric_rows, "foodyllm_stage_present"),
        "avg_latency_ms": round(statistics.mean(result["latency_ms"] for result in results), 2),
        "avg_top1_suitability_score": round(statistics.mean(row["top1_suitability_score"] for row in metric_rows), 2),
        "top3_constraint_compliance": {
            key: _constraint_rate(metric_rows, key)
            for key in constraint_keys
        },
        "by_foodyllm_task": {
            task: {
                "cases": len(rows),
                "hit_at_3": _rate(rows, "hit_at_3"),
                "mean_reciprocal_rank": round(statistics.mean(row["reciprocal_rank"] for row in rows), 4),
            }
            for task, rows in sorted(by_task.items())
        },
    }


def _rate(rows: list[dict[str, Any]], key: str) -> float:
    if not rows:
        return 0.0
    return round(sum(1 for row in rows if row[key]) / len(rows), 4)


def _constraint_rate(rows: list[dict[str, Any]], key: str) -> float:
    if not rows:
        return 0.0
    return round(sum(1 for row in rows if row["top3_constraints_ok"][key]) / len(rows), 4)


def _write_outputs(results: list[dict[str, Any]], summary: dict[str, Any], output_dir: Path) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    predictions_path = output_dir / "foodyllm_ai_eval_predictions.jsonl"
    metrics_path = output_dir / "foodyllm_ai_eval_metrics.json"
    report_path = output_dir / "foodyllm_ai_eval_report.md"

    with predictions_path.open("w", encoding="utf-8") as predictions_file:
        for result in results:
            predictions_file.write(json.dumps(result, ensure_ascii=False) + "\n")
    metrics_path.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    report_path.write_text(_render_report(results, summary), encoding="utf-8")
    return {
        "predictions": predictions_path,
        "metrics": metrics_path,
        "report": report_path,
    }


def _render_report(results: list[dict[str, Any]], summary: dict[str, Any]) -> str:
    lines = [
        "# FoodyLLM-Based AI Recommendation Evaluation",
        "",
        "This evaluation uses a FoodyLLM-inspired dataset derived from the original FoodyLLM task family: nutrition profile assessment, traffic-light nutrition screening, and food entity/allergy safety. The AI service applies those model capabilities inside the app pipeline: rule filtering, hybrid RAG retrieval, FoodyLLM JSON scoring, and meal optimization.",
        "",
        "## Summary Metrics",
        "",
        f"- Total cases: {summary['total_cases']}",
        f"- Hit@1: {summary['hit_at_1']}",
        f"- Hit@3: {summary['hit_at_3']}",
        f"- MRR: {summary['mean_reciprocal_rank']}",
        f"- Recommendation coverage: {summary['recommendation_coverage']}",
        f"- FoodyLLM stage coverage: {summary['foodyllm_stage_coverage']}",
        f"- Average latency ms: {summary['avg_latency_ms']}",
        f"- Average top-1 suitability score: {summary['avg_top1_suitability_score']}",
        "",
        "## Top-3 Constraint Compliance",
        "",
    ]
    for key, value in summary["top3_constraint_compliance"].items():
        lines.append(f"- {key}: {value}")

    lines.extend(["", "## Metrics By FoodyLLM Task", "", "| Task | Cases | Hit@3 | MRR |", "|---|---:|---:|---:|"])
    for task, task_metrics in summary["by_foodyllm_task"].items():
        lines.append(
            f"| {task} | {task_metrics['cases']} | {task_metrics['hit_at_3']} | {task_metrics['mean_reciprocal_rank']} |"
        )

    lines.extend(["", "## Case-Level Results", "", "| Case | Task | Expected Hit@3 | Top Recommendations | Latency ms |", "|---|---|---:|---|---:|"])
    for result in results:
        top_names = ", ".join(item["name"] for item in result["recommendations"][:3])
        lines.append(
            f"| {result['id']} | {result['foodyllm_task']} | {result['metrics']['hit_at_3']} | {top_names} | {result['latency_ms']} |"
        )
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Evaluate the AI service with a FoodyLLM-inspired dataset.")
    parser.add_argument("--dataset", type=Path, default=DATASET_PATH)
    parser.add_argument("--output-dir", type=Path, default=REPORTS_DIR)
    parser.add_argument("--use-real-foodyllm", action="store_true", help="Do not force local fallback; load the configured FoodyLLM model.")
    args = parser.parse_args()

    _configure_provider(args.use_real_foodyllm)
    cases = _load_cases(args.dataset)
    results = [_run_case(case) for case in cases]
    summary = _aggregate(results)
    paths = _write_outputs(results, summary, args.output_dir)

    print(json.dumps(summary, indent=2, ensure_ascii=False))
    for label, path in paths.items():
        print(f"{label}: {path}")


if __name__ == "__main__":
    main()
