import {
  Activity,
  AlertTriangle,
  Bot,
  DatabaseZap,
  HeartPulse,
  LineChart as LineChartIcon,
  SearchCheck,
  ServerCog,
  ShieldAlert,
  Sparkles,
  Target,
  Users,
  Utensils
} from "lucide-react";
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  LabelList,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from "recharts";
import { goalDistribution, recipes } from "../data/mockData.js";

const primaryKpis = [
  { label: "Tổng người dùng", value: "12,482", note: "Tổng tài khoản đã đăng ký", icon: Users },
  { label: "DAU", value: "843", note: "Người dùng hoạt động hôm nay", trend: "+12% so với hôm qua", icon: Activity },
  { label: "WAU", value: "5,920", note: "Hoạt động trong 7 ngày", trend: "+6.4% so với tuần trước", icon: LineChartIcon },
  { label: "MAU", value: "10,684", note: "Hoạt động trong 30 ngày", trend: "+8.1% so với tháng trước", icon: HeartPulse },
  { label: "System Alerts", value: "3", note: "AI, embedding, health device", icon: AlertTriangle, danger: true }
];

const userActivityData = [
  { day: "01", dau: 640, wau: 4820, mau: 9200 },
  { day: "05", dau: 690, wau: 5040, mau: 9460 },
  { day: "10", dau: 735, wau: 5280, mau: 9820 },
  { day: "15", dau: 762, wau: 5520, mau: 10120 },
  { day: "20", dau: 810, wau: 5780, mau: 10420 },
  { day: "25", dau: 824, wau: 5900, mau: 10610 },
  { day: "30", dau: 843, wau: 5920, mau: 10684 }
];

const activitySummary = [
  { label: "DAU", value: "843" },
  { label: "WAU", value: "5,920" },
  { label: "MAU", value: "10,684" },
  { label: "Stickiness", value: "7.9%", note: "DAU / MAU" }
];

const aiPerformance = [
  { label: "AI Chef Requests", value: "8,420", note: "+14% so với tuần trước", icon: Bot },
  { label: "Recipe Recommendations", value: "12,860", note: "Công thức AI đã gợi ý", icon: Sparkles },
  { label: "Meal Plans Generated", value: "1,120", note: "+9.6% so với tuần trước", icon: Utensils },
  { label: "AI Success Rate", value: "96.8%", note: "Fallback rate 2.1%", icon: Target },
  { label: "Safety Warnings", value: "32", note: "Cảnh báo an toàn cần rà soát", icon: ShieldAlert, warning: true }
];

const popularRecipes = [
  { ...recipes[0], views: "18.4k", saved: "4.2k", mealPlanAdds: "1.8k" },
  { ...recipes[1], views: "16.7k", saved: "3.9k", mealPlanAdds: "1.5k" },
  { ...recipes[3], views: "13.2k", saved: "2.7k", mealPlanAdds: "1.1k" },
  { ...recipes[2], views: "9.8k", saved: "2.1k", mealPlanAdds: "840" }
];

const recipeStatusMetrics = [
  { label: "Tổng công thức", value: "4,892" },
  { label: "Đã xuất bản", value: "4,120" },
  { label: "Bản nháp", value: "312" },
  { label: "Cần duyệt AI", value: "46" },
  { label: "Đã ẩn/lưu trữ", value: "414" }
];

const searchedIngredients = [
  { name: "Ức gà", searches: "9.4k", trend: "+18%", group: "Nhóm đạm" },
  { name: "Trứng", searches: "8.1k", trend: "+12%", group: "Nhóm đạm" },
  { name: "Yến mạch", searches: "7.6k", trend: "+9%", group: "Ngũ cốc" },
  { name: "Bơ", searches: "6.2k", trend: "+15%", group: "Rau củ / Thực phẩm tươi" },
  { name: "Cá hồi", searches: "5.9k", trend: "-3%", group: "Nhóm đạm", down: true }
];

const allergyProfile = [
  { name: "Sữa", value: 32 },
  { name: "Hạt", value: 25 },
  { name: "Hải sản", value: 18 },
  { name: "Gluten", value: 15 },
  { name: "Trứng", value: 10 }
];

const systemAlerts = [
  {
    title: "Lỗi AI recommendation",
    description: "Tỷ lệ fallback tăng ở nhóm truy vấn keto dessert.",
    severity: "Warning",
    tone: "warning",
    icon: Sparkles
  },
  {
    title: "Embedding queue chậm",
    description: "Dataset recipe mới còn 312 chunks đang chờ index.",
    severity: "Delayed",
    tone: "delayed",
    icon: DatabaseZap
  },
  {
    title: "API health device",
    description: "Endpoint đồng bộ health device timeout 2.4% request.",
    severity: "Critical",
    tone: "critical",
    icon: ServerCog
  }
];

const operationActivity = [
  { title: "Admin cập nhật bộ quy tắc dị ứng", detail: "Safety matrix v1.4 được bật cho nhóm dairy-free.", time: "8 phút trước" },
  { title: "AI index hoàn tất tài liệu WHO", detail: "482 chunks đã sẵn sàng cho retrieval sandbox.", time: "22 phút trước" },
  { title: "Recipe dataset được đồng bộ", detail: "36 công thức mới đang chờ kiểm duyệt nội dung.", time: "1 giờ trước" },
  { title: "Health device sync retry", detail: "Retry policy tự động chạy cho 214 request timeout.", time: "2 giờ trước" }
];

export default function OverviewPage() {
  return (
    <div className="page-stack">
      <section className="overview-hero">
        <div>
          <p className="eyebrow">Overview Dashboard</p>
          <h2>Tình trạng toàn hệ thống</h2>
          <p>Theo dõi nhanh người dùng, AI, công thức, meal plan và cảnh báo vận hành.</p>
        </div>
        <div className="overview-health">
          <span>System Health</span>
          <strong>97.6%</strong>
          <small>Dựa trên API uptime, AI success rate, embedding queue và health device sync trong 24h.</small>
          <b>3 cảnh báo cần xử lý</b>
        </div>
      </section>

      <section className="kpi-grid overview-main-kpis">
        {primaryKpis.map(({ label, value, note, trend, icon: Icon, danger }) => (
          <article className={`kpi-card ${danger ? "danger-card" : ""}`} key={label}>
            <div className="kpi-icon">
              <Icon size={20} />
            </div>
            <span>{label}</span>
            <strong>{value}</strong>
            <small>{note}</small>
            {trend ? <em className="kpi-trend">{trend}</em> : null}
          </article>
        ))}
      </section>

      <section className="overview-section user-activity-section">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">User Activity</p>
            <h2>Xu hướng hoạt động người dùng</h2>
            <p>Line/area chart DAU, WAU, MAU trong 30 ngày gần nhất.</p>
          </div>
          <div className="chip-row">
            <span className="chip">7 ngày</span>
            <span className="chip active">30 ngày</span>
            <span className="chip">90 ngày</span>
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
                <Area type="monotone" dataKey="mau" name="MAU" stroke="#8a6a46" fill="#efe4ce" strokeWidth={2} />
                <Area type="monotone" dataKey="wau" name="WAU" stroke="#8da290" fill="#dbe5d3" strokeWidth={2} />
                <Area type="monotone" dataKey="dau" name="DAU" stroke="#536b58" fill="#b9cbb7" strokeWidth={3} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
          <div className="activity-summary">
            {activitySummary.map((item) => (
              <div className="compact-stat" key={item.label}>
                <span>{item.label}</span>
                <strong>{item.value}</strong>
                {item.note ? <small>{item.note}</small> : null}
              </div>
            ))}
            <div className="stickiness-note">
              <strong>Stickiness 7.9%</strong>
              <span>Tỷ lệ người dùng quay lại hằng ngày.</span>
            </div>
          </div>
        </div>
      </section>

      <section className="overview-section">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">AI Performance</p>
            <h2>Hiệu suất AI</h2>
            <p>Theo dõi AI Chef, recipe recommendation, meal plan và cảnh báo an toàn.</p>
          </div>
        </div>
        <div className="ai-performance-grid">
          {aiPerformance.map(({ label, value, note, icon: Icon, warning }) => (
            <article className={`mini-panel ai-performance-card ${warning ? "warning-card" : ""}`} key={label}>
              <div className="kpi-icon">
                <Icon size={19} />
              </div>
              <span>{label}</span>
              <strong>{value}</strong>
              <small>{note}</small>
            </article>
          ))}
        </div>
      </section>

      <section className="overview-section">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">Recipe Insights</p>
            <h2>Phân tích công thức & nguyên liệu</h2>
            <p>Theo dõi hiệu suất công thức, lượt tương tác và nguyên liệu được tìm kiếm nhiều trong hệ thống.</p>
          </div>
          <div className="chip-row recipe-period-filter" aria-label="Lọc thời gian phân tích công thức">
            <button className="chip">7 ngày</button>
            <button className="chip active">30 ngày</button>
            <button className="chip">90 ngày</button>
          </div>
        </div>
        <div className="recipe-insights-grid">
          <article className="panel recipe-status-panel">
            <div className="panel-heading compact-heading">
              <div>
                <h2><Utensils size={20} /> Trạng thái nội dung</h2>
                <p>Tổng quan kho công thức hiện tại.</p>
              </div>
            </div>
            <div className="recipe-status-grid">
              {recipeStatusMetrics.map((item) => (
                <div className="recipe-status-metric" key={item.label}>
                  <span>{item.label}</span>
                  <strong>{item.value}</strong>
                </div>
              ))}
            </div>
          </article>

          <article className="panel recipe-table-panel">
            <div className="panel-heading">
              <h2>Top công thức phổ biến trong 30 ngày</h2>
              <button className="link-btn">Xem tất cả</button>
            </div>
            <div className="table-scroll compact-table-scroll">
              <table className="data-table overview-recipe-table">
                <thead>
                  <tr>
                    <th>Công thức</th>
                    <th>Lượt xem</th>
                    <th>Đã lưu</th>
                    <th>Kế hoạch</th>
                    <th>Đánh giá</th>
                  </tr>
                </thead>
                <tbody>
                  {popularRecipes.map((recipe) => (
                    <tr key={recipe.id}>
                      <td className="recipe-name">
                        <img src={recipe.image} alt={recipe.name} />
                        <div>
                          <strong>{recipe.name}</strong>
                          <span>{recipe.cuisine} · {recipe.calories} kcal</span>
                        </div>
                      </td>
                      <td>{recipe.views}</td>
                      <td>{recipe.saved}</td>
                      <td>{recipe.mealPlanAdds}</td>
                      <td>{recipe.rating} ★</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </article>

          <article className="panel ingredient-search-panel">
            <div className="panel-heading">
              <div>
                <h2><SearchCheck size={20} /> Nguyên liệu được tìm nhiều</h2>
                <p>Lượt tìm kiếm và mức tăng/giảm trong 30 ngày.</p>
              </div>
            </div>
            <div className="searched-ingredient-list">
              {searchedIngredients.map((item) => (
                <div className="searched-ingredient" key={item.name}>
                  <div>
                    <strong>{item.name}</strong>
                    <span>{item.group}</span>
                  </div>
                  <div>
                    <b>{item.searches} lượt</b>
                    <small className={item.down ? "trend-down" : ""}>{item.trend}</small>
                  </div>
                </div>
              ))}
            </div>
            <button className="ghost-btn trend-btn">Xem xu hướng</button>
          </article>
        </div>
      </section>

      <section className="overview-section">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">User Profile Insights</p>
            <h2>User Profile Insights</h2>
            <p>Dựa trên hồ sơ người dùng đã hoàn tất onboarding.</p>
          </div>
        </div>
        <div className="dashboard-grid">
          <article className="panel goal-panel">
            <h2><Target size={20} /> Phân bố mục tiêu</h2>
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie data={goalDistribution} innerRadius={70} outerRadius={96} dataKey="value" paddingAngle={3}>
                  {goalDistribution.map((entry) => (
                    <Cell key={entry.name} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
            <div className="legend-list">
              {goalDistribution.map((item) => (
                <span key={item.name}>
                  <i style={{ background: item.color }} />
                  {item.name}
                  <b>{item.value}%</b>
                </span>
              ))}
            </div>
          </article>

          <article className="panel allergy-profile-panel">
            <div className="panel-heading">
              <div>
                <h2>Phân bố dị ứng</h2>
                <p>Dựa trên hồ sơ người dùng đã hoàn tất onboarding.</p>
              </div>
            </div>
            <ResponsiveContainer width="100%" height={270}>
              <BarChart data={allergyProfile} layout="vertical" margin={{ right: 34 }}>
                <XAxis type="number" hide domain={[0, 40]} />
                <YAxis type="category" dataKey="name" width={78} />
                <Tooltip />
                <Bar dataKey="value" fill="#8da290" radius={[0, 8, 8, 0]}>
                  <LabelList dataKey="value" position="right" formatter={(value) => `${value}%`} />
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </article>
        </div>
      </section>

      <section className="overview-section">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">Operations</p>
            <h2>Vận hành & cảnh báo</h2>
            <p>Những tín hiệu cần admin xử lý ngay trong ngày.</p>
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
                    <button className="link-btn">Xem chi tiết</button>
                  </div>
                </article>
              ))}
            </div>
          </article>

          <article className="panel">
            <div className="panel-heading">
              <h2>Hoạt động vận hành gần đây</h2>
              <button className="link-btn">Xem tất cả</button>
            </div>
            <div className="activity-list">
              {operationActivity.map((item) => (
                <div className="activity-item" key={`${item.title}-${item.time}`}>
                  <span className="avatar-xs">OP</span>
                  <div>
                    <strong>{item.title}</strong>
                    <p>{item.detail}</p>
                    <small>{item.time}</small>
                  </div>
                </div>
              ))}
            </div>
          </article>
        </div>
      </section>
    </div>
  );
}
