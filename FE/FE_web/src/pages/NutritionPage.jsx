import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Database, Eye, Layers3, Pencil, Plus, RefreshCw, Search, ShieldAlert, Tags, Trash2, X } from "lucide-react";
import {
  createAllergen,
  createCategory,
  deleteAllergen,
  deleteCategory,
  deleteIngredient,
  getAllergen,
  getAllergens,
  getCategories,
  getCategory,
  getIngredient,
  getIngredients,
  updateAllergen,
  updateCategory
} from "../api/recipeManagement.js";

const PAGE_SIZE = 10;

function CatalogPanel({
  title,
  description,
  idKey,
  supportsDescription = false,
  loader,
  creator,
  updater,
  remover,
  getter
}) {
  const [items, setItems] = useState([]);
  const [name, setName] = useState("");
  const [itemDescription, setItemDescription] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [detail, setDetail] = useState(null);
  const [detailLoading, setDetailLoading] = useState(false);

  async function load() {
    setLoading(true);
    setError("");
    try {
      const response = await loader({ page: 0, size: 200, sort: "name,asc" });
      setItems(response.content || []);
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  async function handleCreate(event) {
    event.preventDefault();
    if (!name.trim()) return;
    try {
      await creator(supportsDescription
        ? { name: name.trim(), description: itemDescription.trim() || null }
        : { name: name.trim() });
      setName("");
      setItemDescription("");
      await load();
    } catch (requestError) {
      setError(requestError.message);
    }
  }

  async function handleEdit(item) {
    const nextName = window.prompt(`Tên mới cho “${item.name}”:`, item.name);
    if (!nextName?.trim()) return;
    const nextDescription = supportsDescription
      ? window.prompt("Mô tả:", item.description || "")
      : undefined;
    try {
      await updater(item[idKey], supportsDescription
        ? { name: nextName.trim(), description: nextDescription?.trim() || null }
        : { name: nextName.trim() });
      await load();
    } catch (requestError) {
      setError(requestError.message);
    }
  }

  async function handleDelete(item) {
    if (!window.confirm(`Xóa “${item.name}”? Backend sẽ từ chối nếu dữ liệu đang được sử dụng.`)) return;
    try {
      await remover(item[idKey]);
      await load();
    } catch (requestError) {
      setError(requestError.message);
    }
  }

  async function handleView(item) {
    setDetailLoading(true);
    setError("");
    try {
      setDetail(await getter(item[idKey]));
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setDetailLoading(false);
    }
  }

  return (
    <section className="panel catalog-panel">
      <div className="section-heading"><h2>{title}</h2><p>{description}</p></div>
      <form className={`catalog-form-grid ${supportsDescription ? "" : "compact"}`} onSubmit={handleCreate}>
        <label className="field"><span>Tên</span><input maxLength="100" value={name} onChange={(event) => setName(event.target.value)} /></label>
        {supportsDescription ? <label className="field"><span>Mô tả</span><input maxLength="1000" value={itemDescription} onChange={(event) => setItemDescription(event.target.value)} /></label> : null}
        <button className="primary-btn" type="submit">Thêm mới</button>
      </form>
      {error ? <div className="warning-panel mini"><span>{error}</span></div> : null}
      <div className="table-scroll">
        <table className="data-table">
          <thead><tr><th>Tên</th>{supportsDescription ? <th>Mô tả</th> : null}<th>Hành động</th></tr></thead>
          <tbody>
            {loading ? <tr><td colSpan={supportsDescription ? 3 : 2}>Đang tải...</td></tr> : null}
            {!loading && !items.length ? <tr><td colSpan={supportsDescription ? 3 : 2}>Chưa có dữ liệu.</td></tr> : null}
            {!loading && items.map((item) => (
              <tr key={item[idKey]}>
                <td><strong>{item.name}</strong></td>
                {supportsDescription ? <td>{item.description || "-"}</td> : null}
                <td className="actions-cell">
                  <button className="icon-link" type="button" onClick={() => handleView(item)} title="Xem chi tiết"><Eye size={16} /></button>
                  <button className="icon-link" type="button" onClick={() => handleEdit(item)} title="Chỉnh sửa"><Pencil size={16} /></button>
                  <button className="icon-link" type="button" onClick={() => handleDelete(item)} title="Xóa"><Trash2 size={16} /></button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {(detail || detailLoading) ? (
        <div className="modal-backdrop" role="dialog" aria-modal="true">
          <article className="panel nutrition-detail-modal">
            <div className="recipe-detail-header">
              <div>
                <p className="eyebrow">Recipe Service</p>
                <h2>{detail?.name || "Đang tải..."}</h2>
              </div>
              <button className="icon-btn" type="button" onClick={() => setDetail(null)} aria-label="Đóng"><X size={18} /></button>
            </div>
            {detailLoading ? <div className="empty-state">Đang tải chi tiết...</div> : null}
            {!detailLoading && detail ? (
              <div className="nutrition-detail-grid">
                <div><span>Mã</span><strong>#{detail[idKey]}</strong></div>
                <div><span>Tên</span><strong>{detail.name}</strong></div>
                {supportsDescription ? <div className="span-2"><span>Mô tả</span><p>{detail.description || "Chưa có mô tả."}</p></div> : null}
              </div>
            ) : null}
          </article>
        </div>
      ) : null}
    </section>
  );
}

export default function NutritionPage() {
  const [page, setPage] = useState(0);
  const [query, setQuery] = useState("");
  const [search, setSearch] = useState("");
  const [data, setData] = useState({ content: [], totalElements: 0, totalPages: 0 });
  const [catalogStats, setCatalogStats] = useState({ categories: 0, allergens: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [detail, setDetail] = useState(null);
  const [detailLoading, setDetailLoading] = useState(false);

  async function loadIngredients(targetPage = page, targetQuery = search) {
    setLoading(true);
    setError("");
    try {
      const response = await getIngredients({
        page: targetPage,
        size: PAGE_SIZE,
        sort: "name,asc",
        query: targetQuery
      });
      setData(response);
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setLoading(false);
    }
  }

  async function loadCatalogStats() {
    try {
      const [categoryPage, allergenPage] = await Promise.all([
        getCategories({ page: 0, size: 1 }),
        getAllergens({ page: 0, size: 1 })
      ]);
      setCatalogStats({
        categories: categoryPage.totalElements || 0,
        allergens: allergenPage.totalElements || 0
      });
    } catch {
      setCatalogStats((current) => current);
    }
  }

  useEffect(() => {
    loadIngredients(page, search);
  }, [page, search]);

  useEffect(() => { loadCatalogStats(); }, []);

  function handleSearch(event) {
    event.preventDefault();
    setPage(0);
    setSearch(query.trim());
  }

  async function handleDelete(ingredient) {
    if (!window.confirm(`Xóa nguyên liệu “${ingredient.name}”? Công thức đang sử dụng nguyên liệu này có thể ngăn thao tác xóa.`)) return;
    setError("");
    try {
      await deleteIngredient(ingredient.ingredientId);
      const targetPage = data.content.length === 1 && page > 0 ? page - 1 : page;
      if (targetPage !== page) setPage(targetPage);
      else await loadIngredients(targetPage, search);
    } catch (requestError) {
      setError(requestError.message);
    }
  }

  async function handleViewIngredient(ingredient) {
    setDetailLoading(true);
    setError("");
    try {
      setDetail(await getIngredient(ingredient.ingredientId));
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setDetailLoading(false);
    }
  }

  async function handleRefresh() {
    await Promise.all([
      loadIngredients(page, search),
      loadCatalogStats()
    ]);
  }

  const taggedCount = (data.content || []).filter((item) => item.allergens?.length).length;

  return (
    <div className="page-stack nutrition-page">
      <div className="page-toolbar nutrition-toolbar">
        <div><p className="eyebrow">Recipe Service</p><h2>Danh mục nguyên liệu</h2><p>Quản lý nguyên liệu và nhãn dị ứng dùng trong công thức.</p></div>
        <div className="button-row">
          <button className="ghost-btn" type="button" onClick={handleRefresh} disabled={loading}><RefreshCw size={16} /> Làm mới</button>
          <Link className="primary-btn" to="/nutrition/new"><Plus size={17} /> Thêm nguyên liệu</Link>
        </div>
      </div>

      <section className="nutrition-kpi-grid">
        <article className="kpi-card nutrition-kpi-card"><div className="kpi-icon"><Database size={18} /></div><span>Tổng nguyên liệu</span><strong>{data.totalElements || 0}</strong><small>Dữ liệu từ Recipe Service</small></article>
        <article className="kpi-card nutrition-kpi-card"><div className="kpi-icon"><ShieldAlert size={18} /></div><span>Có nhãn dị ứng</span><strong>{taggedCount}</strong><small>Trong trang hiện tại</small></article>
        <article className="kpi-card nutrition-kpi-card"><div className="kpi-icon"><Layers3 size={18} /></div><span>Danh mục</span><strong>{catalogStats.categories}</strong><small>Catalog công thức đang dùng</small></article>
        <article className="kpi-card nutrition-kpi-card warm"><div className="kpi-icon"><Tags size={18} /></div><span>Nhãn dị ứng</span><strong>{catalogStats.allergens}</strong><small>Dùng cho bộ lọc an toàn</small></article>
      </section>

      <section className="panel nutrition-filter-panel">
        <form className="nutrition-filter-grid" onSubmit={handleSearch}>
          <label className="field search-field"><Search size={16} /><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Tìm theo tên nguyên liệu..." /></label>
          <button className="ghost-btn" type="submit" disabled={loading}>Tìm kiếm</button>
          {search ? <button className="ghost-btn" type="button" onClick={() => { setQuery(""); setPage(0); setSearch(""); }}>Xóa bộ lọc</button> : null}
        </form>
      </section>

      {error ? <section className="warning-panel"><ShieldAlert size={20} /><div><strong>Không thể tải dữ liệu nguyên liệu</strong><p>{error}</p><button className="ghost-btn" onClick={() => loadIngredients(page, search)}>Thử lại</button></div></section> : null}

      <section className="panel nutrition-table-panel">
        <div className="section-heading nutrition-table-heading">
          <div>
            <h2>Danh sách nguyên liệu</h2>
            <p>Hiển thị nguyên liệu theo bộ lọc hiện tại và các nhãn dị ứng liên quan.</p>
          </div>
          <span>{data.totalElements || 0} nguyên liệu</span>
        </div>
        <div className="table-scroll">
          <table className="data-table nutrition-table">
            <thead><tr><th>Nguyên liệu</th><th>Mã</th><th>Nhãn dị ứng</th><th>Hành động</th></tr></thead>
            <tbody>
              {loading ? <tr><td colSpan="4">Đang tải nguyên liệu...</td></tr> : null}
              {!loading && !(data.content || []).length ? <tr><td colSpan="4">Không có nguyên liệu phù hợp.</td></tr> : null}
              {!loading && (data.content || []).map((item) => (
                <tr key={item.ingredientId}>
                  <td className="person-cell nutrition-ingredient-cell"><span className="food-icon">🥗</span><strong>{item.name}</strong></td>
                  <td>#{item.ingredientId}</td>
                  <td>{item.allergens?.length ? item.allergens.map((allergen) => <span className="chip danger" key={allergen.allergenId}>{allergen.name}</span>) : <span className="muted-text">Không có</span>}</td>
                  <td className="actions-cell">
                    <button className="icon-link" type="button" onClick={() => handleViewIngredient(item)} title="Xem chi tiết"><Eye size={16} /></button>
                    <Link className="icon-link" to={`/nutrition/${item.ingredientId}/edit`} title="Chỉnh sửa"><Pencil size={16} /></Link>
                    <button className="icon-link" type="button" onClick={() => handleDelete(item)} title="Xóa"><Trash2 size={16} /></button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="table-footer">
          <span>Trang {data.totalPages ? page + 1 : 0}/{data.totalPages || 0} · {data.totalElements || 0} nguyên liệu</span>
          <div className="pagination">
            <button disabled={loading || page === 0} onClick={() => setPage((value) => value - 1)}>‹</button>
            <button className="active" disabled>{page + 1}</button>
            <button disabled={loading || page + 1 >= (data.totalPages || 0)} onClick={() => setPage((value) => value + 1)}>›</button>
          </div>
        </div>
      </section>

      {(detail || detailLoading) ? (
        <div className="modal-backdrop" role="dialog" aria-modal="true">
          <article className="panel nutrition-detail-modal">
            <div className="recipe-detail-header">
              <div>
                <p className="eyebrow">Chi tiết nguyên liệu</p>
                <h2>{detail?.name || "Đang tải..."}</h2>
              </div>
              <button className="icon-btn" type="button" onClick={() => setDetail(null)} aria-label="Đóng"><X size={18} /></button>
            </div>
            {detailLoading ? <div className="empty-state">Đang tải dữ liệu nguyên liệu...</div> : null}
            {!detailLoading && detail ? (
              <div className="nutrition-detail-grid">
                <div><span>Mã nguyên liệu</span><strong>#{detail.ingredientId}</strong></div>
                <div><span>Tên nguyên liệu</span><strong>{detail.name}</strong></div>
                <div className="span-2">
                  <span>Nhãn dị ứng</span>
                  <div className="chip-row">
                    {detail.allergens?.length
                      ? detail.allergens.map((allergen) => <span className="chip danger" key={allergen.allergenId}>{allergen.name}</span>)
                      : <span className="muted-text">Không có nhãn dị ứng.</span>}
                  </div>
                </div>
              </div>
            ) : null}
          </article>
        </div>
      ) : null}

      <div className="nutrition-catalog-grid">
        <CatalogPanel
          title="Danh mục công thức"
          description="Category được chọn bắt buộc khi tạo công thức."
          idKey="categoryId"
          supportsDescription
          loader={getCategories}
          creator={createCategory}
          updater={updateCategory}
          remover={deleteCategory}
          getter={getCategory}
        />
        <CatalogPanel
          title="Nhãn dị ứng"
          description="Allergen được gắn vào nguyên liệu và dùng cho bộ lọc an toàn."
          idKey="allergenId"
          loader={getAllergens}
          creator={createAllergen}
          updater={updateAllergen}
          remover={deleteAllergen}
          getter={getAllergen}
        />
      </div>
    </div>
  );
}
