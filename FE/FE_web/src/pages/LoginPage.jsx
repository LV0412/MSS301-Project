import { Eye, EyeOff, LockKeyhole, ShieldCheck, Utensils } from "lucide-react";
import { useMemo, useState } from "react";
import { Link, Navigate, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export default function LoginPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isAuthenticated, login } = useAuth();
  const [form, setForm] = useState({ email: "admin@nutrichef.ai", password: "Admin@123456" });
  const [showPassword, setShowPassword] = useState(false);
  const [touched, setTouched] = useState({});
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const from = location.state?.from?.pathname || "/overview";

  const errors = useMemo(() => {
    const next = {};
    if (!form.email.trim()) next.email = "Vui lòng nhập email.";
    else if (!emailPattern.test(form.email.trim())) next.email = "Email không đúng định dạng.";
    if (!form.password) next.password = "Vui lòng nhập mật khẩu.";
    return next;
  }, [form]);

  const disabled = submitting || Boolean(errors.email) || Boolean(errors.password);

  if (isAuthenticated) return <Navigate to={from} replace />;

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
    setError("");
  }

  async function handleSubmit(event) {
    event.preventDefault();
    setTouched({ email: true, password: true });
    if (disabled) return;

    setSubmitting(true);
    setError("");

    try {
      await login({ email: form.email.trim().toLowerCase(), password: form.password });
      navigate(from, { replace: true });
    } catch (err) {
      if (err?.status === 401) setError("Email hoặc mật khẩu không đúng.");
      else if (err?.message?.includes("ADMIN")) setError("Tài khoản này không có quyền truy cập dashboard Admin.");
      else setError(err?.message || "Đăng nhập thất bại. Vui lòng thử lại.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="login-page">
      <div className="login-shell">
        <section className="login-intro" aria-label="NutriChef AI Admin">
          <div className="brand login-brand">
            <div className="brand-mark"><Utensils size={20} /></div>
            <div>
              <strong>NutriChef AI</strong>
              <span>Admin Dashboard</span>
            </div>
          </div>

          <div className="login-copy">
            <p className="eyebrow">Hệ thống quản trị</p>
            <h1>Đăng nhập Admin</h1>
            <p>Truy cập hệ thống quản trị NutriChef AI để quản lý người dùng, công thức, dinh dưỡng và dịch vụ AI gợi ý món ăn.</p>
          </div>

          <div className="admin-access-note">
            <ShieldCheck size={18} />
            <div>
              <strong>Yêu cầu quyền ADMIN</strong>
              <p>Chỉ tài khoản đã được cấp quyền ADMIN mới có thể truy cập dashboard quản trị.</p>
            </div>
          </div>
        </section>

        <section className="login-card" aria-label="Đăng nhập Dashboard">
          <div className="login-card-header">
            <span>XÁC THỰC ADMIN</span>
            <h2>Đăng nhập Dashboard</h2>
            <p>Sử dụng tài khoản admin đã được cấp quyền trong Auth Service.</p>
          </div>

          <form className="login-form" onSubmit={handleSubmit} noValidate>
            <label>
              Email
              <input
                value={form.email}
                onBlur={() => setTouched((current) => ({ ...current, email: true }))}
                onChange={(event) => updateField("email", event.target.value)}
                placeholder="admin@nutrichef.ai"
                autoComplete="email"
              />
              {touched.email && errors.email ? <span className="field-error">{errors.email}</span> : null}
            </label>

            <label>
              Mật khẩu
              <span className="password-field">
                <input
                  type={showPassword ? "text" : "password"}
                  value={form.password}
                  onBlur={() => setTouched((current) => ({ ...current, password: true }))}
                  onChange={(event) => updateField("password", event.target.value)}
                  placeholder="Nhập mật khẩu"
                  autoComplete="current-password"
                />
                <button
                  className="password-toggle"
                  type="button"
                  onClick={() => setShowPassword((current) => !current)}
                  aria-label={showPassword ? "Ẩn mật khẩu" : "Hiện mật khẩu"}
                >
                  {showPassword ? <EyeOff size={17} /> : <Eye size={17} />}
                </button>
              </span>
              {touched.password && errors.password ? <span className="field-error">{errors.password}</span> : null}
            </label>

            {error ? (
              <div className="login-error" role="alert">
                <LockKeyhole size={18} />
                <span>{error}</span>
              </div>
            ) : null}

            <button className="primary-btn login-submit" type="submit" disabled={disabled}>
              {submitting ? "Đang đăng nhập..." : "Đăng nhập"}
            </button>
          </form>

          <p className="auth-switch">Chưa có tài khoản? <Link to="/register">Đăng ký</Link></p>
        </section>
      </div>
    </main>
  );
}
