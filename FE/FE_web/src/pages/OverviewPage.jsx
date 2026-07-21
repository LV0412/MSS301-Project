import { useEffect, useMemo, useState } from "react";
import {
  AlertTriangle,
  CalendarDays,
  Database,
  SearchCheck,
  ServerCog,
  Users,
  Utensils
} from "lucide-react";
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  LabelList,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from "recharts";
import { getAllergens, getCategories, getIngredients, getRecipes } from "../api/recipeManagement.js";
import { getUsers } from "../api/userManagement.js";

const emptyPage = { content: [], totalElements: 0, totalPages: 0 };

function formatNumber(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) return "0";
  return new Intl.NumberFormat("vi-VN").format(Number(value));
}

function parseDate(value) {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

function isWithinDays(value, days) {
  const date = parseDate(value);
  if (!date) return false;
  const from = new Date();
  from.setHours(0, 0, 0, 0);
  from.setDate(from.getDate() - (days - 1));
  return date >= from;
}

function buildProfileGrowth(users) {
  const today = new Date();
  return [30, 25, 20, 15, 10, 5, 0].map((offset) => {
    const day = new Date(today);
    day.setDate(today.getDate() - offset);
    day.setHours(23, 59, 59, 999);
    const label = new Intl.DateTimeFormat("vi-VN", { day: "2-digit", month: "2-digit" }).format(day);
    const registered = users.filter((user) => {
      const createdAt = parseDate(user.createdAt);
      return createdAt && createdAt <= day;
    }).length;
    const updated = users.filter((user) => {
      const updatedAt = parseDate(user.updatedAt);
      return updatedAt && updatedAt <= day;
    }).length;
    return { day: label, registered, updated };
  });
}

function getRecipeAllergens(recipe) {
  return [...new Map((recipe.ingredients || [])
    .flatMap((item) => item.allergens || [])
    .map((allergen) => [allergen.allergenId, allergen]))
    .values()];
}

export default function OverviewPage() {
  const [usersPage, setUsersPage] = useState(emptyPage);
  const [recipesPage, setRecipesPage] = useState(emptyPage);
  const [ingredientsPage, setIngredientsPage] = useState(emptyPage);
  const [categoriesPage, setCategoriesPage] = useState(emptyPage);
  const [allergensPage, setAllergensPage] = useState(emptyPage);
  const [loading, setLoading] = useState(true);
  const [errors, setErrors] = useState([]);

  useEffect(() => {
    let active = true;

    async function loadOverview() {
      setLoading(true);
      const requests = await Promise.allSettled([
        getUsers({ page: 0, size: 1000, sort: "createdAt,desc" }),
        getRecipes({ page: 0, size: 500, sort: "createdAt,desc" }),
        getIngredients({ page: 0, size: 1000, sort: "name,asc" }),
        getCategories({ page: 0, size: 500, sort: "name,asc" }),
        getAllergens({ page: 0, size: 500, sort: "name,asc" })
      ]);

      if (!active) return;

      const [users, recipes, ingredients, categories, allergens] = requests;
      if (users.status === "fulfilled") setUsersPage(users.value || emptyPage);
      if (recipes.status === "fulfilled") setRecipesPage(recipes.value || emptyPage);
      if (ingredients.status === "fulfilled") setIngredientsPage(ingredients.value || emptyPage);
      if (categories.status === "fulfilled") setCategoriesPage(categories.value || emptyPage);
      if (allergens.status === "fulfilled") setAllergensPage(allergens.value || emptyPage);

      setErrors(requests
        .filter((result) => result.status === "rejected")
        .map((result) => result.reason?.message || "Không tải được dữ liệu."));
      setLoading(false);
    }

    loadOverview();
    return () => { active = false; };
  }, []);

  const users = usersPage.content || [];
  const recipes = recipesPage.content || [];
  const ingredients = ingredientsPage.content || [];
  const categories = categoriesPage.content || [];
  const allergens = allergensPage.content || [];

  const newUsersToday = users.filter((user) => isWithinDays(user.createdAt, 1)).length;
  const newUsers7Days = users.filter((user) => isWithinDays(user.createdAt, 7)).length;
  const newUsers30Days = users.filter((user) => isWithinDays(user.createdAt, 30)).length;
  const linkedUsers = users.filter((user) => user.authAccountId != null).length;
  const usersWithDob = users.filter((user) => Boolean(user.dob)).length;
  const recipesWithDiet = recipes.filter((recipe) => recipe.dietTypes?.length).length;
  const recipesWithAllergens = recipes.filter((recipe) => getRecipeAllergens(recipe).length).length;
  const systemHealth = errors.length ? Math.max(0, 100 - errors.length * 25) : 100;

  const userActivityData = useMemo(() => buildProfileGrowth(users), [users]);

  const allergyProfile = useMemo(() => {
    const counts = new Map();
    ingredients.forEach((ingredient) => {
      (ingredient.allergens || []).forEach((allergen) => {
        counts.set(allergen.name, (counts.get(allergen.name) || 0) + 1);
      });
    });

    const totalTagged = [...counts.values()].reduce((sum, value) => sum + value, 0);
    return [...counts.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([name, count]) => ({
        name,
        value: totalTagged ? Math.round((count / totalTagged) * 100) : 0,
        count
      }));
  }, [ingredients]);

  const primaryKpis = [
    { label: "Tổng người dùng", value: usersPage.totalElements, note: "Tổng hồ sơ", icon: Users },
    { label: "Người dùng mới hôm nay", value: newUsersToday, note: "createdAt", icon: CalendarDays },
    { label: "Người dùng mới 7 ngày", value: newUsers7Days, note: "createdAt", icon: CalendarDays },
    { label: "Người dùng mới 30 ngày", value: newUsers30Days, note: "createdAt", icon: CalendarDays },
    { label: "Cảnh báo hệ thống", value: errors.length, note: "API lỗi", icon: AlertTriangle, danger: Boolean(errors.length) }
  ];

  const userSummary = [
    { label: "Tổng hồ sơ", value: usersPage.totalElements },
    { label: "Đã liên kết Auth", value: linkedUsers },
    { label: "Có ngày sinh", value: usersWithDob },
    { label: "Mới 30 ngày", value: newUsers30Days }
  ];

  const recipeStatusMetrics = [
    { label: "Tổng công thức", value: recipesPage.totalElements },
    { label: "Danh mục", value: categoriesPage.totalElements },
    { label: "Nguyên liệu", value: ingredientsPage.totalElements },
    { label: "Nhãn dị ứng", value: allergensPage.totalElements },
    { label: "Có diet tags", value: recipesWithDiet },
    { label: "Có dị ứng", value: recipesWithAllergens }
  ];

  const recentRecipes = recipes.slice(0, 5);
  const catalogIngredients = ingredients.slice(0, 5).map((ingredient) => ({
    name: ingredient.name,
    group: ingredient.allergens?.length ? "Có dị ứng" : "Không có dị ứng",
    allergenCount: ingredient.allergens?.length || 0
  }));

  const systemAlerts = errors.length
    ? errors.map((message, index) => ({
      title: `API #${index + 1}`,
      description: message,
      severity: "Warning",
      tone: "warning",
      icon: ServerCog
    }))
    : [{
      title: "API",
      description: "Hoạt động",
      severity: "OK",
      tone: "ok",
      icon: Database
    }];

  return (
    <div className="page-stack">
      <section className="overview-hero">
        <div>
          <p className="eyebrow">Overview Dashboard</p>
          <h2>Tình trạng toàn hệ thống</h2>
        </div>
        <div className="overview-health">
          <span>System Health</span>
          <strong>{loading ? "..." : `${systemHealth}%`}</strong>
          <b>{errors.length ? `${errors.length} cảnh báo` : "Hoạt động"}</b>
        </div>
      </section>

      {errors.length ? (
        <section className="warning-panel">
          <AlertTriangle size={20} />
          <div>
            <strong>Lỗi tải dữ liệu</strong>
            {errors.map((error) => <p key={error}>{error}</p>)}
          </div>
        </section>
      ) : null}

      <section className="kpi-grid overview-main-kpis">
        {primaryKpis.map(({ label, value, note, icon: Icon, danger }) => (
          <article className={`kpi-card ${danger ? "danger-card" : ""}`} key={label}>
            <div className="kpi-icon"><Icon size={20} /></div>
            <span>{label}</span>
            <strong>{loading ? "..." : formatNumber(value)}</strong>
            <small>{note}</small>
          </article>
        ))}
      </section>

      <section className="overview-section user-activity-section">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">User Service</p>
            <h2>Xu hướng hồ sơ người dùng</h2>
          </div>
        </div>
        <div className="activity-chart-grid">
          <div className="chart-box tall-chart">
            <ResponsiveContainer width="100%" height={320}>
              <AreaChart data={userActivityData}>
                <CartesianGrid stroke="#e7eadc" />
                <XAxis dataKey="day" />
                <YAxis />
                <Tooltip />
                <Area type="monotone" dataKey="registered" name="Hồ sơ đã tạo" stroke="#536b58" fill="#b9cbb7" strokeWidth={3} />
                <Area type="monotone" dataKey="updated" name="Hồ sơ đã cập nhật" stroke="#8a6a46" fill="#efe4ce" strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
          <div className="activity-summary">
            {userSummary.map((item) => (
              <div className="compact-stat" key={item.label}>
                <span>{item.label}</span>
                <strong>{loading ? "..." : formatNumber(item.value)}</strong>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="overview-section">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">Recipe Service</p>
            <h2>Phân tích công thức & nguyên liệu</h2>
          </div>
        </div>
        <div className="recipe-insights-grid">
          <article className="panel recipe-status-panel">
            <div className="panel-heading compact-heading">
              <div>
                <h2><Utensils size={20} /> Catalog hiện tại</h2>
              </div>
            </div>
            <div className="recipe-status-grid">
              {recipeStatusMetrics.map((item) => (
                <div className="recipe-status-metric" key={item.label}>
                  <span>{item.label}</span>
                  <strong>{loading ? "..." : formatNumber(item.value)}</strong>
                </div>
              ))}
            </div>
          </article>

          <article className="panel recipe-table-panel">
            <div className="panel-heading">
              <h2>Công thức mới nhất</h2>
            </div>
            <div className="table-scroll compact-table-scroll">
              <table className="data-table overview-recipe-table">
                <thead>
                  <tr>
                    <th>Công thức</th>
                    <th>Danh mục</th>
                    <th>Kcal</th>
                    <th>Khẩu phần</th>
                    <th>Dị ứng</th>
                  </tr>
                </thead>
                <tbody>
                  {recentRecipes.map((recipe) => (
                    <tr key={recipe.recipeId}>
                      <td><strong>{recipe.title}</strong></td>
                      <td>{recipe.category?.name || "-"}</td>
                      <td>{recipe.nutrition?.calories ?? "-"}</td>
                      <td>{recipe.servings ?? "-"}</td>
                      <td>{getRecipeAllergens(recipe).length}</td>
                    </tr>
                  ))}
                  {!recentRecipes.length ? <tr><td colSpan="5">Không có dữ liệu.</td></tr> : null}
                </tbody>
              </table>
            </div>
          </article>

          <article className="panel ingredient-search-panel">
            <div className="panel-heading">
              <div>
                <h2><SearchCheck size={20} /> Nguyên liệu</h2>
              </div>
            </div>
            <div className="searched-ingredient-list">
              {catalogIngredients.map((item) => (
                <div className="searched-ingredient" key={item.name}>
                  <div>
                    <strong>{item.name}</strong>
                    <span>{item.group}</span>
                  </div>
                  <div>
                    <b>{formatNumber(item.allergenCount)}</b>
                    <small>nhãn</small>
                  </div>
                </div>
              ))}
              {!catalogIngredients.length ? <div className="empty-state">Không có dữ liệu.</div> : null}
            </div>
          </article>
        </div>
      </section>

      <section className="overview-section">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">Safety Catalog</p>
            <h2>Phân bố nhãn dị ứng</h2>
          </div>
        </div>
        <article className="panel allergy-profile-panel">
          <ResponsiveContainer width="100%" height={270}>
            <BarChart data={allergyProfile} layout="vertical" margin={{ right: 34 }}>
              <XAxis type="number" hide domain={[0, 100]} />
              <YAxis type="category" dataKey="name" width={110} />
              <Tooltip formatter={(value, name, item) => [`${value}% (${item.payload.count})`, "Tỷ lệ"]} />
              <Bar dataKey="value" fill="#8da290" radius={[0, 8, 8, 0]}>
                <LabelList dataKey="value" position="right" formatter={(value) => `${value}%`} />
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </article>
      </section>

      <section className="overview-section">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">Operations</p>
            <h2>Vận hành & cảnh báo</h2>
          </div>
        </div>
        <div className="dashboard-grid">
          <article className="panel">
            <div className="panel-heading">
              <h2><AlertTriangle size={20} /> Cảnh báo hệ thống</h2>
            </div>
            <div className="system-alert-list">
              {systemAlerts.map(({ title, description, severity, tone, icon: Icon }) => (
                <article className={`system-alert ${tone}`} key={title}>
                  <Icon size={18} />
                  <div>
                    <div className="alert-title-row">
                      <strong>{title}</strong>
                      <span className={`severity-pill ${tone}`}>{severity}</span>
                    </div>
                    <span>{description}</span>
                  </div>
                </article>
              ))}
            </div>
          </article>

          <article className="panel">
            <div className="panel-heading">
              <h2>Dữ liệu đã tải</h2>
            </div>
            <div className="activity-list">
              <div className="activity-item">
                <span className="avatar-xs">US</span>
                <div>
                  <strong>User Service</strong>
                  <p>{formatNumber(users.length)} hồ sơ</p>
                </div>
              </div>
              <div className="activity-item">
                <span className="avatar-xs">RS</span>
                <div>
                  <strong>Recipe Service</strong>
                  <p>{formatNumber(recipes.length)} công thức</p>
                </div>
              </div>
              <div className="activity-item">
                <span className="avatar-xs">NT</span>
                <div>
                  <strong>Nutrition Catalog</strong>
                  <p>{formatNumber(ingredients.length)} nguyên liệu</p>
                </div>
              </div>
            </div>
          </article>
        </div>
      </section>
    </div>
  );
}
