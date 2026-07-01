import { BarChart3, Heart, ThumbsDown, ThumbsUp } from "lucide-react";
import { feedbackMetrics } from "../../data/mockData.js";

const icons = [BarChart3, ThumbsUp, ThumbsDown, Heart];

export default function FeedbackEvaluation() {
  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">AI Evaluation</p>
          <h2>Feedback & Evaluation</h2>
          <p>Theo dõi chất lượng recommendation qua acceptance, confidence, like/dislike và truy vấn low confidence.</p>
        </div>
      </div>

      <section className="ai-feedback-grid">
        {feedbackMetrics.map((metric, index) => {
          const Icon = icons[index] ?? BarChart3;
          return (
            <article className="kpi-card compact-kpi" key={metric.label}>
              <div className="kpi-icon"><Icon size={18} /></div>
              <span>{metric.label}</span>
              <strong>{metric.value}</strong>
            </article>
          );
        })}
      </section>

      <section className="ai-banner compact">
        <div className="ai-icon"><BarChart3 size={22} /></div>
        <div>
          <h2>Evaluation Insight</h2>
          <p>Acceptance rate giảm nhẹ ở nhóm truy vấn keto dessert. Nên kiểm tra recipe coverage, allergy rule và prompt generation cho nhóm món tráng miệng ít carb.</p>
        </div>
      </section>
    </div>
  );
}
