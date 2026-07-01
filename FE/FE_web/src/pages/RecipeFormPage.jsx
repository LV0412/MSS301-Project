import { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import {
  Archive,
  Camera,
  CheckCircle2,
  CirclePlus,
  Eye,
  GripVertical,
  Save,
  ShieldAlert,
  ShieldCheck,
  Sparkles,
  Timer,
  Wand2,
  X
} from "lucide-react";
import { recipes } from "../data/mockData.js";
import { applyAiSuggestion, archiveRecipe, publishRecipe, runRecipeSafetyCheck, saveRecipeDraft } from "../api/recipeManagement.js";

const editorSteps = [
  { id: "basic-info", label: "Thông tin cơ bản", state: "Hoàn tất" },
  { id: "ingredients", label: "Nguyên liệu", state: "Cảnh báo" },
  { id: "instructions", label: "Hướng dẫn nấu", state: "Hoàn tất" },
  { id: "nutrition", label: "Dinh dưỡng", state: "Hoàn tất" },
  { id: "safety-tags", label: "Tags & an toàn", state: "Cảnh báo" },
  { id: "publish", label: "Xem trước & xuất bản", state: "Chưa hoàn tất" }
];

const ingredients = [
  { name: "Quinoa", amount: "1", unit: "cup", note: "đã nấu", status: "Đã khớp DB" },
  { name: "Đậu gà", amount: "200", unit: "g", note: "nướng nhẹ", status: "Đã khớp DB" },
  { name: "Sốt tahini chanh", amount: "2", unit: "muỗng", note: "tự pha", status: "Chưa khớp DB" }
];

const instructionSteps = [
  { order: 1, text: "Rửa quinoa dưới vòi nước lạnh và nấu với 2 cup nước muối nhẹ.", timer: "15" },
  { order: 2, text: "Cắt cà chua bi, trộn với dầu olive, rau xanh và đậu gà nướng.", timer: "8" },
  { order: 3, text: "Rưới sốt tahini chanh, thêm rau thơm và phục vụ khi còn ấm.", timer: "" }
];

const nutritionFields = [
  { label: "Calories", value: 450, unit: "kcal" },
  { label: "Protein", value: 24, unit: "g" },
  { label: "Carb", value: 56, unit: "g" },
  { label: "Fat", value: 12, unit: "g" },
  { label: "Fiber", value: 9, unit: "g" },
  { label: "Sodium", value: 420, unit: "mg" },
  { label: "Sugar", value: 6, unit: "g" },
  { label: "Cholesterol", value: 0, unit: "mg" }
];

const aiSuggestions = [
  { id: "heart-tag", text: 'Gắn tag "Tốt cho tim mạch"', confidence: "86%" },
  { id: "olive-oil", text: "Giảm 20% dầu olive", confidence: "78%" },
  { id: "nut-check", text: 'Kiểm tra allergen "Hạt"', confidence: "91%" }
];

const publishChecklist = [
  { label: "Có ảnh món ăn", state: "completed", help: "Đã có ảnh cover." },
  { label: "Có tên và mô tả", state: "completed", help: "Thông tin cơ bản đã đủ." },
  { label: "Có ít nhất 1 nguyên liệu", state: "completed", help: "Đã thêm 3 nguyên liệu." },
  { label: "Tất cả nguyên liệu đã khớp Nutrition Database", state: "missing", help: "Sốt tahini chanh chưa khớp Nutrition Database." },
  { label: "Có hướng dẫn nấu", state: "completed", help: "Đã có 3 bước nấu." },
  { label: "Dinh dưỡng đã tính", state: "completed", help: "Tính từ 3/3 dòng nguyên liệu, 1 dòng cần xác nhận lại." },
  { label: "Allergen tags đã xác nhận", state: "warning", help: "Cần xác nhận allergen Hạt." },
  { label: "Safety check không có lỗi nghiêm trọng", state: "missing", help: "Critical: Có hạt, cần duyệt trước khi xuất bản." }
];

function confirmArchive(recipe) {
  const reason = window.prompt(`Nhập lý do lưu trữ "${recipe.name}":`);
  if (!reason) return;
  if (window.confirm("Công thức đã được người dùng lưu hoặc thêm vào kế hoạch. Xác nhận lưu trữ thay vì xóa cứng?")) {
    archiveRecipe(recipe.id, reason);
  }
}

export default function RecipeFormPage({ mode }) {
  const { id } = useParams();
  const recipe = recipes.find((item) => item.id === id) ?? recipes[0];
  const isCreate = mode === "create";
  const [showPreview, setShowPreview] = useState(false);
  const [nutritionMode, setNutritionMode] = useState("auto");
  const [activeStep, setActiveStep] = useState(editorSteps[0].id);
  const [calculationResult, setCalculationResult] = useState("Dữ liệu dinh dưỡng đã được tính từ 3/3 nguyên liệu, 1 dòng cần xác nhận DB.");

  const blockedChecklist = useMemo(() => publishChecklist.filter((item) => item.state === "missing"), []);
  const hasCriticalSafety = true;
  const canPublish = blockedChecklist.length === 0 && !hasCriticalSafety;

  useEffect(() => {
    const sections = editorSteps.map((step) => document.getElementById(step.id)).filter(Boolean);
    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries.filter((entry) => entry.isIntersecting).sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
        if (visible?.target?.id) setActiveStep(visible.target.id);
      },
      { rootMargin: "-190px 0px -55% 0px", threshold: [0.15, 0.35, 0.6] }
    );

    sections.forEach((section) => observer.observe(section));
    return () => observer.disconnect();
  }, []);

  function handlePublish() {
    if (!canPublish) return;
    publishRecipe({ recipeId: recipe.id });
  }

  function handleOverridePublish() {
    if (window.confirm("Công thức này còn cảnh báo dinh dưỡng hoặc allergen. Bạn có chắc muốn xuất bản không?")) {
      publishRecipe({ recipeId: recipe.id, overrideWarnings: true });
    }
  }

  return (
    <div className="page-stack recipe-editor-page">
      <div className="page-toolbar recipe-editor-title">
        <div>
          <p className="eyebrow">Recipe Studio</p>
          <h2>{isCreate ? "Tạo công thức mới" : "Chỉnh sửa công thức"}</h2>
          <p>Tạo công thức có cấu trúc, kiểm soát dinh dưỡng, dị ứng và khả năng cá nhân hóa bởi AI.</p>
        </div>
      </div>

      <div className="recipe-action-bar">
        <span className="source-badge">Trạng thái: Bản nháp</span>
        <div className="button-row">
          <button className="ghost-btn" onClick={() => setShowPreview(true)}><Eye size={16} /> Xem trước</button>
          <button className="ghost-btn" onClick={() => saveRecipeDraft({ recipeId: recipe.id })}><Save size={16} /> Lưu nháp</button>
          <button className="ghost-btn" onClick={() => runRecipeSafetyCheck(recipe.id)}><ShieldCheck size={16} /> Chạy kiểm tra an toàn</button>
          <button className="primary-btn disabled-btn" disabled={!canPublish} title="Cần hoàn tất checklist trước khi xuất bản." onClick={handlePublish}>Xuất bản</button>
          {!canPublish ? <button className="ghost-btn" onClick={handleOverridePublish}>Override có xác nhận</button> : null}
        </div>
      </div>

      <nav className="recipe-stepper" aria-label="Recipe editor sections">
        {editorSteps.map((step) => (
          <a className={activeStep === step.id ? "active" : ""} href={`#${step.id}`} key={step.id}>
            {step.label}
            <span className={`step-state ${step.state === "Hoàn tất" ? "done" : step.state === "Cảnh báo" ? "warn" : "todo"}`}>{step.state}</span>
          </a>
        ))}
      </nav>

      <section className="recipe-editor-section basic-info-section" id="basic-info">
        <div className="section-heading">
          <h2>Thông tin cơ bản</h2>
          <p>Ảnh, mô tả, thời gian nấu, trạng thái và nguồn công thức.</p>
        </div>
        <div className="recipe-basic-grid">
          <div className="media-upload recipe-media-upload">
            <img src={recipe.image} alt={recipe.name} />
            <button><Camera size={22} /> Thay ảnh món ăn</button>
          </div>
          <div className="form-card">
            <label>Tên công thức<input defaultValue={isCreate ? "" : recipe.name} placeholder="Ví dụ: Bowl quinoa Địa Trung Hải" /></label>
            <label>Mô tả<textarea defaultValue="Một bữa ăn giàu dinh dưỡng với đậu gà nướng, cà chua, rau xanh và sốt chanh tahini." /></label>
            <div className="macro-input-grid compact-form-grid">
              <label>Cuisine<select defaultValue={recipe.cuisine}><option>Địa Trung Hải</option><option>Việt Nam</option><option>Bắc Âu</option></select></label>
              <label>Mùa phù hợp<select><option>Mùa hè</option><option>Mùa xuân</option><option>Quanh năm</option></select></label>
              <label>Khẩu phần<input type="number" min="1" defaultValue="2" /></label>
              <label>Chuẩn bị (phút)<input type="number" min="0" defaultValue="10" /></label>
              <label>Thời gian nấu (phút)<input type="number" min="0" defaultValue="25" /></label>
              <label>Tổng thời gian (phút)<input type="number" min="0" defaultValue="35" /></label>
              <label>Độ khó<select><option>Dễ</option><option>Trung bình</option><option>Khó</option></select></label>
              <label>Trạng thái<select><option>Bản nháp</option><option>Chờ duyệt</option><option>Đã xuất bản</option></select></label>
              <label>Nguồn<select><option>Thủ công</option><option>AI tạo</option><option>Import</option></select></label>
            </div>
          </div>
        </div>
      </section>

      <section className="recipe-editor-section" id="ingredients">
        <div className="section-heading">
          <h2>Nguyên liệu</h2>
          <p>Chọn từ Nutrition Database để tính dinh dưỡng chính xác.</p>
        </div>
        <div className="structured-list">
          {ingredients.map((ingredient) => (
            <div className="structured-ingredient-row" key={ingredient.name}>
              <GripVertical size={16} />
              <label>Nguyên liệu<input defaultValue={ingredient.name} /></label>
              <label>Số lượng<input defaultValue={ingredient.amount} /></label>
              <label>Đơn vị<input defaultValue={ingredient.unit} /></label>
              <label>Ghi chú<input defaultValue={ingredient.note} /></label>
              <span className={`safety-badge ${ingredient.status === "Đã khớp DB" ? "ok" : "warning"}`}>{ingredient.status}</span>
            </div>
          ))}
        </div>
        <div className="warning-panel mini">
          <ShieldAlert size={16} />
          <span>1 nguyên liệu chưa khớp Nutrition Database: Sốt tahini chanh.</span>
        </div>
        <div className="button-row">
          <button className="ghost-btn"><CirclePlus size={16} /> Thêm nguyên liệu</button>
          <button className="primary-btn" onClick={() => setCalculationResult("Đã tính lại dinh dưỡng. Còn 1 nguyên liệu chưa khớp DB cần xác nhận.")}>Tính lại dinh dưỡng</button>
        </div>
        <p className="calculation-result">{calculationResult}</p>
      </section>

      <section className="recipe-editor-section" id="instructions">
        <div className="section-heading row-heading">
          <div>
            <h2>Hướng dẫn nấu</h2>
            <p>Các bước có timer, drag để sắp xếp và tùy chọn AI refine.</p>
          </div>
          <details className="ai-refine-menu">
            <summary><Wand2 size={16} /> AI refine</summary>
            <div>
              {["Làm rõ hướng dẫn", "Rút gọn bước nấu", "Đề xuất giảm calo", "Đề xuất giảm natri", "Gợi ý phiên bản ít carb", "Kiểm tra xung đột dị ứng"].map((item) => <button key={item}>{item}</button>)}
            </div>
          </details>
        </div>
        <div className="instruction-list">
          {instructionSteps.map((step) => (
            <div className="instruction-row" key={step.order}>
              <GripVertical size={16} />
              <span className="step-number">{step.order}</span>
              <textarea defaultValue={step.text} />
              <label><Timer size={14} /> Timer (phút)<input type="number" min="0" defaultValue={step.timer} placeholder="Tùy chọn" /></label>
              <button className="icon-link" aria-label="Xóa bước"><X size={16} /></button>
            </div>
          ))}
        </div>
        <button className="dashed-btn"><CirclePlus size={16} /> Thêm bước nấu</button>
      </section>

      <section className="recipe-editor-grid half-grid">
        <article className="recipe-editor-section" id="nutrition">
          <div className="section-heading">
            <h2>Dinh dưỡng</h2>
            <p>Dữ liệu dinh dưỡng đã được tính từ 3/3 nguyên liệu.</p>
          </div>
          <div className="segmented-control">
            <button className={nutritionMode === "auto" ? "active" : ""} onClick={() => setNutritionMode("auto")}>Tự động tính từ nguyên liệu</button>
            <button className={nutritionMode === "manual" ? "active" : ""} onClick={() => setNutritionMode("manual")}>Ghi đè thủ công</button>
          </div>
          <div className="macro-input-grid nutrition-unit-grid">
            {nutritionFields.map((field) => (
              <label key={field.label}>
                {field.label}
                <div className="unit-input">
                  <input type="number" min="0" defaultValue={field.value} readOnly={nutritionMode === "auto"} />
                  <span>{field.unit}</span>
                </div>
              </label>
            ))}
          </div>
          <div className="micronutrient-grid compact-micronutrients">
            {["Iron 18%", "Vitamin C 45%", "Zinc 12%", "B12 5%"].map((item) => <span key={item}>{item}</span>)}
          </div>
          <button className="ghost-btn add-micro-btn">+ Thêm vi chất</button>
        </article>

        <article className="recipe-editor-section" id="safety-tags">
          <div className="section-heading">
            <h2>Tags & an toàn</h2>
            <p>Kiểm soát allergen, diet tags và cảnh báo safety trước khi publish.</p>
          </div>
          <div className="tag-section-grid">
            <div><h3>Allergen tags</h3><span className="chip danger">Hạt</span><span className="chip">+ thêm</span></div>
            <div><h3>Diet tags</h3><span className="chip active">Vegan</span><span className="chip active">Gluten-free</span></div>
            <div><h3>Health tags</h3><span className="chip">Tốt cho tim mạch</span><span className="chip">Chống viêm</span></div>
            <div><h3>Safety warnings</h3><span className="severity-pill critical">Critical: Có hạt</span><span className="severity-pill warning">Warning: Natri cao</span><span className="severity-pill delayed">Review: Cần chuyên gia duyệt</span></div>
          </div>
          <div className="button-row">
            <button className="ghost-btn"><ShieldCheck size={16} /> Chạy kiểm tra an toàn</button>
            <button className="primary-btn"><Sparkles size={16} /> Áp dụng gợi ý AI</button>
          </div>
        </article>
      </section>

      <section className="ai-banner recipe-ai-insight compact-ai-insight">
        <div className="ai-icon"><Sparkles size={22} /></div>
        <div>
          <h2>NutriChef AI Insight · Độ tin cậy 86%</h2>
          <p>Nguồn phân tích: Nutrition Database + ingredient tags.</p>
          <div className="ai-suggestion-grid compact-ai-suggestions">
            {aiSuggestions.map((suggestion) => (
              <article className="ai-suggestion-card" key={suggestion.id}>
                <strong>{suggestion.text}</strong>
                <span>Confidence {suggestion.confidence}</span>
                <div className="button-row">
                  <button className="primary-btn" onClick={() => applyAiSuggestion(suggestion.id)}>Áp dụng</button>
                  <button className="ghost-btn">Bỏ qua</button>
                </div>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="recipe-editor-section" id="publish">
        <div className="section-heading row-heading">
          <div>
            <h2>Xem trước & xuất bản</h2>
            <p>Kiểm tra checklist trước khi công thức xuất hiện trên mobile app.</p>
          </div>
          <button className="ghost-btn" onClick={() => setShowPreview(true)}><Eye size={16} /> Xem trước trên mobile</button>
        </div>
        <div className="publish-checklist status-checklist">
          {publishChecklist.map((item) => (
            <label className={`check-${item.state}`} key={item.label}>
              {item.state === "completed" ? <CheckCircle2 size={17} /> : item.state === "warning" ? <ShieldAlert size={17} /> : <X size={17} />}
              <span>
                <strong>{item.label}</strong>
                <small>{item.help}</small>
              </span>
            </label>
          ))}
        </div>
        {!canPublish ? <p className="publish-helper">Cần hoàn tất checklist trước khi xuất bản.</p> : null}
      </section>

      {showPreview ? (
        <aside className="preview-panel" aria-label="Xem trước công thức trên mobile app">
          <button className="icon-link preview-close" onClick={() => setShowPreview(false)} aria-label="Đóng preview"><X size={18} /></button>
          <img src={recipe.image} alt={recipe.name} />
          <h2>{recipe.name}</h2>
          <span className="chip active">Phù hợp mẫu 92%</span>
          <p>{recipe.calories} kcal · P {recipe.protein}g · C {recipe.carb}g · F {recipe.fat}g</p>
          <div className="warning-panel mini"><ShieldAlert size={16} /> Allergen warning: Có hạt, cần xác nhận.</div>
          <h3>Ingredients</h3>
          <ul>{ingredients.map((item) => <li key={item.name}>{item.amount} {item.unit} {item.name}</li>)}</ul>
          <h3>Steps</h3>
          <ol>{instructionSteps.map((step) => <li key={step.order}>{step.text}</li>)}</ol>
          <p className="soft-copy">Health note: giàu chất xơ, phù hợp bữa trưa cân bằng.</p>
        </aside>
      ) : null}

      <div className="danger-footer">
        {isCreate ? (
          <Link className="danger-link" to="/recipes">Hủy tạo công thức</Link>
        ) : (
          <button className="danger-link" onClick={() => confirmArchive(recipe)}><Archive size={16} /> Lưu trữ công thức</button>
        )}
        <div className="button-row">
          <Link className="ghost-btn" to="/recipes">Hủy</Link>
          <button className="ghost-btn" onClick={() => saveRecipeDraft({ recipeId: recipe.id })}>Lưu nháp</button>
          <button className="primary-btn wide disabled-btn" disabled={!canPublish} title="Cần hoàn tất checklist trước khi xuất bản." onClick={handlePublish}>Xuất bản lên ứng dụng</button>
        </div>
      </div>
    </div>
  );
}
