import { useMemo, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Mail, Save, ShieldCheck, UserPlus } from "lucide-react";
import { users } from "../data/mockData.js";
import { createUser } from "../api/userManagement.js";

const defaultCountries = ["Việt Nam", "Hoa Kỳ", "Canada", "Đức", "Anh"];

function validate(form) {
  const errors = {};
  const normalizedEmail = form.email.trim().toLowerCase();

  if (form.fullName.trim().length < 2) {
    errors.fullName = "Họ tên là bắt buộc và phải có ít nhất 2 ký tự.";
  }

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)) {
    errors.email = "Email là bắt buộc và phải đúng định dạng.";
  } else if (users.some((user) => user.email.toLowerCase() === normalizedEmail)) {
    errors.email = "Email này đã tồn tại trong hệ thống.";
  }

  if (!form.country) {
    errors.country = "Vui lòng chọn quốc gia.";
  }

  return errors;
}

export default function UserFormPage() {
  const navigate = useNavigate();
  const countries = useMemo(() => Array.from(new Set([...defaultCountries, ...users.map((user) => user.country)])), []);
  const [form, setForm] = useState({
    fullName: "",
    email: "",
    country: "",
    initialStatus: "Chờ kích hoạt",
    sendInvitation: true,
    requireOnboarding: true
  });
  const [errors, setErrors] = useState({});
  const [toast, setToast] = useState("");

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

    await createUser({
      fullName: form.fullName.trim(),
      email: form.email.trim(),
      country: form.country,
      initialStatus: form.initialStatus,
      sendInvitation: form.sendInvitation,
      requireOnboarding: form.requireOnboarding
    });
    setToast(form.sendInvitation ? "Tạo người dùng thành công. Email mời đã được gửi." : "Tạo người dùng thành công.");
    window.setTimeout(() => navigate("/users"), 900);
  }

  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">Quyền CSKH</p>
          <h2>Tạo người dùng mới</h2>
          <p>Tạo tài khoản cơ bản và gửi lời mời để người dùng tự hoàn tất đăng nhập và onboarding.</p>
        </div>
      </div>

      <section className="privacy-banner">
        <ShieldCheck size={24} />
        <div>
          <strong>Form tối thiểu dữ liệu</strong>
          <p>Màn hình này không thu thập dữ liệu sức khỏe, dị ứng, mục tiêu calo, macro, meal plan hoặc lịch sử AI của người dùng.</p>
        </div>
      </section>

      <section className="user-create-layout">
        <form className="form-card user-create-form" onSubmit={handleSubmit} noValidate>
          <div className="panel-heading">
            <div>
              <h2><UserPlus size={18} /> Thông tin cơ bản</h2>
              <p>Người dùng mới sẽ ở trạng thái Chờ kích hoạt cho đến khi đặt mật khẩu và đăng nhập lần đầu. Dữ liệu sức khỏe sẽ do người dùng tự khai báo trong onboarding.</p>
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
            Quốc gia
            <select
              value={form.country}
              onChange={(event) => updateField("country", event.target.value)}
              aria-invalid={Boolean(errors.country)}
            >
              <option value="">Chọn quốc gia</option>
              {countries.map((country) => (
                <option key={country} value={country}>{country}</option>
              ))}
            </select>
            {errors.country ? <span className="field-error">{errors.country}</span> : null}
          </label>

          <label>
            Trạng thái sau khi tạo
            <select value={form.initialStatus} onChange={(event) => updateField("initialStatus", event.target.value)}>
              <option>Chờ kích hoạt</option>
              <option>Hoạt động</option>
            </select>
          </label>

          <div className="checkbox-stack">
            <label className="checkbox-row">
              <input
                type="checkbox"
                checked={form.sendInvitation}
                onChange={(event) => updateField("sendInvitation", event.target.checked)}
              />
              <span>Gửi email mời người dùng đặt mật khẩu</span>
            </label>
            <label className="checkbox-row">
              <input
                type="checkbox"
                checked={form.requireOnboarding}
                onChange={(event) => updateField("requireOnboarding", event.target.checked)}
              />
              <span>Yêu cầu người dùng hoàn tất onboarding ở lần đăng nhập đầu tiên</span>
            </label>
          </div>

          {toast ? (
            <div className="success-note">
              <ShieldCheck size={18} />
              {toast}
            </div>
          ) : null}

          <div className="form-actions">
            <Link className="ghost-btn" to="/users">Hủy</Link>
            <button className="primary-btn" type="submit">
              <Save size={16} />
              {form.sendInvitation ? "Tạo và gửi lời mời" : "Tạo người dùng"}
            </button>
          </div>
        </form>

        <aside className="panel user-create-summary">
          <h2>Nguyên tắc quyền riêng tư</h2>
          <ul className="privacy-list">
            <li>Chỉ lưu thông tin định danh cơ bản.</li>
            <li>Không nhập dữ liệu sức khỏe trong luồng CSKH.</li>
            <li>Dữ liệu nhạy cảm mặc định hiển thị ở trạng thái masking.</li>
            <li>Người dùng tự hoàn tất hồ sơ sức khỏe trong onboarding.</li>
          </ul>
        </aside>
      </section>
    </div>
  );
}
