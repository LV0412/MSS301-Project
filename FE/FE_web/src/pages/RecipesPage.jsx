import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { BookOpen, Pencil, Plus, Search, Trash2 } from "lucide-react";
import {
  deleteRecipe,
  getAllergens,
  getCategories,
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

function formatDate(value) {
  if (!value) return "-";
  return new Intl.DateTimeFormat("vi-VN", {
    dateStyle: "short",
    timeStyle: "short"
  }).format(new Date(value));
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
    if (!window.confirm(`Xóa công thức “${recipe.title}”? Thao tác này không thể hoàn tác.`)) return;
    try {
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

  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">Recipe Service</p>
          <h2>Quản lý công thức</h2>
          <p>Dữ liệu được đọc và cập nhật trực tiếp từ Recipe-service.</p>
        </div>
        <Link className="primary-btn" to="/recipes/new"><Plus size={17} /> Thêm công thức</Link>
      </div>

      <section className="kpi-grid four">
        <article className="kpi-card"><div className="kpi-icon"><BookOpen size={19} /></div><span>Tổng kết quả</span><strong>{page.totalElements || 0}</strong><small>Theo bộ lọc hiện tại</small></article>
        <article className="kpi-card"><span>Danh mục</span><strong>{categories.length}</strong><small>Đang có trong catalog</small></article>
        <article className="kpi-card"><span>Dị ứng</span><strong>{allergens.length}</strong><small>Nhãn dị ứng có thể loại trừ</small></article>
        <article className="kpi-card"><span>Trang hiện tại</span><strong>{page.totalPages ? page.number + 1 : 0}/{page.totalPages || 0}</strong><small>10 công thức mỗi trang</small></article>
      </section>

      <section className="panel">
        <div className="filter-grid recipe-management-filter-grid">
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
            {DIET_TYPES.map((item) => <option value={item} key={item}>{item.replaceAll("_", " ")}</option>)}
          </select>
          <select value={excludedAllergenIds} onChange={(event) => { setExcludedAllergenIds(event.target.value); setPageNumber(0); }}>
            <option value="">Không loại trừ dị ứng</option>
            {allergens.map((item) => <option value={item.allergenId} key={item.allergenId}>Không có {item.name}</option>)}
          </select>
          <button className="ghost-btn" onClick={resetFilters}>Xóa lọc</button>
        </div>
      </section>

      {error ? <section className="warning-panel"><span>{error}</span></section> : null}

      <section className="panel">
        <div className="table-scroll">
          <table className="data-table recipe-table">
            <thead><tr><th>Công thức</th><th>Danh mục</th><th>Thời gian</th><th>Dinh dưỡng</th><th>Dị ứng</th><th>Diet tags</th><th>Cập nhật</th><th>Hành động</th></tr></thead>
            <tbody>
              {loading ? <tr><td colSpan="8">Đang tải công thức...</td></tr> : null}
              {!loading && !page.content.length ? <tr><td colSpan="8">Không tìm thấy công thức phù hợp.</td></tr> : null}
              {!loading && page.content.map((recipe) => (
                <tr key={recipe.recipeId}>
                  <td className="recipe-name">
                    {recipe.imageUrl ? <img src={recipe.imageUrl} alt={recipe.title} /> : <span className="food-icon">🍽️</span>}
                    <div><strong>{recipe.title}</strong><span>{recipe.difficulty} · {recipe.servings} khẩu phần</span></div>
                  </td>
                  <td><span className="chip">{recipe.category?.name || "-"}</span></td>
                  <td>{(recipe.preparationTime || 0) + (recipe.cookTime || 0)} phút</td>
                  <td><div className="macro-row"><span>{recipe.nutrition?.calories ?? 0} kcal</span><span>P {recipe.nutrition?.protein ?? 0}g</span><span>C {recipe.nutrition?.carbs ?? 0}g</span><span>F {recipe.nutrition?.fat ?? 0}g</span></div></td>
                  <td>{[...new Map((recipe.ingredients || []).flatMap((item) => item.allergens || []).map((item) => [item.allergenId, item])).values()].map((item) => <span className="chip danger" key={item.allergenId}>{item.name}</span>)}</td>
                  <td>{(recipe.dietTypes || []).map((item) => <span className="chip" key={item}>{item.replaceAll("_", " ")}</span>)}</td>
                  <td>{formatDate(recipe.updatedAt)}</td>
                  <td className="actions-cell">
                    <Link className="icon-link" to={`/recipes/${recipe.recipeId}/edit`} title="Chỉnh sửa"><Pencil size={17} /></Link>
                    <button className="icon-link" onClick={() => handleDelete(recipe)} title="Xóa"><Trash2 size={17} /></button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="table-footer">
          <span>Hiển thị {shownRange} trong {page.totalElements || 0} công thức</span>
          <div className="pagination">
            <button disabled={page.number <= 0} onClick={() => setPageNumber((value) => value - 1)}>‹</button>
            {pageItems(page).map((item) => <button className={item === page.number ? "active" : ""} onClick={() => setPageNumber(item)} key={item}>{item + 1}</button>)}
            <button disabled={page.number >= page.totalPages - 1} onClick={() => setPageNumber((value) => value + 1)}>›</button>
          </div>
        </div>
      </section>
    </div>
  );
}
