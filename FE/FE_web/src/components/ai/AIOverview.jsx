import { Activity, Bot, Clock, Database, FileText, ShieldAlert, Sparkles, Utensils } from "lucide-react";
import { aiOverviewCards } from "../../data/mockData.js";
import AILogs from "./AILogs.jsx";

const icons = [Activity, Bot, Sparkles, Database, Utensils, FileText, Clock, Clock, ShieldAlert, Sparkles];

export default function AIOverview() {
  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">AI Service</p>
          <h2>AI Overview</h2>
          <p>Theo dõi model, vector database, recipe indexing, latency và lượng recommendation trong ngày.</p>
        </div>
      </div>

      <section className="ai-service-grid">
        {aiOverviewCards.map((card, index) => {
          const Icon = icons[index] ?? Sparkles;
          return (
            <article className={`kpi-card ai-service-card ${card.tone ?? ""}`} key={card.label}>
              <div className="kpi-icon"><Icon size={19} /></div>
              <span>{card.label}</span>
              <strong>{card.value}</strong>
              <small>{card.note}</small>
            </article>
          );
        })}
      </section>

      <section className="ai-flow-panel">
        {["RAG Retrieval", "Rule Filtering", "Nutrition Scoring", "FoodyLLM Generation", "Monitoring"].map((step) => (
          <div className="ai-flow-step" key={step}>
            <span>{step}</span>
            <strong>Hoạt động</strong>
          </div>
        ))}
      </section>
      <AILogs embedded />
    </div>
  );
}
