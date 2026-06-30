import { Link, useParams } from "react-router-dom";
import { Save, ShieldAlert, Sparkles } from "lucide-react";
import { ingredients } from "../data/mockData.js";

export default function IngredientFormPage({ mode }) {
  const { id } = useParams();
  const ingredient = ingredients.find((item) => item.id === id) ?? ingredients[0];
  const isCreate = mode === "create";

  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div><p className="eyebrow">Ingredient Studio</p><h2>{isCreate ? "Tạo nguyên liệu mới" : "Chỉnh sửa nguyên liệu"}</h2></div>
        <button className="primary-btn"><Save size={16} /> Lưu nguyên liệu</button>
      </div>

      <section className="form-grid">
        <article className="form-card span-2">
          <h2>Thông tin chính</h2>
          <div className="two-col">
            <label>Tên nguyên liệu<input defaultValue={isCreate ? "" : ingredient.name} /></label>
            <label>Danh mục<select defaultValue={ingredient.category}><option>Rau củ</option><option>Protein</option><option>Ngũ cốc</option><option>Sữa</option></select></label>
            <label>Đơn vị khẩu phần<input defaultValue="100g" /></label>
            <label>Cholesterol<input defaultValue="0 mg" /></label>
          </div>
        </article>
        <article className="form-card">
          <h2>Cảnh báo AI</h2>
          <p className="soft-copy"><Sparkles size={16} /> Kiểm tra chéo với nguồn USDA trước khi xuất bản nếu macro thay đổi trên 15%.</p>
        </article>
      </section>

      <section className="form-card">
        <h2>Giá trị dinh dưỡng</h2>
        <div className="macro-input-grid">
          {[
            ["Calories", ingredient.calories],
            ["Protein", ingredient.protein],
            ["Carb", ingredient.carb],
            ["Chất béo", ingredient.fat],
            ["Chất xơ", ingredient.fiber],
            ["Natri", ingredient.sodium],
            ["Đường", ingredient.sugar]
          ].map(([label, value]) => <label key={label}>{label}<input defaultValue={value} /></label>)}
        </div>
      </section>

      <section className="form-grid">
        <article className="form-card">
          <h2>Thông tin dị ứng</h2>
          <textarea defaultValue={ingredient.allergen === "-" ? "" : ingredient.allergen} placeholder="Mô tả dị ứng liên quan..." />
        </article>
        <article className="form-card">
          <h2>Cảnh báo sức khỏe</h2>
          <textarea defaultValue="Không khuyến nghị dùng quá khẩu phần khi người dùng có chỉ số sodium cao." />
        </article>
        <article className="form-card">
          <h2>Nguyên liệu thay thế</h2>
          <textarea defaultValue="Hạt bí, đậu gà rang, sữa hạnh nhân không đường." />
        </article>
      </section>

      <section className="warning-panel">
        <ShieldAlert size={20} />
        <div><strong>Safety matrix</strong><p>Các tag dị ứng sẽ được dùng trong bộ lọc recipe và cảnh báo cá nhân hóa.</p></div>
      </section>

      <div className="danger-footer"><Link className="ghost-btn" to="/nutrition">Hủy</Link><Link className="primary-btn wide" to="/nutrition">Lưu vào database</Link></div>
    </div>
  );
}
