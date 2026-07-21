import { useEffect, useMemo, useRef, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { CirclePlus, ImagePlus, Save, Trash2, Upload, X } from "lucide-react";
import {
  createRecipe,
  deleteRecipe,
  getCategories,
  getIngredients,
  getRecipe,
  updateRecipe,
  uploadRecipeImage
} from "../api/recipeManagement.js";

const DIET_TYPES = ["NORMAL", "VEGETARIAN", "VEGAN", "OVO_VEGETARIAN", "LACTO_VEGETARIAN", "KETO", "LOW_CARB"];

const DIET_LABELS = {
  NORMAL: "Thông thường",
  VEGETARIAN: "Chay",
  VEGAN: "Thuần chay",
  OVO_VEGETARIAN: "Chay có trứng",
  LACTO_VEGETARIAN: "Chay có sữa",
  KETO: "Keto",
  LOW_CARB: "Ít carb"
};

const DIFFICULTY_LABELS = {
  EASY: "Dễ",
  MEDIUM: "Trung bình",
  HARD: "Khó"
};

const NUTRITION_FIELDS = [
  ["servingSizeGrams", "Khối lượng khẩu phần", "g"],
  ["calories", "Năng lượng", "kcal"],
  ["protein", "Protein", "g"],
  ["carbs", "Carb", "g"],
  ["fat", "Fat", "g"],
  ["saturatedFat", "Fat bão hòa", "g"],
  ["transFat", "Trans fat", "g"],
  ["cholesterol", "Cholesterol", "mg"],
  ["fiber", "Chất xơ", "g"],
  ["sugar", "Đường", "g"],
  ["sodium", "Natri", "mg"],
  ["potassium", "Kali", "mg"],
  ["vitaminA", "Vitamin A", "mcg"],
  ["vitaminD", "Vitamin D", "mcg"],
  ["vitaminE", "Vitamin E", "mg"],
  ["vitaminK", "Vitamin K", "mcg"],
  ["vitaminB1", "Vitamin B1", "mg"],
  ["vitaminB2", "Vitamin B2", "mg"],
  ["vitaminB3", "Vitamin B3", "mg"],
  ["vitaminB6", "Vitamin B6", "mg"],
  ["vitaminB9", "Vitamin B9", "mcg"],
  ["vitaminB12", "Vitamin B12", "mcg"],
  ["vitaminC", "Vitamin C", "mg"],
  ["calcium", "Canxi", "mg"],
  ["iron", "Sắt", "mg"]
];

const EMPTY_NUTRITION = Object.fromEntries(NUTRITION_FIELDS.map(([key]) => [key, 0]));

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
  nutrition: EMPTY_NUTRITION
};

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
      ingredientId: String(item.ingredientId),
      quantity: item.quantity,
      unit: item.unit
    })),
    steps: (recipe.steps || [])
      .sort((a, b) => a.stepOrder - b.stepOrder)
      .map((item, index) => ({ stepOrder: index + 1, instruction: item.instruction })),
    nutrition: {
      ...EMPTY_NUTRITION,
      ...Object.fromEntries(NUTRITION_FIELDS.map(([key]) => [key, recipe.nutrition?.[key] ?? 0]))
    }
  };
}

function toNumber(value) {
  const numericValue = Number(value);
  return Number.isFinite(numericValue) ? numericValue : 0;
}

function toPayload(form) {
  return {
    categoryId: Number(form.categoryId),
    title: form.title.trim(),
    description: form.description.trim(),
    imageUrl: form.imageUrl.trim() || null,
    preparationTime: toNumber(form.preparationTime),
    cookTime: toNumber(form.cookTime),
    difficulty: form.difficulty,
    servings: toNumber(form.servings),
    dietTypes: form.dietTypes,
    ingredients: form.ingredients.map((item) => ({
      ingredientId: Number(item.ingredientId),
      quantity: toNumber(item.quantity),
      unit: item.unit.trim()
    })),
    steps: form.steps.map((item, index) => ({
      stepOrder: index + 1,
      instruction: item.instruction.trim()
    })),
    nutrition: Object.fromEntries(NUTRITION_FIELDS.map(([key]) => [key, toNumber(form.nutrition[key])]))
  };
}

function validate(form) {
  if (!form.categoryId) return "Vui lòng chọn danh mục.";
  if (!form.title.trim()) return "Tên công thức là bắt buộc.";
  if (!form.description.trim()) return "Mô tả công thức là bắt buộc.";
  if (toNumber(form.preparationTime) < 0 || toNumber(form.cookTime) < 0) return "Thời gian không được âm.";
  if (toNumber(form.servings) <= 0) return "Khẩu phần phải lớn hơn 0.";
  if (!form.ingredients.length || form.ingredients.some((item) => !item.ingredientId || toNumber(item.quantity) <= 0 || !item.unit.trim())) {
    return "Mỗi nguyên liệu cần có tên, số lượng lớn hơn 0 và đơn vị.";
  }
  if (!form.steps.length || form.steps.some((item) => !item.instruction.trim())) return "Mỗi bước nấu cần có hướng dẫn.";
  if (NUTRITION_FIELDS.some(([key]) => toNumber(form.nutrition[key]) < 0)) return "Dinh dưỡng phải là số không âm.";
  return "";
}

export default function RecipeFormPage({ mode }) {
  const { id } = useParams();
  const navigate = useNavigate();
  const fileInputRef = useRef(null);
  const errorRef = useRef(null);
  const isCreate = mode === "create";
  const [form, setForm] = useState(EMPTY_FORM);
  const [categories, setCategories] = useState([]);
  const [ingredientOptions, setIngredientOptions] = useState([]);
  const [loading, setLoading] = useState(!isCreate);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState("");

  function showError(message) {
    setError(message);
    window.setTimeout(() => {
      errorRef.current?.scrollIntoView({ behavior: "smooth", block: "center" });
    }, 50);
  }

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
    return [...new Set(ingredientOptions
      .filter((item) => selectedIds.has(item.ingredientId))
      .flatMap((item) => item.allergens || [])
      .map((item) => item.name))];
  }, [form.ingredients, ingredientOptions]);

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
  }

  function updateIngredient(index, field, value) {
    setForm((current) => ({
      ...current,
      ingredients: current.ingredients.map((item, itemIndex) => itemIndex === index ? { ...item, [field]: value } : item)
    }));
  }

  function updateStep(index, value) {
    setForm((current) => ({
      ...current,
      steps: current.steps.map((item, itemIndex) => itemIndex === index ? { ...item, instruction: value } : item)
    }));
  }

  function toggleDiet(dietType) {
    setForm((current) => ({
      ...current,
      dietTypes: current.dietTypes.includes(dietType)
        ? current.dietTypes.filter((item) => item !== dietType)
        : [...current.dietTypes, dietType]
    }));
  }

  async function handleImageUpload(event) {
    const file = event.target.files?.[0];
    if (!file) return;
    setUploading(true);
    setError("");
    try {
      const response = await uploadRecipeImage(file);
      updateField("imageUrl", response.imageUrl || "");
    } catch (requestError) {
      showError(requestError.message);
    } finally {
      setUploading(false);
      event.target.value = "";
    }
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const validationError = validate(form);
    if (validationError) {
      showError(validationError);
      return;
    }
    setSaving(true);
    setError("");
    try {
      const saved = isCreate ? await createRecipe(toPayload(form)) : await updateRecipe(id, toPayload(form));
      navigate(isCreate ? "/recipes" : `/recipes/${saved.recipeId}/edit`, { replace: true });
    } catch (requestError) {
      showError(requestError.message);
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete() {
    if (!window.confirm(`Xóa công thức "${form.title}"?`)) return;
    try {
      await deleteRecipe(id);
      navigate("/recipes");
    } catch (requestError) {
      showError(requestError.message);
    }
  }

  if (loading) {
    return <div className="page-stack"><section className="panel">Đang tải dữ liệu công thức...</section></div>;
  }

  return (
    <form className="page-stack recipe-editor-page" onSubmit={handleSubmit}>
      <div className="page-toolbar recipe-editor-title">
        <div>
          <p className="eyebrow">Recipe Service</p>
          <h2>{isCreate ? "Thêm công thức" : "Chỉnh sửa công thức"}</h2>
          <p>Form sử dụng đúng dữ liệu mà Recipe Service đang hỗ trợ.</p>
        </div>
        <div className="button-row">
          <Link className="ghost-btn" to="/recipes">Hủy</Link>
          <button className="primary-btn" disabled={saving || uploading} type="submit">
            <Save size={16} /> {saving ? "Đang lưu..." : isCreate ? "Tạo công thức" : "Lưu thay đổi"}
          </button>
        </div>
      </div>

      {error ? <section className="warning-panel" ref={errorRef}><span>{error}</span></section> : null}

      <section className="recipe-editor-section">
        <div className="section-heading">
          <h2>Thông tin cơ bản</h2>
          <p>Danh mục, ảnh đại diện, thời gian, độ khó và khẩu phần.</p>
        </div>
        <div className="recipe-basic-grid">
          <div className="recipe-image-panel">
            {form.imageUrl ? <img src={form.imageUrl} alt={form.title || "Ảnh công thức"} /> : <div><ImagePlus size={30} /><span>Chưa có ảnh</span></div>}
            <input ref={fileInputRef} type="file" accept="image/*" hidden onChange={handleImageUpload} />
            <button className="ghost-btn" type="button" onClick={() => fileInputRef.current?.click()} disabled={uploading}>
              <Upload size={16} /> {uploading ? "Đang tải ảnh..." : "Tải ảnh lên"}
            </button>
            <label>URL ảnh
              <input maxLength="2048" type="url" value={form.imageUrl} onChange={(event) => updateField("imageUrl", event.target.value)} placeholder="https://..." />
            </label>
          </div>

          <div className="form-card recipe-basic-form-card">
            <label>Tên công thức
              <input maxLength="255" value={form.title} onChange={(event) => updateField("title", event.target.value)} />
            </label>
            <label>Mô tả
              <textarea value={form.description} onChange={(event) => updateField("description", event.target.value)} />
            </label>
            <div className="compact-form-grid">
              <label>Danh mục
                <select value={form.categoryId} onChange={(event) => updateField("categoryId", event.target.value)}>
                  <option value="">Chọn danh mục</option>
                  {categories.map((item) => <option value={item.categoryId} key={item.categoryId}>{item.name}</option>)}
                </select>
              </label>
              <label>Chuẩn bị (phút)
                <input min="0" type="number" value={form.preparationTime} onChange={(event) => updateField("preparationTime", event.target.value)} />
              </label>
              <label>Nấu (phút)
                <input min="0" type="number" value={form.cookTime} onChange={(event) => updateField("cookTime", event.target.value)} />
              </label>
              <label>Độ khó
                <select value={form.difficulty} onChange={(event) => updateField("difficulty", event.target.value)}>
                  {Object.entries(DIFFICULTY_LABELS).map(([value, label]) => <option value={value} key={value}>{label}</option>)}
                </select>
              </label>
              <label>Khẩu phần
                <input min="1" type="number" value={form.servings} onChange={(event) => updateField("servings", event.target.value)} />
              </label>
            </div>
          </div>
        </div>
      </section>

      <section className="recipe-editor-section">
        <div className="section-heading">
          <h2>Nguyên liệu</h2>
          <p>Chọn nguyên liệu từ catalog, nhập số lượng và đơn vị.</p>
        </div>
        <div className="structured-list">
          {form.ingredients.map((item, index) => (
            <div className="structured-ingredient-row clean-ingredient-row" key={index}>
              <span className="row-index">{index + 1}</span>
              <label>Nguyên liệu
                <select value={item.ingredientId} onChange={(event) => updateIngredient(index, "ingredientId", event.target.value)}>
                  <option value="">Chọn nguyên liệu</option>
                  {ingredientOptions.map((option) => <option value={option.ingredientId} key={option.ingredientId}>{option.name}</option>)}
                </select>
              </label>
              <label>Số lượng
                <input min="0.0001" step="any" type="number" value={item.quantity} onChange={(event) => updateIngredient(index, "quantity", event.target.value)} />
              </label>
              <label>Đơn vị
                <input maxLength="50" value={item.unit} onChange={(event) => updateIngredient(index, "unit", event.target.value)} />
              </label>
              <button className="icon-link" disabled={form.ingredients.length === 1} type="button" onClick={() => setForm((current) => ({ ...current, ingredients: current.ingredients.filter((_, itemIndex) => itemIndex !== index) }))} aria-label="Xóa nguyên liệu">
                <X size={16} />
              </button>
            </div>
          ))}
        </div>
        <button className="dashed-btn" type="button" onClick={() => setForm((current) => ({ ...current, ingredients: [...current.ingredients, { ingredientId: "", quantity: 1, unit: "g" }] }))}>
          <CirclePlus size={16} /> Thêm nguyên liệu
        </button>
        {allergenNames.length ? <div className="warning-panel mini"><span>Dị ứng theo nguyên liệu đã chọn: {allergenNames.join(", ")}</span></div> : null}
      </section>

      <section className="recipe-editor-section">
        <div className="section-heading">
          <h2>Hướng dẫn nấu</h2>
          <p>Các bước sẽ được gửi theo thứ tự từ trên xuống dưới.</p>
        </div>
        <div className="instruction-list">
          {form.steps.map((step, index) => (
            <div className="instruction-row clean-instruction-row" key={index}>
              <span className="step-number">{index + 1}</span>
              <textarea value={step.instruction} onChange={(event) => updateStep(index, event.target.value)} placeholder="Nhập hướng dẫn cho bước này..." />
              <button className="icon-link" disabled={form.steps.length === 1} type="button" onClick={() => setForm((current) => ({ ...current, steps: current.steps.filter((_, itemIndex) => itemIndex !== index) }))} aria-label="Xóa bước">
                <X size={16} />
              </button>
            </div>
          ))}
        </div>
        <button className="dashed-btn" type="button" onClick={() => setForm((current) => ({ ...current, steps: [...current.steps, { stepOrder: current.steps.length + 1, instruction: "" }] }))}>
          <CirclePlus size={16} /> Thêm bước nấu
        </button>
      </section>

      <section className="recipe-editor-grid half-grid">
        <article className="recipe-editor-section">
          <div className="section-heading">
            <h2>Dinh dưỡng</h2>
            <p>Các trường này khớp với NutritionRequest của backend.</p>
          </div>
          <div className="nutrition-unit-grid">
            {NUTRITION_FIELDS.map(([key, label, unit]) => (
              <label key={key}>{label}
                <div className="unit-input">
                  <input min="0" step="any" type="number" value={form.nutrition[key]} onChange={(event) => setForm((current) => ({ ...current, nutrition: { ...current.nutrition, [key]: event.target.value } }))} />
                  <span>{unit}</span>
                </div>
              </label>
            ))}
          </div>
        </article>

        <article className="recipe-editor-section">
          <div className="section-heading">
            <h2>Chế độ ăn</h2>
            <p>Chọn các DietType phù hợp với công thức.</p>
          </div>
          <div className="tag-section-grid recipe-diet-grid">
            {DIET_TYPES.map((item) => (
              <label className={`chip ${form.dietTypes.includes(item) ? "active" : ""}`} key={item}>
                <input checked={form.dietTypes.includes(item)} onChange={() => toggleDiet(item)} type="checkbox" />
                {DIET_LABELS[item]}
              </label>
            ))}
          </div>
        </article>
      </section>

      <div className="danger-footer">
        {!isCreate ? <button className="danger-link" onClick={handleDelete} type="button"><Trash2 size={16} /> Xóa công thức</button> : <span />}
        <div className="recipe-footer-actions">
          {error ? <div className="footer-error-note">{error}</div> : null}
          <div className="button-row">
            <Link className="ghost-btn" to="/recipes">Hủy</Link>
            <button className="primary-btn wide" disabled={saving || uploading} type="submit">{saving ? "Đang lưu..." : "Lưu công thức"}</button>
          </div>
        </div>
      </div>
    </form>
  );
}
