import { useEffect, useMemo, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { CirclePlus, Save, Trash2, X } from "lucide-react";
import {
  createRecipe,
  deleteRecipe,
  getCategories,
  getIngredients,
  getRecipe,
  updateRecipe
} from "../api/recipeManagement.js";

const DIET_TYPES = ["NORMAL", "VEGETARIAN", "VEGAN", "OVO_VEGETARIAN", "LACTO_VEGETARIAN", "KETO", "LOW_CARB"];
const EMPTY_FORM = {
  categoryId: "",
  title: "",
  description: "",
  imageUrl: "",
  preparationTime: 0,
  cookTime: 0,
  difficulty: "EASY",
  servings: 1,
  dietTypes: [],
  ingredients: [{ ingredientId: "", quantity: 1, unit: "g" }],
  steps: [{ stepOrder: 1, instruction: "" }],
  nutrition: { calories: 0, protein: 0, fat: 0, carbs: 0, fiber: 0, sugar: 0, sodium: 0 }
};

const NUTRITION_FIELDS = [
  ["calories", "Calories", "kcal"],
  ["protein", "Protein", "g"],
  ["carbs", "Carb", "g"],
  ["fat", "Fat", "g"],
  ["fiber", "Fiber", "g"],
  ["sugar", "Sugar", "g"],
  ["sodium", "Sodium", "mg"]
];

function toForm(recipe) {
  return {
    categoryId: String(recipe.category?.categoryId || ""),
    title: recipe.title || "",
    description: recipe.description || "",
    imageUrl: recipe.imageUrl || "",
    preparationTime: recipe.preparationTime ?? 0,
    cookTime: recipe.cookTime ?? 0,
    difficulty: recipe.difficulty || "EASY",
    servings: recipe.servings ?? 1,
    dietTypes: recipe.dietTypes || [],
    ingredients: (recipe.ingredients || []).map((item) => ({
      ingredientId: String(item.ingredientId), quantity: item.quantity, unit: item.unit
    })),
    steps: (recipe.steps || []).sort((a, b) => a.stepOrder - b.stepOrder).map((item, index) => ({
      stepOrder: index + 1, instruction: item.instruction
    })),
    nutrition: {
      calories: recipe.nutrition?.calories ?? 0,
      protein: recipe.nutrition?.protein ?? 0,
      fat: recipe.nutrition?.fat ?? 0,
      carbs: recipe.nutrition?.carbs ?? 0,
      fiber: recipe.nutrition?.fiber ?? 0,
      sugar: recipe.nutrition?.sugar ?? 0,
      sodium: recipe.nutrition?.sodium ?? 0
    }
  };
}

function toPayload(form) {
  return {
    ...form,
    categoryId: Number(form.categoryId),
    preparationTime: Number(form.preparationTime),
    cookTime: Number(form.cookTime),
    servings: Number(form.servings),
    imageUrl: form.imageUrl.trim() || null,
    ingredients: form.ingredients.map((item) => ({
      ingredientId: Number(item.ingredientId), quantity: Number(item.quantity), unit: item.unit.trim()
    })),
    steps: form.steps.map((item, index) => ({ stepOrder: index + 1, instruction: item.instruction.trim() })),
    nutrition: Object.fromEntries(Object.entries(form.nutrition).map(([key, value]) => [key, Number(value)]))
  };
}

function validate(form) {
  if (!form.categoryId) return "Vui lòng chọn danh mục.";
  if (!form.title.trim() || !form.description.trim()) return "Tên và mô tả công thức là bắt buộc.";
  if (Number(form.servings) <= 0) return "Khẩu phần phải lớn hơn 0.";
  if (!form.ingredients.length || form.ingredients.some((item) => !item.ingredientId || Number(item.quantity) <= 0 || !item.unit.trim())) return "Mỗi nguyên liệu cần có tên, số lượng lớn hơn 0 và đơn vị.";
  if (!form.steps.length || form.steps.some((item) => !item.instruction.trim())) return "Mỗi bước nấu cần có hướng dẫn.";
  if (Object.values(form.nutrition).some((value) => Number(value) < 0 || Number.isNaN(Number(value)))) return "Dinh dưỡng phải là số không âm.";
  return "";
}

export default function RecipeFormPage({ mode }) {
  const { id } = useParams();
  const navigate = useNavigate();
  const isCreate = mode === "create";
  const [form, setForm] = useState(EMPTY_FORM);
  const [categories, setCategories] = useState([]);
  const [ingredientOptions, setIngredientOptions] = useState([]);
  const [loading, setLoading] = useState(!isCreate);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    setLoading(true);
    const requests = [
      getCategories({ page: 0, size: 500, sort: "name,asc" }),
      getIngredients({ page: 0, size: 500, sort: "name,asc" })
    ];
    if (!isCreate) requests.push(getRecipe(id));

    Promise.all(requests)
      .then(([categoryPage, ingredientPage, recipe]) => {
        setCategories(categoryPage.content || []);
        setIngredientOptions(ingredientPage.content || []);
        if (recipe) setForm(toForm(recipe));
      })
      .catch((requestError) => setError(requestError.message))
      .finally(() => setLoading(false));
  }, [id, isCreate]);

  const allergenNames = useMemo(() => {
    const selectedIds = new Set(form.ingredients.map((item) => Number(item.ingredientId)));
    return [...new Set(ingredientOptions.filter((item) => selectedIds.has(item.ingredientId)).flatMap((item) => item.allergens || []).map((item) => item.name))];
  }, [form.ingredients, ingredientOptions]);

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
  }

  function updateIngredient(index, field, value) {
    setForm((current) => ({ ...current, ingredients: current.ingredients.map((item, itemIndex) => itemIndex === index ? { ...item, [field]: value } : item) }));
  }

  function updateStep(index, value) {
    setForm((current) => ({ ...current, steps: current.steps.map((item, itemIndex) => itemIndex === index ? { ...item, instruction: value } : item) }));
  }

  function toggleDiet(dietType) {
    setForm((current) => ({
      ...current,
      dietTypes: current.dietTypes.includes(dietType) ? current.dietTypes.filter((item) => item !== dietType) : [...current.dietTypes, dietType]
    }));
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const validationError = validate(form);
    if (validationError) { setError(validationError); return; }
    setSaving(true);
    setError("");
    try {
      const saved = isCreate ? await createRecipe(toPayload(form)) : await updateRecipe(id, toPayload(form));
      navigate(`/recipes/${saved.recipeId}/edit`, { replace: true });
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete() {
    if (!window.confirm(`Xóa công thức “${form.title}”?`)) return;
    try { await deleteRecipe(id); navigate("/recipes"); }
    catch (requestError) { setError(requestError.message); }
  }

  if (loading) return <div className="page-stack"><section className="panel">Đang tải dữ liệu công thức...</section></div>;

  return (
    <form className="page-stack recipe-editor-page" onSubmit={handleSubmit}>
      <div className="page-toolbar recipe-editor-title">
        <div><p className="eyebrow">Recipe Service</p><h2>{isCreate ? "Tạo công thức mới" : "Chỉnh sửa công thức"}</h2><p>Biểu mẫu này bám đúng RecipeRequest của backend.</p></div>
        <div className="button-row"><Link className="ghost-btn" to="/recipes">Hủy</Link><button className="primary-btn" disabled={saving} type="submit"><Save size={16} /> {saving ? "Đang lưu..." : isCreate ? "Tạo công thức" : "Lưu thay đổi"}</button></div>
      </div>

      {error ? <section className="warning-panel"><span>{error}</span></section> : null}

      <section className="recipe-editor-section">
        <div className="section-heading"><h2>Thông tin cơ bản</h2><p>Danh mục, hình ảnh, thời gian, độ khó và khẩu phần.</p></div>
        <div className="form-card">
          <label>Tên công thức<input maxLength="255" value={form.title} onChange={(event) => updateField("title", event.target.value)} /></label>
          <label>Mô tả<textarea value={form.description} onChange={(event) => updateField("description", event.target.value)} /></label>
          <label>URL ảnh<input maxLength="2048" type="url" value={form.imageUrl} onChange={(event) => updateField("imageUrl", event.target.value)} placeholder="https://..." /></label>
          <div className="macro-input-grid compact-form-grid">
            <label>Danh mục<select value={form.categoryId} onChange={(event) => updateField("categoryId", event.target.value)}><option value="">Chọn danh mục</option>{categories.map((item) => <option value={item.categoryId} key={item.categoryId}>{item.name}</option>)}</select></label>
            <label>Chuẩn bị (phút)<input min="0" type="number" value={form.preparationTime} onChange={(event) => updateField("preparationTime", event.target.value)} /></label>
            <label>Nấu (phút)<input min="0" type="number" value={form.cookTime} onChange={(event) => updateField("cookTime", event.target.value)} /></label>
            <label>Độ khó<select value={form.difficulty} onChange={(event) => updateField("difficulty", event.target.value)}><option value="EASY">Dễ</option><option value="MEDIUM">Trung bình</option><option value="HARD">Khó</option></select></label>
            <label>Khẩu phần<input min="1" type="number" value={form.servings} onChange={(event) => updateField("servings", event.target.value)} /></label>
          </div>
        </div>
      </section>

      <section className="recipe-editor-section">
        <div className="section-heading"><h2>Nguyên liệu</h2><p>Recipe-service yêu cầu ít nhất một nguyên liệu từ catalog.</p></div>
        <div className="structured-list">
          {form.ingredients.map((item, index) => (
            <div className="structured-ingredient-row" key={index}>
              <label>Nguyên liệu<select value={item.ingredientId} onChange={(event) => updateIngredient(index, "ingredientId", event.target.value)}><option value="">Chọn nguyên liệu</option>{ingredientOptions.map((option) => <option value={option.ingredientId} key={option.ingredientId}>{option.name}</option>)}</select></label>
              <label>Số lượng<input min="0.0001" step="any" type="number" value={item.quantity} onChange={(event) => updateIngredient(index, "quantity", event.target.value)} /></label>
              <label>Đơn vị<input maxLength="50" value={item.unit} onChange={(event) => updateIngredient(index, "unit", event.target.value)} /></label>
              <button className="icon-link" disabled={form.ingredients.length === 1} type="button" onClick={() => setForm((current) => ({ ...current, ingredients: current.ingredients.filter((_, itemIndex) => itemIndex !== index) }))}><X size={16} /></button>
            </div>
          ))}
        </div>
        <button className="dashed-btn" type="button" onClick={() => setForm((current) => ({ ...current, ingredients: [...current.ingredients, { ingredientId: "", quantity: 1, unit: "g" }] }))}><CirclePlus size={16} /> Thêm nguyên liệu</button>
        {allergenNames.length ? <div className="warning-panel mini"><span>Dị ứng suy ra từ nguyên liệu: {allergenNames.join(", ")}</span></div> : null}
      </section>

      <section className="recipe-editor-section">
        <div className="section-heading"><h2>Hướng dẫn nấu</h2><p>Thứ tự bước được gửi liên tiếp từ 1.</p></div>
        <div className="instruction-list">
          {form.steps.map((step, index) => <div className="instruction-row" key={index}><span className="step-number">{index + 1}</span><textarea value={step.instruction} onChange={(event) => updateStep(index, event.target.value)} /><button className="icon-link" disabled={form.steps.length === 1} type="button" onClick={() => setForm((current) => ({ ...current, steps: current.steps.filter((_, itemIndex) => itemIndex !== index) }))}><X size={16} /></button></div>)}
        </div>
        <button className="dashed-btn" type="button" onClick={() => setForm((current) => ({ ...current, steps: [...current.steps, { stepOrder: current.steps.length + 1, instruction: "" }] }))}><CirclePlus size={16} /> Thêm bước nấu</button>
      </section>

      <section className="recipe-editor-grid half-grid">
        <article className="recipe-editor-section">
          <div className="section-heading"><h2>Dinh dưỡng</h2><p>Giá trị dinh dưỡng của toàn bộ công thức.</p></div>
          <div className="macro-input-grid nutrition-unit-grid">
            {NUTRITION_FIELDS.map(([key, label, unit]) => <label key={key}>{label}<div className="unit-input"><input min="0" step="any" type="number" value={form.nutrition[key]} onChange={(event) => setForm((current) => ({ ...current, nutrition: { ...current.nutrition, [key]: event.target.value } }))} /><span>{unit}</span></div></label>)}
          </div>
        </article>
        <article className="recipe-editor-section">
          <div className="section-heading"><h2>Chế độ ăn</h2><p>Các giá trị DietType backend hỗ trợ.</p></div>
          <div className="tag-section-grid">
            {DIET_TYPES.map((item) => <label className={`chip ${form.dietTypes.includes(item) ? "active" : ""}`} key={item}><input checked={form.dietTypes.includes(item)} onChange={() => toggleDiet(item)} type="checkbox" /> {item.replaceAll("_", " ")}</label>)}
          </div>
        </article>
      </section>

      <div className="danger-footer">
        {!isCreate ? <button className="danger-link" onClick={handleDelete} type="button"><Trash2 size={16} /> Xóa công thức</button> : <span />}
        <div className="button-row"><Link className="ghost-btn" to="/recipes">Hủy</Link><button className="primary-btn wide" disabled={saving} type="submit">{saving ? "Đang lưu..." : "Lưu công thức"}</button></div>
      </div>
    </form>
  );
}
