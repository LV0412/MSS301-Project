import { ShieldCheck, Utensils, UserPlus } from "lucide-react";
import { useMemo, useState } from "react";
import { Link, Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export default function RegisterPage() {
  const { isAuthenticated, register } = useAuth();
  const [form, setForm] = useState({ fullName: "", email: "", password: "", confirmPassword: "" });
  const [touched, setTouched] = useState({});
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const errors = useMemo(() => {
    const next = {};
    if (form.fullName.trim().length < 2) next.fullName = "Họ và tên cần tối thiểu 2 ký tự.";
    if (!form.email.trim()) next.email = "Vui lòng nhập email.";
    else if (!emailPattern.test(form.email.trim())) next.email = "Email không đúng định dạng.";
    if (form.password.length < 8) next.password = "Mật khẩu cần tối thiểu 8 ký tự.";
    if (form.confirmPassword !== form.password) next.confirmPassword = "Mật khẩu xác nhận không khớp.";
    return next;
  }, [form]);

  const disabled = submitting || Object.keys(errors).length > 0;

  if (isAuthenticated) return <Navigate to="/overview" replace />;

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
    setError("");
    setSuccess("");
  }

  async function handleSubmit(event) {
    event.preventDefault();
    setTouched({ fullName: true, email: true, password: true, confirmPassword: true });
    if (disabled) return;

    setSubmitting(true);
    setError("");
    setSuccess("");

    try {
      const response = await register({
        fullName: form.fullName.trim(),
        email: form.email.trim().toLowerCase(),
        password: form.password
      });
      setSuccess(response?.message || "Đăng ký thành công. Vui lòng xác thực email trước khi đăng nhập.");
      setForm({ fullName: "", email: "", password: "", confirmPassword: "" });
      setTouched({});
    } catch (err) {
      setError(err?.message || "Đăng ký thất bại. Vui lòng thử lại.");
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
            <p className="eyebrow">Tạo tài khoản</p>
            <h1>Đăng ký</h1>
            <p>Tạo tài khoản qua Auth Service. Tài khoản mới cần xác thực email và được cấp quyền ADMIN trước khi truy cập dashboard.</p>
          </div>

          <div className="admin-access-note">
            <ShieldCheck size={18} />
            <div>
              <strong>Không tự cấp quyền ADMIN</strong>
              <p>Endpoint đăng ký của BE tạo tài khoản thường. Quyền truy cập dashboard vẫn phụ thuộc role ADMIN trong Auth Service.</p>
            </div>
          </div>
        </section>

        <section className="login-card" aria-label="Đăng ký tài khoản">
          <div className="login-card-header">
            <span>AUTH SERVICE</span>
            <h2>Đăng ký tài khoản</h2>
            <p>Form gửi đúng contract BE: fullName, email và password.</p>
          </div>

          <form className="login-form" onSubmit={handleSubmit} noValidate>
            <label>
              Họ và tên
              <input
                value={form.fullName}
                onBlur={() => setTouched((current) => ({ ...current, fullName: true }))}
                onChange={(event) => updateField("fullName", event.target.value)}
                placeholder="Nguyễn An"
                autoComplete="name"
              />
              {touched.fullName && errors.fullName ? <span className="field-error">{errors.fullName}</span> : null}
            </label>

            <label>
              Email
              <input
                value={form.email}
                onBlur={() => setTouched((current) => ({ ...current, email: true }))}
                onChange={(event) => updateField("email", event.target.value)}
                placeholder="admin@example.com"
                autoComplete="email"
              />
              {touched.email && errors.email ? <span className="field-error">{errors.email}</span> : null}
            </label>

            <label>
              Mật khẩu
              <input
                type="password"
                value={form.password}
                onBlur={() => setTouched((current) => ({ ...current, password: true }))}
                onChange={(event) => updateField("password", event.target.value)}
                placeholder="Tối thiểu 8 ký tự"
                autoComplete="new-password"
              />
              {touched.password && errors.password ? <span className="field-error">{errors.password}</span> : null}
            </label>

            <label>
              Xác nhận mật khẩu
              <input
                type="password"
                value={form.confirmPassword}
                onBlur={() => setTouched((current) => ({ ...current, confirmPassword: true }))}
                onChange={(event) => updateField("confirmPassword", event.target.value)}
                placeholder="Nhập lại mật khẩu"
                autoComplete="new-password"
              />
              {touched.confirmPassword && errors.confirmPassword ? <span className="field-error">{errors.confirmPassword}</span> : null}
            </label>

            {error ? <div className="login-error" role="alert"><UserPlus size={18} /><span>{error}</span></div> : null}
            {success ? <div className="login-success" role="status"><ShieldCheck size={18} /><span>{success}</span></div> : null}

            <button className="primary-btn login-submit" type="submit" disabled={disabled}>
              {submitting ? "Đang đăng ký..." : "Đăng ký"}
            </button>
          </form>

          <p className="auth-switch">Đã có tài khoản? <Link to="/login">Đăng nhập</Link></p>
        </section>
      </div>
    </main>
  );
}
