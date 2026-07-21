import { useState } from "react";
import { FlaskConical, Sparkles, Utensils } from "lucide-react";
import RecommendationSandbox from "./RecommendationSandbox.jsx";
import MealPlanSandbox from "./MealPlanSandbox.jsx";

const tabs = [
  { id: "recommendation", label: "Gợi ý công thức", icon: Sparkles },
  { id: "meal-plan", label: "Meal plan", icon: Utensils }
];

export default function AISandbox({ embedded = false }) {
  const [activeTab, setActiveTab] = useState("recommendation");

  return (
    <div className={embedded ? "ai-sandbox-tab-content" : "page-stack"}>
      {!embedded ? <div className="page-toolbar">
        <div>
          <p className="eyebrow">AI Sandbox</p>
          <h2>AI Sandbox</h2>
          <p>Test nhanh luồng AI gợi ý công thức và sinh meal plan trong cùng một màn hình.</p>
        </div>
      </div> : null}

      <section className="panel ai-sandbox-shell">
        <div className="panel-heading">
          <h2><FlaskConical size={20} /> Kịch bản test AI</h2>
          <div className="segmented-control ai-sandbox-tabs">
            {tabs.map(({ id, label, icon: Icon }) => (
              <button
                className={activeTab === id ? "active" : ""}
                key={id}
                type="button"
                onClick={() => setActiveTab(id)}
              >
                <Icon size={15} />
                {label}
              </button>
            ))}
          </div>
        </div>

        {activeTab === "recommendation" ? <RecommendationSandbox embedded /> : <MealPlanSandbox embedded />}
      </section>
    </div>
  );
}
