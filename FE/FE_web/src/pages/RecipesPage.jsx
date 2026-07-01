import { Link } from "react-router-dom";
import {
  Archive,
  BookOpen,
  CheckCircle2,
  Copy,
  Eye,
  FileUp,
  MoreVertical,
  Pencil,
  Plus,
  RefreshCw,
  Search,
  ShieldCheck,
  Sparkles,
  Star,
  Tags
} from "lucide-react";
import { recipes } from "../data/mockData.js";
import {
  archiveRecipe,
  duplicateRecipe,
  hideRecipe,
  importRecipeDataset,
  recalculateNutrition,
  runRecipeSafetyCheck,
  viewRecipeHistory
} from "../api/recipeManagement.js";

const stats = [
  { label: "Tổng công thức", value: "1,284", note: "Toàn bộ kho công thức", icon: BookOpen },
  { label: "Đã xuất bản", value: "942", note: "Đang hiển thị trên ứng dụng", icon: CheckCircle2 },
  { label: "Bản nháp", value: "214", note: "Đang biên tập", icon: Pencil },
  { label: "Cần duyệt AI", value: "46", note: "Công thức AI tạo/chỉnh sửa đang chờ kiểm duyệt", icon: Sparkles, warm: true },
  { label: "Đánh giá TB", value: "4.8", note: "Từ 50k+ review", icon: Star }
];

const recipeRows = [
  { ...recipes[0], safety: "OK", source: "Chuyên gia duyệt", statusLabel: "Đã xuất bản" },
  { ...recipes[1], safety: "Natri cao", source: "AI tạo", statusLabel: "Chờ duyệt" },
  { ...recipes[2], safety: "Thiếu allergen", source: "Import", statusLabel: "Cần chỉnh sửa" },
  { ...recipes[3], safety: "Cần kiểm tra", source: "Thủ công", statusLabel: "Bản nháp" }
];

function requestReason(actionLabel, recipeName) {
  return window.prompt(`Nhập lý do để ${actionLabel.toLowerCase()} "${recipeName}":`);
}

async function runRowAction(action, recipe) {
  if (action.requiresReason) {
    const reason = requestReason(action.label, recipe.name);
    if (!reason) return;
    if (!window.confirm(`Xác nhận ${action.label.toLowerCase()} công thức "${recipe.name}"?`)) return;
    await action.handler(recipe.id, reason);
    return;
  }

  if (action.confirm && !window.confirm(`Xác nhận ${action.label.toLowerCase()} công thức "${recipe.name}"?`)) return;
  await action.handler(recipe.id);
}

const moreActions = [
  { label: "Nhân bản công thức", icon: Copy, handler: duplicateRecipe },
  { label: "Chạy kiểm tra an toàn", icon: ShieldCheck, handler: runRecipeSafetyCheck },
  { label: "Tính lại dinh dưỡng", icon: RefreshCw, handler: recalculateNutrition },
  { label: "Ẩn khỏi ứng dụng", icon: Eye, handler: hideRecipe, requiresReason: true },
  { label: "Lưu trữ", icon: Archive, handler: archiveRecipe, requiresReason: true, danger: true },
  { label: "Xem lịch sử chỉnh sửa", icon: Tags, handler: viewRecipeHistory }
];

function safetyClass(value) {
  if (value === "OK") return "ok";
  if (value === "Natri cao" || value === "Đường cao") return "warning";
  if (value === "Thiếu allergen" || value === "Diet conflict") return "danger";
  return "review";
}

export default function RecipesPage() {
  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">Recipe Operations</p>
          <h2>Quản lý công thức</h2>
          <p>Quản lý công thức, trạng thái xuất bản, dữ liệu dinh dưỡng, dị ứng và kiểm duyệt nội dung AI.</p>
        </div>
        <div className="button-row">
          <Link className="primary-btn" to="/recipes/new"><Plus size={17} /> Thêm công thức</Link>
          <button className="ghost-btn" onClick={() => importRecipeDataset({ source: "admin-upload" })}><FileUp size={16} /> Import dataset</button>
        </div>
      </div>

      <section className="kpi-grid overview-main-kpis">
        {stats.map(({ label, value, note, icon: Icon, warm }) => (
          <article className={`kpi-card compact-kpi ${warm ? "warm" : ""}`} key={label}>
            <div className="kpi-icon"><Icon size={19} /></div>
            <span>{label}</span>
            <strong>{value}</strong>
            <small>{note}</small>
          </article>
        ))}
      </section>

      <section className="panel">
        <div className="filter-grid recipe-management-filter-grid">
          <label className="field search-field recipe-search-field">
            <Search size={16} />
            <input placeholder="Tìm công thức..." />
          </label>
          <select><option>Cuisine</option><option>Việt Nam</option><option>Địa Trung Hải</option><option>Bắc Âu</option></select>
          <select><option>Chế độ ăn</option><option>Keto</option><option>Vegan</option><option>Gluten-free</option></select>
          <select><option>Dị ứng</option><option>Không hạt</option><option>Không sữa</option><option>Không hải sản</option></select>
          <select><option>Trạng thái</option><option>Bản nháp</option><option>Chờ duyệt</option><option>Đã xuất bản</option><option>Đã ẩn</option><option>Lưu trữ</option></select>
          <select><option>Nguồn</option><option>Thủ công</option><option>AI tạo</option><option>Import dataset</option><option>Chuyên gia duyệt</option></select>
          <select><option>Safety</option><option>An toàn</option><option>Cần kiểm tra</option><option>Có cảnh báo</option></select>
          <button className="ghost-btn">Xóa lọc</button>
        </div>
      </section>

      <section className="panel">
        <div className="table-scroll">
          <table className="data-table recipe-table">
            <thead>
              <tr>
                <th>Công thức</th>
                <th>Cuisine</th>
                <th>Dinh dưỡng</th>
                <th>Dị ứng</th>
                <th>Diet tags</th>
                <th>Safety</th>
                <th>Nguồn</th>
                <th>Trạng thái</th>
                <th>Cập nhật</th>
                <th>Hành động</th>
              </tr>
            </thead>
            <tbody>
              {recipeRows.map((recipe) => (
                <tr key={recipe.id}>
                  <td className="recipe-name">
                    <img src={recipe.image} alt={recipe.name} />
                    <div>
                      <strong>{recipe.name}</strong>
                      <span>{recipe.calories} kcal · {recipe.rating} ★</span>
                    </div>
                  </td>
                  <td><span className="chip">{recipe.cuisine}</span></td>
                  <td>
                    <div className="macro-row">
                      <span>P {recipe.protein}g</span>
                      <span>C {recipe.carb}g</span>
                      <span>F {recipe.fat}g</span>
                    </div>
                  </td>
                  <td>{recipe.allergens.length ? recipe.allergens.map((tag) => <span className="chip danger" key={tag}>{tag}</span>) : "-"}</td>
                  <td>{recipe.dietTags.map((tag) => <span className="chip" key={tag}>{tag}</span>)}</td>
                  <td><span className={`safety-badge ${safetyClass(recipe.safety)}`}>{recipe.safety}</span></td>
                  <td><span className="source-badge">{recipe.source}</span></td>
                  <td><span className={`status-dot ${recipe.statusLabel !== "Đã xuất bản" ? "muted" : ""}`}>{recipe.statusLabel}</span></td>
                  <td>{recipe.updated}</td>
                  <td className="actions-cell">
                    <button className="icon-link" title="Xem trước" aria-label="Xem trước công thức"><Eye size={17} /></button>
                    <Link className="icon-link" to={`/recipes/${recipe.id}/edit`} title="Chỉnh sửa" aria-label="Chỉnh sửa công thức"><Pencil size={17} /></Link>
                    <details className="action-menu">
                      <summary title="Mở menu hành động" aria-label="Mở menu hành động"><MoreVertical size={17} /></summary>
                      <div className="action-menu-list">
                        {moreActions.map(({ icon: Icon, ...action }) => (
                          <button
                            className={action.danger ? "danger-action" : ""}
                            key={action.label}
                            onClick={() => runRowAction(action, recipe)}
                            title={action.label}
                          >
                            <Icon size={15} />
                            {action.label}
                          </button>
                        ))}
                      </div>
                    </details>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="table-footer">
          <span>Hiển thị 1-10 trong 1,284 công thức</span>
          <div className="pagination"><button disabled>‹</button><button className="active">1</button><button>2</button><button>3</button><span>...</span><button>129</button><button>›</button></div>
        </div>
      </section>

      <section className="ai-banner recipe-ai-insight">
        <div className="ai-icon"><Sparkles size={22} /></div>
        <div>
          <h2>NutriChef AI Insight</h2>
          <p>Người dùng gluten-free đang tìm món Địa Trung Hải tăng 22%. Có 46 công thức AI tạo đang chờ duyệt, 12 công thức thiếu allergen tag và khoảng trống rõ ở nhóm protein thực vật cao.</p>
          <div className="button-row">
            <Link className="ghost-btn" to="/reports">Xem báo cáo khoảng trống danh mục</Link>
            <button className="primary-btn">Xem công thức cần kiểm tra</button>
          </div>
        </div>
      </section>
    </div>
  );
}
