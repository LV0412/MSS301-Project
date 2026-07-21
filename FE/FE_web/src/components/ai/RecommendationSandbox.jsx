import { useState } from "react";
import { AlertTriangle, SearchCheck, Sparkles } from "lucide-react";
import { recommendationResults } from "../../data/mockData.js";

export default function RecommendationSandbox({ embedded = false }) {
  const [state, setState] = useState("ready");

  function runSimulation(event) {
    event.preventDefault();
    setState("loading");
    window.setTimeout(() => setState("results"), 450);
  }

  return (
    <div className={embedded ? "ai-sandbox-tab-content" : "page-stack"}>
      {!embedded ? <div className="page-toolbar">
        <div>
          <p className="eyebrow">AI Sandbox</p>
          <h2>Recommendation Sandbox</h2>
          <p>Test gợi ý món ăn theo user context, allergy filtering, nutrition scoring và citation.</p>
        </div>
      </div> : null}

      <section className="ai-sandbox-layout">
        <form className="panel ai-sandbox-form" onSubmit={runSimulation}>
          <div className="form-grid">
            <label>User ID<input defaultValue="elena" /></label>
            <label>Meal Type<select defaultValue="Lunch"><option>Breakfast</option><option>Lunch</option><option>Dinner</option><option>Snack</option></select></label>
            <label>Goal<select defaultValue="Weight loss"><option>Weight loss</option><option>Muscle gain</option><option>Maintain weight</option><option>Healthy eating</option></select></label>
            <label>Diet Preference<select defaultValue="Mediterranean"><option>Low carb</option><option>High protein</option><option>Vegetarian</option><option>Keto</option><option>Mediterranean</option></select></label>
            <label>Allergies<input defaultValue="Sữa, Đậu phộng" /></label>
            <label>Target Calories<input type="number" defaultValue="450" /></label>
            <label>Limit<input type="number" defaultValue="5" /></label>
            <label className="span-2">Query text<textarea defaultValue="Gợi ý bữa trưa giàu protein, ít calo, không chứa sữa." /></label>
          </div>
          <div className="button-row">
            <button className="primary-btn" type="submit"><SearchCheck size={16} /> Chạy recommendation</button>
            <button className="ghost-btn" type="button" onClick={() => setState("empty")}>Empty state</button>
            <button className="ghost-btn" type="button" onClick={() => setState("error")}>Error state</button>
          </div>
        </form>

        <section className="panel ai-result-panel">
          <div className="panel-heading">
            <h2><Sparkles size={20} /> Kết quả gợi ý</h2>
            <span className="chip active">FoodyLLM + RAG</span>
          </div>

          {state === "ready" ? <div className="empty-state">Nhập context và chạy test để xem recipe recommendations.</div> : null}
          {state === "loading" ? <div className="empty-state">Đang retrieval, lọc dị ứng và scoring dinh dưỡng...</div> : null}
          {state === "empty" ? <div className="empty-state">Không tìm thấy công thức phù hợp với ràng buộc hiện tại.</div> : null}
          {state === "error" ? <div className="warning-panel"><AlertTriangle size={18} /><span>AI Service timeout khi gọi FoodyLLM. Vui lòng thử lại hoặc chuyển sang mock mode.</span></div> : null}

          {state === "results" ? (
            <div className="ai-result-list">
              {recommendationResults.map((recipe) => (
                <article className="ai-result-card" key={recipe.id}>
                  <div>
                    <span className="chip">{recipe.id}</span>
                    <h3>{recipe.name}</h3>
                    <p>{recipe.reason}</p>
                  </div>
                  <div className="ai-result-metrics">
                    <span>Score <strong>{recipe.score}</strong></span>
                    <span>{recipe.calories} kcal</span>
                    <span>P {recipe.protein}g</span>
                    <span>C {recipe.carbs}g</span>
                    <span>F {recipe.fat}g</span>
                  </div>
                  <div className="chip-row">
                    <span className="chip active">Nutrition Match {recipe.nutritionMatch}</span>
                    <span className={`chip ${recipe.allergySafety === "An toàn" ? "" : "danger"}`}>{recipe.allergySafety}</span>
                    <span className="chip">{recipe.source}</span>
                  </div>
                </article>
              ))}
            </div>
          ) : null}
        </section>
      </section>
    </div>
  );
}
