import { useMemo, useState } from "react";
import { AlertTriangle, ChefHat, SearchCheck, Sparkles } from "lucide-react";
import { getAiRecommendations } from "../../api/aiRecommendation.js";

const mealTypes = [
  { label: "Bữa sáng", value: "breakfast" },
  { label: "Bữa trưa", value: "lunch" },
  { label: "Bữa tối", value: "dinner" },
  { label: "Bữa phụ", value: "snack" }
];

const dietOptions = [
  { label: "Không chọn", value: "" },
  { label: "Thông thường", value: "normal" },
  { label: "Chay", value: "vegetarian" },
  { label: "Thuần chay", value: "vegan" },
  { label: "Keto", value: "keto" },
  { label: "Ít carb", value: "low_carb" }
];

const goalOptions = [
  { label: "Không chọn", value: "" },
  { label: "Giảm cân", value: "weight_loss" },
  { label: "Tăng cơ", value: "muscle_gain" },
  { label: "Duy trì", value: "maintain" },
  { label: "Ăn lành mạnh", value: "healthy" }
];

const initialForm = {
  userId: "",
  mealType: "lunch",
  goal: "healthy",
  diet: "",
  allergies: "",
  availableIngredients: "",
  targetCalories: "500",
  maxCalories: "650",
  minProtein: "20",
  maxCarbs: "",
  maxFat: "",
  budget: "",
  limit: "5",
  strictIngredients: false,
  query: "Gợi ý bữa trưa giàu protein, ít calo."
};

function splitTokens(value) {
  return value
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);
}

function optionalNumber(value) {
  if (value === "" || value === null || value === undefined) return undefined;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
}

function formatScore(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed.toFixed(1) : "0.0";
}

function warningItems(result) {
  const recipeWarnings = (result?.recommendations || []).flatMap((recipe) => recipe.warnings || []);
  return [...new Set([...(result?.warnings || []), ...recipeWarnings])];
}

export default function RecommendationSandbox({ embedded = false }) {
  const [form, setForm] = useState(initialForm);
  const [state, setState] = useState("ready");
  const [result, setResult] = useState(null);
  const [error, setError] = useState("");

  const canSubmit = useMemo(() => {
    const userIdValid = !form.userId.trim() || /^[1-9]\d*$/.test(form.userId.trim());
    return form.query.trim().length >= 2 && userIdValid && Number(form.limit) >= 1;
  }, [form]);

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
  }

  async function runRecommendation(event) {
    event.preventDefault();
    if (!canSubmit) return;

    setState("loading");
    setError("");
    setResult(null);

    const userId = form.userId.trim();
    const payload = {
      query: form.query.trim(),
      meal_type: form.mealType || undefined,
      diet: form.diet || undefined,
      goal: form.goal || undefined,
      allergies: splitTokens(form.allergies),
      available_ingredients: splitTokens(form.availableIngredients),
      target_calories: optionalNumber(form.targetCalories),
      max_calories: optionalNumber(form.maxCalories),
      min_protein: optionalNumber(form.minProtein),
      max_carbs: optionalNumber(form.maxCarbs),
      max_fat: optionalNumber(form.maxFat),
      budget: optionalNumber(form.budget),
      strict_ingredients: form.strictIngredients,
      limit: optionalNumber(form.limit) || 5,
      use_user_profile: false
    };

    if (userId) payload.user_id = userId;

    try {
      const response = await getAiRecommendations(payload);
      setResult(response);
      setState(response.recommendations?.length ? "results" : "empty");
    } catch (requestError) {
      setError(requestError.message || "Không gọi được AI Recommendation Service.");
      setState("error");
    }
  }

  const warnings = warningItems(result);

  return (
    <div className={embedded ? "ai-sandbox-tab-content" : "page-stack"}>
      {!embedded ? (
        <div className="page-toolbar">
          <div>
            <p className="eyebrow">AI Sandbox</p>
            <h2>Recommendation Sandbox</h2>
            <p>Test gợi ý công thức bằng AI Recommendation Service.</p>
          </div>
        </div>
      ) : null}

      <section className="ai-sandbox-layout recommendation-sandbox-layout">
        <form className="panel ai-sandbox-form recommendation-form" onSubmit={runRecommendation}>
          <div className="panel-heading">
            <div>
              <p className="eyebrow">Input</p>
              <h2><ChefHat size={20} /> Điều kiện gợi ý</h2>
            </div>
          </div>

          <label className="recommendation-query">
            Nội dung yêu cầu
            <textarea value={form.query} onChange={(event) => updateField("query", event.target.value)} />
          </label>

          <div className="recommendation-form-grid">
            <label>
              User ID
              <input placeholder="Ví dụ: 1" value={form.userId} onChange={(event) => updateField("userId", event.target.value)} />
            </label>
            <label>
              Bữa ăn
              <select value={form.mealType} onChange={(event) => updateField("mealType", event.target.value)}>
                {mealTypes.map((item) => <option key={item.value} value={item.value}>{item.label}</option>)}
              </select>
            </label>
            <label>
              Mục tiêu
              <select value={form.goal} onChange={(event) => updateField("goal", event.target.value)}>
                {goalOptions.map((item) => <option key={item.value} value={item.value}>{item.label}</option>)}
              </select>
            </label>
            <label>
              Chế độ ăn
              <select value={form.diet} onChange={(event) => updateField("diet", event.target.value)}>
                {dietOptions.map((item) => <option key={item.value} value={item.value}>{item.label}</option>)}
              </select>
            </label>
            <label className="wide-field">
              Dị ứng
              <input placeholder="Sữa, đậu phộng hoặc allergen:2" value={form.allergies} onChange={(event) => updateField("allergies", event.target.value)} />
            </label>
            <label className="wide-field">
              Nguyên liệu có sẵn
              <input placeholder="Ức gà, cà chua" value={form.availableIngredients} onChange={(event) => updateField("availableIngredients", event.target.value)} />
            </label>
            <label>
              Calories mục tiêu
              <input type="number" min="1" value={form.targetCalories} onChange={(event) => updateField("targetCalories", event.target.value)} />
            </label>
            <label>
              Calories tối đa
              <input type="number" min="1" value={form.maxCalories} onChange={(event) => updateField("maxCalories", event.target.value)} />
            </label>
            <label>
              Protein tối thiểu
              <input type="number" min="0" value={form.minProtein} onChange={(event) => updateField("minProtein", event.target.value)} />
            </label>
            <label>
              Số kết quả
              <input type="number" min="1" max="20" value={form.limit} onChange={(event) => updateField("limit", event.target.value)} />
            </label>
          </div>

          <details className="advanced-ai-options">
            <summary>Tùy chọn nâng cao</summary>
            <div className="recommendation-form-grid">
              <label>
                Carb tối đa
                <input type="number" min="0" value={form.maxCarbs} onChange={(event) => updateField("maxCarbs", event.target.value)} />
              </label>
              <label>
                Fat tối đa
                <input type="number" min="0" value={form.maxFat} onChange={(event) => updateField("maxFat", event.target.value)} />
              </label>
              <label>
                Ngân sách
                <input type="number" min="1" value={form.budget} onChange={(event) => updateField("budget", event.target.value)} />
              </label>
              <label className="toggle-row">
                <input
                  type="checkbox"
                  checked={form.strictIngredients}
                  onChange={(event) => updateField("strictIngredients", event.target.checked)}
                />
                Chỉ dùng nguyên liệu có sẵn
              </label>
            </div>
          </details>

          <button className="primary-btn recommendation-submit" type="submit" disabled={!canSubmit || state === "loading"}>
            <SearchCheck size={16} />
            {state === "loading" ? "Đang gọi AI..." : "Chạy recommendation"}
          </button>
        </form>

        <section className="panel ai-result-panel recommendation-result-panel">
          <div className="panel-heading recommendation-result-heading">
            <div>
              <p className="eyebrow">Output</p>
              <h2><Sparkles size={20} /> Kết quả gợi ý</h2>
            </div>
            {result?.llm_mode ? <span className="chip active">{result.llm_provider} · {result.llm_mode}</span> : null}
          </div>

          {state === "ready" ? <div className="empty-state">Nhập điều kiện rồi chạy recommendation.</div> : null}
          {state === "loading" ? <div className="empty-state">Đang tải dữ liệu từ AI Recommendation Service...</div> : null}
          {state === "empty" ? <div className="empty-state">Không có công thức phù hợp.</div> : null}
          {state === "error" ? (
            <div className="warning-panel">
              <AlertTriangle size={18} />
              <span>{error}</span>
            </div>
          ) : null}

          {state === "results" ? (
            <div className="ai-result-list recommendation-result-list">
              {result.recommendations.map((recipe, index) => (
                <article className="ai-result-card recommendation-result-card" key={recipe.recipe_id}>
                  <div className="recommendation-card-rank">#{index + 1}</div>
                  <div className="recommendation-card-body">
                    <div className="recommendation-card-top">
                      <div>
                        <span className="chip">Recipe #{recipe.recipe_id}</span>
                        <h3>{recipe.name}</h3>
                      </div>
                      <div className="recommendation-score">
                        <span>Score</span>
                        <strong>{formatScore(recipe.suitability_score)}</strong>
                      </div>
                    </div>

                    {recipe.reason ? <p>{recipe.reason}</p> : null}

                    <div className="ai-result-metrics recommendation-metrics">
                      <span><strong>{recipe.calories}</strong> kcal</span>
                      <span><strong>{recipe.protein}</strong>g protein</span>
                      <span><strong>{recipe.carbs}</strong>g carb</span>
                      <span><strong>{recipe.fat}</strong>g fat</span>
                      <span><strong>{Math.round(recipe.ingredient_match_ratio * 100)}%</strong> match</span>
                    </div>

                    <div className="chip-row compact-chip-row">
                      <span className="chip active">{recipe.source}</span>
                      {recipe.tags?.slice(0, 4).map((tag) => <span className="chip" key={tag}>{tag}</span>)}
                    </div>
                  </div>
                </article>
              ))}

              {warnings.length ? (
                <article className="warning-panel recommendation-warning-list">
                  <AlertTriangle size={18} />
                  <div>
                    <strong>Cảnh báo</strong>
                    <ul>
                      {warnings.map((warning) => <li key={warning}>{warning}</li>)}
                    </ul>
                  </div>
                </article>
              ) : null}
            </div>
          ) : null}
        </section>
      </section>
    </div>
  );
}
