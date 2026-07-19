import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { CalendarDays, KeyRound, Mail, Save, UserPlus } from "lucide-react";
import { createUser } from "../api/userManagement.js";

const genderOptions = [
  { value: "MALE", label: "Nam" },
  { value: "FEMALE", label: "Nữ" },
  { value: "OTHER", label: "Khác" }
];

function validate(form) {
  const errors = {};
  const normalizedEmail = form.email.trim().toLowerCase();

  if (form.fullName.trim().length < 2) {
    errors.fullName = "Họ tên là bắt buộc và phải có ít nhất 2 ký tự.";
  }

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)) {
    errors.email = "Email là bắt buộc và phải đúng định dạng.";
  }

  if (!form.passwordHash.trim()) {
    errors.passwordHash = "Vui lòng nhập mật khẩu tạm thời.";
  }

  if (!form.gender) {
    errors.gender = "Vui lòng chọn giới tính.";
  }

  if (form.dob) {
    const dob = new Date(form.dob);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (Number.isNaN(dob.getTime()) || dob >= today) {
      errors.dob = "Ngày sinh phải là một ngày trong quá khứ.";
    }
  }

  return errors;
}

export default function UserFormPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    fullName: "",
    email: "",
    passwordHash: "",
    dob: "",
    gender: ""
  });
  const [errors, setErrors] = useState({});
  const [toast, setToast] = useState("");
  const [submitting, setSubmitting] = useState(false);

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
    setErrors((current) => ({ ...current, [field]: undefined }));
    setToast("");
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const nextErrors = validate(form);

    if (Object.keys(nextErrors).length > 0) {
      setErrors(nextErrors);
      return;
    }

    setSubmitting(true);
    setErrors({});
    try {
      await createUser({
        fullName: form.fullName.trim(),
        email: form.email.trim().toLowerCase(),
        passwordHash: form.passwordHash.trim(),
        dob: form.dob || null,
        gender: form.gender
      });
      setToast("Mời người dùng thành công.");
      window.setTimeout(() => navigate("/users"), 800);
    } catch (error) {
      setErrors({ submit: error.message || "Không tạo được người dùng. Vui lòng thử lại." });
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">Quản lý người dùng</p>
          <h2>Mời người dùng mới</h2>
          <p>Gửi lời mời tạo tài khoản người dùng cơ bản vào hệ thống NutriChef AI.</p>
        </div>
      </div>

      <section className="user-create-layout single-form-layout">
        <form className="form-card user-create-form" onSubmit={handleSubmit} noValidate>
          <div className="panel-heading">
            <div>
              <h2><UserPlus size={18} /> Thông tin tài khoản</h2>
            </div>
          </div>

          <label>
            Họ và tên
            <input
              value={form.fullName}
              onChange={(event) => updateField("fullName", event.target.value)}
              placeholder="Ví dụ: Nguyễn An"
              aria-invalid={Boolean(errors.fullName)}
            />
            {errors.fullName ? <span className="field-error">{errors.fullName}</span> : null}
          </label>

          <label>
            Email
            <div className="field form-field-with-icon">
              <Mail size={16} />
              <input
                value={form.email}
                onChange={(event) => updateField("email", event.target.value)}
                placeholder="nguoidung@example.com"
                aria-invalid={Boolean(errors.email)}
              />
            </div>
            {errors.email ? <span className="field-error">{errors.email}</span> : null}
          </label>

          <label>
            Mật khẩu tạm thời
            <div className="field form-field-with-icon">
              <KeyRound size={16} />
              <input
                value={form.passwordHash}
                onChange={(event) => updateField("passwordHash", event.target.value)}
                placeholder="Nhập mật khẩu tạm thời"
                aria-invalid={Boolean(errors.passwordHash)}
              />
            </div>
            {errors.passwordHash ? <span className="field-error">{errors.passwordHash}</span> : null}
          </label>

          <label>
            Ngày sinh
            <div className="field form-field-with-icon">
              <CalendarDays size={16} />
              <input
                type="date"
                value={form.dob}
                onChange={(event) => updateField("dob", event.target.value)}
                aria-invalid={Boolean(errors.dob)}
              />
            </div>
            {errors.dob ? <span className="field-error">{errors.dob}</span> : null}
          </label>

          <label>
            Giới tính
            <select
              value={form.gender}
              onChange={(event) => updateField("gender", event.target.value)}
              aria-invalid={Boolean(errors.gender)}
            >
              <option value="">Chọn giới tính</option>
              {genderOptions.map((option) => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>
            {errors.gender ? <span className="field-error">{errors.gender}</span> : null}
          </label>

          {errors.submit ? (
            <div className="login-error" role="alert">
              {errors.submit}
            </div>
          ) : null}

          {toast ? (
            <div className="success-note">
              {toast}
            </div>
          ) : null}

          <div className="form-actions">
            <Link className="ghost-btn" to="/users">Hủy</Link>
            <button className="primary-btn" type="submit" disabled={submitting}>
              <Save size={16} />
              {submitting ? "Đang gửi..." : "Mời người dùng"}
            </button>
          </div>
        </form>
      </section>
    </div>
  );
}
