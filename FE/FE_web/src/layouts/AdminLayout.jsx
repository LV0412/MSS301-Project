import { NavLink, Outlet, useLocation } from "react-router-dom";
import {
  BarChart3,
  Bell,
  BrainCircuit,
  Bot,
  Database,
  FlaskConical,
  LayoutDashboard,
  ListTree,
  LogOut,
  MessageSquareHeart,
  Search,
  Settings,
  Sparkles,
  UserCircle,
  Users,
  Utensils
} from "lucide-react";

const navItems = [
  { to: "/overview", label: "Tổng quan", icon: LayoutDashboard },
  { to: "/recipes", label: "Công thức", icon: Utensils },
  { to: "/nutrition", label: "Dinh dưỡng", icon: Database },
  { to: "/reports", label: "Báo cáo", icon: BarChart3 },
  { to: "/users", label: "Người dùng", icon: Users },
  { to: "/ai-overview", label: "AI Overview", icon: Bot },
  { to: "/ai-knowledge", label: "AI Knowledge", icon: BrainCircuit },
  { to: "/ai-recommendation-sandbox", label: "Recommendation Sandbox", icon: FlaskConical },
  { to: "/ai-meal-plan-sandbox", label: "Meal Plan Sandbox", icon: Utensils },
  { to: "/ai-logs", label: "AI Logs", icon: ListTree },
  { to: "/ai-feedback", label: "Feedback", icon: MessageSquareHeart },
  { to: "/settings", label: "Cài đặt", icon: Settings }
];

const pageTitles = {
  "/overview": "Tổng quan",
  "/recipes": "Quản lý công thức",
  "/recipes/new": "Tạo công thức",
  "/nutrition": "Cơ sở dữ liệu dinh dưỡng",
  "/nutrition/new": "Tạo nguyên liệu",
  "/reports": "Báo cáo hệ thống",
  "/users": "Quản lý người dùng",
  "/users/new": "Tạo người dùng",
  "/ai-overview": "AI Service Overview",
  "/ai-knowledge": "AI Knowledge Base",
  "/ai-recommendation-sandbox": "Recommendation Sandbox",
  "/ai-meal-plan-sandbox": "Meal Plan Sandbox",
  "/ai-logs": "AI Logs",
  "/ai-feedback": "Feedback & Evaluation",
  "/settings": "Cài đặt"
};

function getTitle(pathname) {
  if (pathname.includes("/recipes/")) return pathname.endsWith("/edit") ? "Chỉnh sửa công thức" : "Tạo công thức";
  if (pathname.includes("/nutrition/")) return pathname.endsWith("/edit") ? "Chỉnh sửa nguyên liệu" : "Tạo nguyên liệu";
  if (pathname === "/users/new") return pageTitles["/users/new"];
  if (pathname.includes("/users/")) return "Chi tiết người dùng";
  return pageTitles[pathname] ?? "NutriChef Admin";
}

export default function AdminLayout() {
  const location = useLocation();

  return (
    <div className="admin-shell">
      <aside className="sidebar">
        <div className="brand">
          <div className="brand-mark">
            <Utensils size={18} />
          </div>
          <div>
            <strong>NutriChef AI</strong>
            <span>Admin Panel</span>
          </div>
        </div>

        <nav className="nav-list" aria-label="Admin navigation">
          {navItems.map(({ to, label, icon: Icon }) => (
            <NavLink key={to} to={to} className={({ isActive }) => `nav-item ${isActive ? "active" : ""}`}>
              <Icon size={18} />
              <span>{label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="sidebar-footer">
          <div className="admin-avatar">AD</div>
          <div className="admin-meta">
            <strong>Admin Panel</strong>
            <span>v1.0.4</span>
          </div>
          <LogOut size={16} />
        </div>
      </aside>

      <main className="main-panel">
        <header className="topbar">
          <div>
            <p className="eyebrow">NutriChef System</p>
            <h1>{getTitle(location.pathname)}</h1>
          </div>
          <div className="topbar-actions">
            <label className="global-search">
              <Search size={17} />
              <input placeholder="Tìm kiếm toàn hệ thống..." />
            </label>
            <button className="icon-btn" aria-label="Thông báo">
              <Bell size={18} />
              <span className="alert-dot" />
            </button>
            <button className="icon-btn" aria-label="AI shortcuts">
              <Sparkles size={18} />
            </button>
            <button className="profile-pill" aria-label="Admin profile">
              <UserCircle size={20} />
              <span>ADMIN</span>
            </button>
          </div>
        </header>

        <section className="page-content">
          <Outlet />
        </section>
      </main>
    </div>
  );
}
