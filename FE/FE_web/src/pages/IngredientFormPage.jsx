import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { Save, ShieldAlert } from "lucide-react";
import { createIngredient, getAllergens, getIngredient, updateIngredient } from "../api/recipeManagement.js";

export default function IngredientFormPage({ mode }) {
  const { id } = useParams();
  const navigate = useNavigate();
  const isCreate = mode === "create";
  const [name, setName] = useState("");
  const [allergenIds, setAllergenIds] = useState([]);
  const [allergens, setAllergens] = useState([]);
  const [errors, setErrors] = useState({});
  const [requestError, setRequestError] = useState("");
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    let active = true;
    async function loadForm() {
      setLoading(true);
      setRequestError("");
      try {
        const [allergenPage, ingredient] = await Promise.all([
          getAllergens({ page: 0, size: 200, sort: "name,asc" }),
          isCreate ? Promise.resolve(null) : getIngredient(id)
        ]);
        if (!active) return;
        setAllergens(allergenPage.content || []);
        if (ingredient) {
          setName(ingredient.name || "");
          setAllergenIds((ingredient.allergens || []).map((item) => item.allergenId));
        }
      } catch (error) {
        if (active) setRequestError(error.message);
      } finally {
        if (active) setLoading(false);
      }
    }
    loadForm();
    return () => { active = false; };
  }, [id, isCreate]);

  function toggleAllergen(allergenId) {
    setAllergenIds((current) => current.includes(allergenId)
      ? current.filter((value) => value !== allergenId)
      : [...current, allergenId]);
    setRequestError("");
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const trimmedName = name.trim();
    if (!trimmedName) {
      setErrors({ name: "Tên nguyên liệu là bắt buộc." });
      return;
    }
    if (trimmedName.length > 150) {
      setErrors({ name: "Tên nguyên liệu không được vượt quá 150 ký tự." });
      return;
    }

    setSubmitting(true);
    setRequestError("");
    setErrors({});
    try {
      const payload = { name: trimmedName, allergenIds };
      if (isCreate) await createIngredient(payload);
      else await updateIngredient(id, payload);
      navigate("/nutrition", { replace: true });
    } catch (error) {
      setRequestError(error.message);
      if (error.details?.validationErrors) setErrors(error.details.validationErrors);
    } finally {
      setSubmitting(false);
    }
  }

  if (loading) return <section className="panel">Đang tải dữ liệu nguyên liệu...</section>;

  return (
    <form className="page-stack" onSubmit={handleSubmit} noValidate>
      <div className="page-toolbar">
        <div><p className="eyebrow">Recipe Service</p><h2>{isCreate ? "Tạo nguyên liệu mới" : "Chỉnh sửa nguyên liệu"}</h2><p>Thông tin này được dùng chung khi admin tạo công thức và kiểm tra dị ứng.</p></div>
        <button className="primary-btn" type="submit" disabled={submitting}><Save size={16} /> {submitting ? "Đang lưu..." : "Lưu nguyên liệu"}</button>
      </div>

      {requestError ? <section className="warning-panel"><ShieldAlert size={20} /><div><strong>Không thể lưu nguyên liệu</strong><p>{requestError}</p></div></section> : null}

      <section className="form-grid">
        <article className="form-card span-2">
          <h2>Thông tin chính</h2>
          <label>Tên nguyên liệu
            <input value={name} onChange={(event) => { setName(event.target.value); setErrors((current) => ({ ...current, name: undefined })); }} placeholder="Ví dụ: Hạnh nhân" aria-invalid={Boolean(errors.name)} />
            {errors.name ? <span className="field-error">{errors.name}</span> : null}
          </label>
        </article>
        <article className="form-card">
          <h2>Nhãn đã chọn</h2>
          <strong>{allergenIds.length}</strong>
          <p className="soft-copy">Có thể để trống nếu nguyên liệu không liên quan đến dị ứng đã biết.</p>
        </article>
      </section>

      <section className="form-card">
        <h2>Thông tin dị ứng</h2>
        <p className="soft-copy">Chọn tất cả nhãn dị ứng có liên quan đến nguyên liệu.</p>
        <div className="filter-bar">
          {allergens.length ? allergens.map((allergen) => (
            <label className={`chip ${allergenIds.includes(allergen.allergenId) ? "active" : ""}`} key={allergen.allergenId}>
              <input type="checkbox" checked={allergenIds.includes(allergen.allergenId)} onChange={() => toggleAllergen(allergen.allergenId)} /> {allergen.name}
            </label>
          )) : <span>Chưa có nhãn dị ứng trong Recipe Service.</span>}
        </div>
        {errors.allergenIds ? <span className="field-error">{errors.allergenIds}</span> : null}
      </section>

      <section className="warning-panel">
        <ShieldAlert size={20} />
        <div><strong>Safety matrix</strong><p>Các nhãn dị ứng được dùng trong bộ lọc công thức và cảnh báo cá nhân hóa. Chỉ chọn nhãn đã được xác minh.</p></div>
      </section>

      <div className="danger-footer"><Link className="ghost-btn" to="/nutrition">Hủy</Link><button className="primary-btn wide" type="submit" disabled={submitting}>{submitting ? "Đang lưu..." : "Lưu vào database"}</button></div>
    </form>
  );
}
