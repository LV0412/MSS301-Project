import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Mail, Save, ShieldCheck, UserPlus } from "lucide-react";
import { createAccountByAdmin } from "../api/userManagement.js";

function validate(form) {
  const errors = {};
  if (form.fullName.trim().length < 2) errors.fullName = "Họ tên phải có ít nhất 2 ký tự.";
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email.trim())) errors.email = "Email không đúng định dạng.";
  return errors;
}

export default function UserFormPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({ fullName: "", email: "" });
  const [errors, setErrors] = useState({});
  const [requestError, setRequestError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
    setErrors((current) => ({ ...current, [field]: undefined }));
    setRequestError("");
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const nextErrors = validate(form);
    if (Object.keys(nextErrors).length) {
      setErrors(nextErrors);
      return;
    }

    setSubmitting(true);
    try {
      const account = await createAccountByAdmin({
        fullName: form.fullName.trim(),
        email: form.email.trim().toLowerCase()
      });
      navigate(`/users/${account.userId}`, { replace: true });
    } catch (error) {
      setRequestError(error.message);
      if (error.details?.validationErrors) setErrors(error.details.validationErrors);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="page-stack">
      <div className="page-toolbar"><div><p className="eyebrow">Auth + User Service</p><h2>Tạo tài khoản người dùng</h2><p>Admin chỉ nhập thông tin định danh; mật khẩu tạm được Auth Service tự gán.</p></div></div>

      <section className="privacy-banner">
        <ShieldCheck size={24} />
        <div><strong>Luồng tài khoản an toàn hơn</strong><p>Tài khoản được tạo ở trạng thái chờ xác minh, OTP được gửi đến email và hồ sơ User Service được liên kết ngay. Người dùng đăng nhập bằng mật khẩu tạm do hệ thống cấu hình và nên đổi mật khẩu trong ứng dụng.</p></div>
      </section>

      <section className="user-create-layout">
        <form className="form-card user-create-form" onSubmit={handleSubmit} noValidate>
          <div className="panel-heading"><div><h2><UserPlus size={18} /> Thông tin tài khoản</h2><p>Không nhập hoặc truyền mật khẩu từ trình duyệt admin.</p></div></div>

          <label>Họ và tên
            <input value={form.fullName} onChange={(event) => updateField("fullName", event.target.value)} placeholder="Ví dụ: Nguyễn An" aria-invalid={Boolean(errors.fullName)} />
            {errors.fullName ? <span className="field-error">{errors.fullName}</span> : null}
          </label>

          <label>Email
            <div className="field form-field-with-icon"><Mail size={16} /><input type="email" value={form.email} onChange={(event) => updateField("email", event.target.value)} placeholder="nguoidung@example.com" aria-invalid={Boolean(errors.email)} /></div>
            {errors.email ? <span className="field-error">{errors.email}</span> : null}
          </label>

          {requestError ? <div className="warning-panel"><span>{requestError}</span></div> : null}
          <div className="form-actions">
            <Link className="ghost-btn" to="/users">Hủy</Link>
            <button className="primary-btn" type="submit" disabled={submitting}><Save size={16} /> {submitting ? "Đang tạo..." : "Tạo tài khoản"}</button>
          </div>
        </form>

        <aside className="panel user-create-summary"><h2>Sau khi tạo</h2><ul className="privacy-list"><li>Auth Service tự mã hóa mật khẩu tạm mặc định.</li><li>Email OTP được gửi để người dùng xác minh tài khoản.</li><li>User Service tạo hồ sơ và liên kết bằng account ID.</li><li>Người dùng nên đổi mật khẩu ngay sau lần đăng nhập đầu.</li></ul></aside>
      </section>
    </div>
  );
}
