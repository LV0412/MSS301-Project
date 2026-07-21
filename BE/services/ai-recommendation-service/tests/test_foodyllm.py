from llm.foodyllm import FoodyLLM


def test_parse_json_payload_accepts_markdown_fence():
    payload = FoodyLLM()._parse_json_payload(
        "```json\n{\"recommendations\":[{\"recipe_id\":\"1\",\"suitability_score\":90}]}\n```"
    )
    assert payload["recommendations"][0]["recipe_id"] == "1"
