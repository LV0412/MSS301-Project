import { useState } from "react";
import { BrainCircuit, FlaskConical, Upload } from "lucide-react";
import AIKnowledgeBase from "../components/ai/AIKnowledgeBase.jsx";
import AISandbox from "../components/ai/AISandbox.jsx";

const tabs = [
  { id: "knowledge", label: "Knowledge Base", icon: BrainCircuit },
  { id: "sandbox", label: "Test AI", icon: FlaskConical }
];

export default function AIKnowledgePage() {
  const [activeTab, setActiveTab] = useState("knowledge");

  return (
    <div className="page-stack ai-studio-page">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">NutriChef AI</p>
          <h2>AI Knowledge Studio</h2>
          <p>Quản lý knowledge source, indexing và test recommendation/meal plan trong cùng một luồng làm việc.</p>
        </div>
        <button className="primary-btn"><Upload size={16} /> Upload nguồn</button>
      </div>

      <section className="panel ai-studio-shell">
        <div className="panel-heading">
          <h2><BrainCircuit size={20} /> Knowledge & Testing</h2>
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

        {activeTab === "knowledge" ? <AIKnowledgeBase embedded /> : <AISandbox embedded />}
      </section>
    </div>
  );
}
