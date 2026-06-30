import { Link } from "react-router-dom";
import { Database, Pencil, Plus, Search, Sparkles, Trash2 } from "lucide-react";
import { ingredients } from "../data/mockData.js";

export default function NutritionPage() {
  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div><p className="eyebrow">Nutrition Intelligence</p><h2>Cơ sở dữ liệu dinh dưỡng</h2></div>
        <Link className="primary-btn" to="/nutrition/new"><Plus size={17} /> Thêm nguyên liệu</Link>
      </div>

      <div className="filter-bar">
        <label className="field search-field"><Search size={16} /><input placeholder="Tìm theo tên nguyên liệu..." /></label>
        {["Tất cả", "Rau củ", "Protein", "Ngũ cốc", "Sữa"].map((item) => <button className={`chip ${item === "Tất cả" ? "active" : ""}`} key={item}>{item}</button>)}
      </div>

      <section className="kpi-grid four">
        <article className="kpi-card"><div className="kpi-icon"><Database size={18} /></div><span>Tổng nguyên liệu</span><strong>1,248</strong><small>Đã chuẩn hóa khẩu phần</small></article>
        <article className="kpi-card"><span>AI xác thực</span><strong>94%</strong><small>Độ tin cậy dữ liệu</small></article>
        <article className="kpi-card"><span>Cập nhật gần nhất</span><strong>24h</strong><small>USDA sync</small></article>
        <article className="kpi-card danger-card"><span>Cảnh báo</span><strong>3</strong><small>Dị ứng cần rà soát</small></article>
      </section>

      <section className="panel">
        <table className="data-table">
          <thead>
            <tr>
              <th>Nguyên liệu</th><th>Danh mục</th><th>Calories/100g</th><th>Protein</th><th>Carb</th><th>Fat</th><th>Fiber</th><th>Dị ứng</th><th>Cập nhật</th><th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            {ingredients.map((item, index) => (
              <tr key={item.id}>
                <td className="person-cell"><span className="food-icon">{index === 0 ? "🥕" : index === 1 ? "🍗" : index === 2 ? "🌰" : index === 3 ? "🌾" : "🥛"}</span><strong>{item.name}</strong></td>
                <td><span className="chip">{item.category}</span></td>
                <td>{item.calories} kcal</td><td>{item.protein}g</td><td>{item.carb}g</td><td>{item.fat}g</td><td>{item.fiber}g</td>
                <td>{item.allergen === "-" ? "-" : <span className="chip danger">{item.allergen}</span>}</td>
                <td>{item.updated}</td>
                <td className="actions-cell"><Link className="icon-link" to={`/nutrition/${item.id}/edit`}><Pencil size={16} /></Link><button className="icon-link"><Trash2 size={16} /></button></td>
              </tr>
            ))}
            <tr className="ai-row">
              <td colSpan="10"><Sparkles size={16} /> AI Insight: Quinoa vừa được cập nhật từ USDA. Mật độ vi chất cao hơn mức trung bình của nhóm ngũ cốc.</td>
            </tr>
          </tbody>
        </table>
        <div className="table-footer"><span>Hiển thị 1-5 trong 1,248 bản ghi</span><div className="pagination"><button>‹</button><button className="active">1</button><button>2</button><button>3</button><span>...</span><button>250</button><button>›</button></div></div>
      </section>
    </div>
  );
}
