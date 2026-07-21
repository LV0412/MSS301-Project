import { BrainCircuit, Eye, FileText, RefreshCw, Send, ShieldAlert, Sparkles, Trash2, Upload } from "lucide-react";
import { knowledgeSources } from "../../data/mockData.js";
import RecipeIndexCard from "./RecipeIndexCard.jsx";

export default function AIKnowledgeBase({ embedded = false }) {
  return (
    <div className={embedded ? "ai-knowledge-tab-content" : "page-stack"}>
      {!embedded ? <div className="page-toolbar">
        <div><p className="eyebrow">NutriChef AI</p><h2>AI Knowledge Base</h2><p>Quản lý dataset proprietary dùng cho nutrition intelligence và RAG retrieval.</p></div>
        <button className="primary-btn"><Upload size={16} /> Upload nguồn</button>
      </div> : null}

      <section className="knowledge-layout">
        <div className="page-stack">
          <RecipeIndexCard />

          <article className="panel">
            <div className="panel-heading"><h2>Nguồn tri thức</h2><span className="chip active">Indexing đang hoạt động</span></div>
            <div className="table-scroll">
              <table className="data-table ai-knowledge-table">
                <thead><tr><th>Tài liệu</th><th>Loại</th><th>Scope</th><th>Version</th><th>Trạng thái</th><th>Last Updated</th><th>Chunks</th><th>Actions</th></tr></thead>
                <tbody>
                  {knowledgeSources.map((source) => (
                    <tr key={source.id}>
                      <td className="person-cell"><FileText size={17} /><strong>{source.name}</strong></td>
                      <td><span className="chip">{source.type}</span></td>
                      <td>{source.scope}</td>
                      <td>{source.version}</td>
                      <td><span className={source.status.includes("Đang") ? "status-dot warning" : "status-dot"}>{source.status}</span></td>
                      <td>{source.updated}</td>
                      <td>{source.chunks}</td>
                      <td className="actions-cell knowledge-actions">
                        <button className="icon-link" title="View chunks"><Eye size={16} /></button>
                        <button className="icon-link" title="Re-index"><RefreshCw size={16} /></button>
                        <button className="ghost-mini-btn">Disable</button>
                        <button className="icon-link danger-icon" title="Delete"><Trash2 size={16} /></button>
                        <button className="ghost-mini-btn">Errors</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </article>

          <div className="two-col-panels">
            <article className="ai-note-card"><Sparkles size={18} /><strong>AI Insight</strong><p>Coverage cho "Keto Dessert Alternatives" tăng 40% sau lần upload mới nhất.</p></article>
            <article className="health-card"><ShieldAlert size={18} /><strong>Health Check</strong><p>Vector store latency tăng nhẹ lên 82ms. Cân nhắc prune dataset công thức 2021.</p></article>
          </div>
        </div>

        <aside className="retrieval-panel">
          <h2><BrainCircuit size={18} /> Retrieval Sandbox</h2>
          <p>Kiểm tra mapping nguồn RAG và confidence.</p>
          <label>Query simulation<textarea defaultValue="Nhu cầu protein cho nam 35 tuổi là bao nhiêu?" /></label>
          <button className="send-btn"><Send size={20} /></button>
          <span className="eyebrow">Answer preview · confidence 94%</span>
          <div className="answer-box">Dựa trên WHO Nutrition Guidelines 2024, lượng protein khuyến nghị cho nam 35 tuổi khỏe mạnh khoảng 0.83g/kg cân nặng/ngày...</div>
          <h3>Source citations</h3>
          <span className="citation">WHO_Nutrition_2024 · Chunk #82</span>
          <span className="citation">Safety_Protocols_v1 · Chunk #12</span>
          <div className="warning-panel mini"><ShieldAlert size={16} /><span>Không dùng câu trả lời AI thay thế tư vấn y tế.</span></div>
          <button className="brown-btn"><RefreshCw size={16} /> Re-index</button>
        </aside>
      </section>
    </div>
  );
}
