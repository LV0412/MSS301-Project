import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { AlertTriangle, BookOpen, Clock3, Eye, FilterX, MoreVertical, Pencil, Plus, Search, ShieldAlert, Tags, Trash2, X } from "lucide-react";
import {
  deleteRecipe,
  getAllergens,
  getCategories,
  getRecipe,
  getRecipes
} from "../api/recipeManagement.js";

const DIET_TYPES = [
  "NORMAL",
  "VEGETARIAN",
  "VEGAN",
  "OVO_VEGETARIAN",
  "LACTO_VEGETARIAN",
  "KETO",
  "LOW_CARB"
];

const DIFFICULTY_LABELS = {
  EASY: "Dễ",
  MEDIUM: "Trung bình",
  HARD: "Khó"
};

const DIET_LABELS = {
  NORMAL: "Thông thường",
  VEGETARIAN: "Chay",
  VEGAN: "Thuần chay",
  OVO_VEGETARIAN: "Chay có trứng",
  LACTO_VEGETARIAN: "Chay có sữa",
  KETO: "Keto",
  LOW_CARB: "Ít carb"
};

function formatDate(value) {
  if (!value) return "-";
  return new Intl.DateTimeFormat("vi-VN", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric"
  }).format(new Date(value));
}

function formatNumber(value) {
  return new Intl.NumberFormat("vi-VN").format(value || 0);
}

function roundMacro(value) {
  return Number(value || 0).toFixed(1).replace(".0", "");
}

function getRecipeAllergens(recipe) {
  return [...new Map((recipe.ingredients || [])
    .flatMap((item) => item.allergens || [])
    .map((item) => [item.allergenId, item]))
    .values()];
}

function pageItems(page) {
  return Array.from({ length: page.totalPages || 0 }, (_, index) => index)
    .filter((index) => Math.abs(index - page.number) <= 2);
}

export default function RecipesPage() {
  const [query, setQuery] = useState("");
  const [categoryId, setCategoryId] = useState("");
  const [dietType, setDietType] = useState("");
  const [excludedAllergenIds, setExcludedAllergenIds] = useState("");
  const [pageNumber, setPageNumber] = useState(0);
  const [page, setPage] = useState({ content: [], number: 0, totalPages: 0, totalElements: 0 });
  const [categories, setCategories] = useState([]);
  const [allergens, setAllergens] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [actionMenu, setActionMenu] = useState(null);
  const [detailRecipe, setDetailRecipe] = useState(null);
  const [detailLoading, setDetailLoading] = useState(false);

  useEffect(() => {
    Promise.all([
      getCategories({ page: 0, size: 200, sort: "name,asc" }),
      getAllergens({ page: 0, size: 200, sort: "name,asc" })
    ])
      .then(([categoryPage, allergenPage]) => {
        setCategories(categoryPage.content || []);
        setAllergens(allergenPage.content || []);
      })
      .catch((requestError) => setError(requestError.message));
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setLoading(true);
      setError("");
      getRecipes({
        query,
        categoryId,
        dietType,
        excludedAllergenIds: excludedAllergenIds ? [excludedAllergenIds] : undefined,
        page: pageNumber,
        size: 10,
        sort: "createdAt,desc"
      })
        .then(setPage)
        .catch((requestError) => setError(requestError.message))
        .finally(() => setLoading(false));
    }, 250);
    return () => window.clearTimeout(timer);
  }, [query, categoryId, dietType, excludedAllergenIds, pageNumber]);

  const shownRange = useMemo(() => {
    if (!page.totalElements) return "0";
    const from = page.number * (page.size || 10) + 1;
    const to = Math.min(from + page.content.length - 1, page.totalElements);
    return `${from}-${to}`;
  }, [page]);

  function resetFilters() {
    setQuery("");
    setCategoryId("");
    setDietType("");
    setExcludedAllergenIds("");
    setPageNumber(0);
  }

  async function handleDelete(recipe) {
    if (!window.confirm(`Xóa công thức "${recipe.title}"? Thao tác này không thể hoàn tác.`)) return;
    try {
      setActionMenu(null);
      await deleteRecipe(recipe.recipeId);
      if (page.content.length === 1 && pageNumber > 0) setPageNumber((value) => value - 1);
      else {
        const nextPage = await getRecipes({
          query,
          categoryId,
          dietType,
          excludedAllergenIds: excludedAllergenIds ? [excludedAllergenIds] : undefined,
          page: pageNumber,
          size: 10,
          sort: "createdAt,desc"
        });
        setPage(nextPage);
      }
    } catch (requestError) {
      setError(requestError.message);
    }
  }

  function openActionMenu(event, recipe) {
    const rect = event.currentTarget.getBoundingClientRect();
    const menuWidth = 240;
    const left = Math.min(rect.right - menuWidth, window.innerWidth - menuWidth - 16);
    setActionMenu({
      recipe,
      top: rect.bottom + 8,
      left: Math.max(16, left)
    });
  }

  async function handleViewDetail(recipe) {
    setActionMenu(null);
    setDetailLoading(true);
    setError("");
    try {
      const response = await getRecipe(recipe.recipeId);
      setDetailRecipe(response);
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setDetailLoading(false);
    }
  }

  return (
    <div className="page-stack recipe-admin-page">
      <div className="page-toolbar recipe-page-toolbar">
        <div>
          <p className="eyebrow">Recipe Service</p>
          <h2>Quản lý công thức</h2>
          <p>Quản lý danh sách công thức, danh mục, dị ứng và thông tin dinh dưỡng từ Recipe Service.</p>
        </div>
        <Link className="primary-btn" to="/recipes/new"><Plus size={17} /> Thêm công thức</Link>
      </div>

      <section className="recipe-kpi-grid">
        <article className="kpi-card recipe-kpi-card">
          <div className="kpi-icon"><BookOpen size={19} /></div>
          <span>Tổng công thức</span>
          <strong>{formatNumber(page.totalElements)}</strong>
          <small>Theo bộ lọc hiện tại</small>
        </article>
        <article className="kpi-card recipe-kpi-card">
          <div className="kpi-icon"><Tags size={19} /></div>
          <span>Danh mục</span>
          <strong>{categories.length}</strong>
          <small>Đang có trong catalog</small>
        </article>
        <article className="kpi-card recipe-kpi-card warm">
          <div className="kpi-icon"><ShieldAlert size={19} /></div>
          <span>Dị ứng</span>
          <strong>{allergens.length}</strong>
          <small>Nhãn có thể loại trừ</small>
        </article>
        <article className="kpi-card recipe-kpi-card">
          <div className="kpi-icon"><Clock3 size={19} /></div>
          <span>Trang hiện tại</span>
          <strong>{page.totalPages ? page.number + 1 : 0}/{page.totalPages || 0}</strong>
          <small>10 công thức mỗi trang</small>
        </article>
      </section>

      <section className="panel recipe-filter-panel">
        <div className="recipe-filter-grid">
          <label className="field search-field recipe-search-field">
            <Search size={16} />
            <input value={query} onChange={(event) => { setQuery(event.target.value); setPageNumber(0); }} placeholder="Tìm theo tên hoặc mô tả..." />
          </label>
          <select value={categoryId} onChange={(event) => { setCategoryId(event.target.value); setPageNumber(0); }}>
            <option value="">Tất cả danh mục</option>
            {categories.map((item) => <option value={item.categoryId} key={item.categoryId}>{item.name}</option>)}
          </select>
          <select value={dietType} onChange={(event) => { setDietType(event.target.value); setPageNumber(0); }}>
            <option value="">Tất cả chế độ ăn</option>
            {DIET_TYPES.map((item) => <option value={item} key={item}>{DIET_LABELS[item]}</option>)}
          </select>
          <select value={excludedAllergenIds} onChange={(event) => { setExcludedAllergenIds(event.target.value); setPageNumber(0); }}>
            <option value="">Không loại trừ dị ứng</option>
            {allergens.map((item) => <option value={item.allergenId} key={item.allergenId}>Không có {item.name}</option>)}
          </select>
          <button className="ghost-btn" type="button" onClick={resetFilters}><FilterX size={16} /> Xóa lọc</button>
        </div>
      </section>

      {error ? (
        <section className="warning-panel">
          <AlertTriangle size={18} />
          <span>{error}</span>
        </section>
      ) : null}

      <section className="panel recipe-table-panel">
        <div className="table-scroll">
          <table className="data-table recipe-table">
            <thead>
              <tr>
                <th>Công thức</th>
                <th>Danh mục</th>
                <th>Thời gian</th>
                <th>Dinh dưỡng</th>
                <th>Dị ứng</th>
                <th>Chế độ ăn</th>
                <th>Cập nhật</th>
                <th>Hành động</th>
              </tr>
            </thead>
            <tbody>
              {loading ? <tr><td colSpan="8">Đang tải công thức...</td></tr> : null}
              {!loading && !page.content.length ? <tr><td colSpan="8">Không tìm thấy công thức phù hợp.</td></tr> : null}
              {!loading && page.content.map((recipe) => {
                const recipeAllergens = getRecipeAllergens(recipe);
                return (
                  <tr key={recipe.recipeId}>
                    <td className="recipe-name">
                      {recipe.imageUrl ? <img src={recipe.imageUrl} alt={recipe.title} /> : <span className="food-icon">🍽</span>}
                      <div>
                        <strong>{recipe.title}</strong>
                        <span>{DIFFICULTY_LABELS[recipe.difficulty] || recipe.difficulty || "Chưa rõ"} · {recipe.servings || 0} khẩu phần</span>
                      </div>
                    </td>
                    <td><span className="chip">{recipe.category?.name || "-"}</span></td>
                    <td><strong>{(recipe.preparationTime || 0) + (recipe.cookTime || 0)} phút</strong></td>
                    <td>
                      <div className="macro-row">
                        <span>{roundMacro(recipe.nutrition?.calories)} kcal</span>
                        <span>P {roundMacro(recipe.nutrition?.protein)}g</span>
                        <span>C {roundMacro(recipe.nutrition?.carbs)}g</span>
                        <span>F {roundMacro(recipe.nutrition?.fat)}g</span>
                      </div>
                    </td>
                    <td>
                      {recipeAllergens.length
                        ? recipeAllergens.map((item) => <span className="chip danger" key={item.allergenId}>{item.name}</span>)
                        : <span className="muted-text">Không có</span>}
                    </td>
                    <td>
                      {(recipe.dietTypes || []).length
                        ? recipe.dietTypes.map((item) => <span className="chip" key={item}>{DIET_LABELS[item] || item.replaceAll("_", " ")}</span>)
                        : <span className="muted-text">Chưa gắn</span>}
                    </td>
                    <td>{formatDate(recipe.updatedAt)}</td>
                    <td className="actions-cell">
                      <button className="icon-link" type="button" onClick={() => handleViewDetail(recipe)} title="Xem chi tiết" aria-label="Xem chi tiết"><Eye size={17} /></button>
                      <Link className="icon-link" to={`/recipes/${recipe.recipeId}/edit`} title="Chỉnh sửa" aria-label="Chỉnh sửa"><Pencil size={17} /></Link>
                      <button className="icon-link" type="button" onClick={(event) => openActionMenu(event, recipe)} title="Mở hành động" aria-label="Mở hành động"><MoreVertical size={17} /></button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        <div className="table-footer">
          <span>Hiển thị {shownRange} trong {formatNumber(page.totalElements)} công thức</span>
          <div className="pagination">
            <button disabled={page.number <= 0} onClick={() => setPageNumber((value) => value - 1)}>‹</button>
            {pageItems(page).map((item) => <button className={item === page.number ? "active" : ""} onClick={() => setPageNumber(item)} key={item}>{item + 1}</button>)}
            <button disabled={page.number >= page.totalPages - 1} onClick={() => setPageNumber((value) => value + 1)}>›</button>
          </div>
        </div>
      </section>

      {actionMenu ? (
        <div className="floating-action-menu recipe-floating-menu" style={{ top: actionMenu.top, left: actionMenu.left }}>
          <div className="floating-action-header">
            <strong>Hành động công thức</strong>
            <button type="button" onClick={() => setActionMenu(null)} aria-label="Đóng menu"><X size={15} /></button>
          </div>
          <button type="button" onClick={() => handleViewDetail(actionMenu.recipe)}>
            <Eye size={16} />
            Xem chi tiết
          </button>
          <Link to={`/recipes/${actionMenu.recipe.recipeId}/edit`} onClick={() => setActionMenu(null)}>
            <Pencil size={16} />
            Chỉnh sửa
          </Link>
          <button className="danger-action" type="button" onClick={() => handleDelete(actionMenu.recipe)}>
            <Trash2 size={16} />
            Xóa công thức
          </button>
          <small>Các hành động này map với API xem, cập nhật và xóa công thức hiện có.</small>
        </div>
      ) : null}

      {(detailRecipe || detailLoading) ? (
        <div className="modal-backdrop" role="dialog" aria-modal="true">
          <article className="panel recipe-detail-modal">
            <div className="recipe-detail-header">
              <div>
                <p className="eyebrow">Chi tiết công thức</p>
                <h2>{detailRecipe?.title || "Đang tải..."}</h2>
              </div>
              <button className="icon-btn" type="button" onClick={() => setDetailRecipe(null)} aria-label="Đóng chi tiết"><X size={18} /></button>
            </div>

            {detailLoading ? <div className="empty-state">Đang tải dữ liệu công thức...</div> : null}

            {!detailLoading && detailRecipe ? (
              <div className="recipe-detail-content">
                {detailRecipe.imageUrl ? <img className="recipe-detail-image" src={detailRecipe.imageUrl} alt={detailRecipe.title} /> : null}
                <div className="recipe-detail-summary">
                  <span className="chip">{detailRecipe.category?.name || "Chưa có danh mục"}</span>
                  <span className="chip">{DIFFICULTY_LABELS[detailRecipe.difficulty] || detailRecipe.difficulty}</span>
                  <span className="chip">{(detailRecipe.preparationTime || 0) + (detailRecipe.cookTime || 0)} phút</span>
                  <span className="chip">{detailRecipe.servings || 0} khẩu phần</span>
                </div>
                <p>{detailRecipe.description || "Chưa có mô tả."}</p>

                <div className="recipe-detail-grid">
                  <section>
                    <h3>Dinh dưỡng</h3>
                    <div className="macro-row">
                      <span>{roundMacro(detailRecipe.nutrition?.calories)} kcal</span>
                      <span>P {roundMacro(detailRecipe.nutrition?.protein)}g</span>
                      <span>C {roundMacro(detailRecipe.nutrition?.carbs)}g</span>
                      <span>F {roundMacro(detailRecipe.nutrition?.fat)}g</span>
                    </div>
                  </section>
                  <section>
                    <h3>Chế độ ăn</h3>
                    <div className="chip-row">
                      {(detailRecipe.dietTypes || []).map((item) => <span className="chip" key={item}>{DIET_LABELS[item] || item}</span>)}
                    </div>
                  </section>
                </div>

                <section>
                  <h3>Nguyên liệu</h3>
                  <div className="recipe-detail-list">
                    {(detailRecipe.ingredients || []).map((item) => (
                      <div key={item.ingredientId}>
                        <strong>{item.name}</strong>
                        <span>{roundMacro(item.quantity)} {item.unit}</span>
                      </div>
                    ))}
                  </div>
                </section>

                <section>
                  <h3>Các bước thực hiện</h3>
                  <ol className="recipe-detail-steps">
                    {(detailRecipe.steps || []).map((step) => <li key={step.stepId}>{step.instruction}</li>)}
                  </ol>
                </section>
              </div>
            ) : null}
          </article>
        </div>
      ) : null}
    </div>
  );
}
