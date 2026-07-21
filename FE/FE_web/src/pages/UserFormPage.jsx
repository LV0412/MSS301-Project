import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ArrowLeft, Mail, Send, ShieldCheck, UserPlus } from "lucide-react";
import { inviteUserByAdmin } from "../api/userManagement.js";

function validate(form) {
  const errors = {};
  if (form.fullName.trim().length < 2) errors.fullName = "Họ và tên phải có ít nhất 2 ký tự.";
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email.trim())) errors.email = "Email không đúng định dạng.";
  return errors;
}

function mapAccountToUser(account) {
  return {
    userId: account.userId,
    authAccountId: account.accountId,
    email: account.email,
    fullName: account.fullName,
    gender: "",
    dob: "",
    createdAt: account.createdAt,
    updatedAt: account.updatedAt
  };
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
    setRequestError("");
    try {
      const account = await inviteUserByAdmin({
        fullName: form.fullName.trim(),
        email: form.email.trim().toLowerCase()
      });
      navigate(`/users/${account.userId}`, {
        replace: true,
        state: { user: mapAccountToUser(account) }
      });
    } catch (error) {
      if (error.status === 401) {
        setRequestError("Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.");
      } else if (error.status === 403) {
        setRequestError("Tài khoản hiện tại không có quyền mời người dùng.");
      } else {
        setRequestError(error.message);
      }
      if (error.details?.validationErrors) setErrors(error.details.validationErrors);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">Người dùng</p>
          <h2>Mời người dùng</h2>
          <p>Tạo lời mời tài khoản mới bằng họ tên và email.</p>
        </div>
        <Link className="ghost-btn" to="/users"><ArrowLeft size={16} /> Quay lại danh sách</Link>
      </div>

      <section className="privacy-banner compact-privacy-banner">
        <ShieldCheck size={22} />
        <div>
          <strong>Chỉ thu thập thông tin cơ bản</strong>
          <p>Form này không yêu cầu thông tin sức khỏe, dị ứng, mục tiêu dinh dưỡng hoặc lịch sử sử dụng.</p>
        </div>
      </section>

      <section className="user-invite-layout">
        <form className="form-card user-create-form user-invite-card" onSubmit={handleSubmit} noValidate>
          <div className="panel-heading">
            <div>
              <h2><UserPlus size={18} /> Thông tin người được mời</h2>
              <p>Người dùng sẽ nhận email xác minh sau khi lời mời được tạo.</p>
            </div>
          </div>

          <label>Họ và tên
            <input
              value={form.fullName}
              onChange={(event) => updateField("fullName", event.target.value)}
              placeholder="Ví dụ: Nguyễn An"
              aria-invalid={Boolean(errors.fullName)}
            />
            {errors.fullName ? <span className="field-error">{errors.fullName}</span> : null}
          </label>

          <label>Email
            <div className="field form-field-with-icon">
              <Mail size={16} />
              <input
                type="email"
                value={form.email}
                onChange={(event) => updateField("email", event.target.value)}
                placeholder="nguoidung@example.com"
                aria-invalid={Boolean(errors.email)}
              />
            </div>
            {errors.email ? <span className="field-error">{errors.email}</span> : null}
          </label>

          {requestError ? <div className="warning-panel mini"><span>{requestError}</span></div> : null}

          <div className="form-actions">
            <Link className="ghost-btn" to="/users">Hủy</Link>
            <button className="primary-btn" type="submit" disabled={submitting}>
              <Send size={16} /> {submitting ? "Đang gửi..." : "Gửi lời mời"}
            </button>
          </div>
        </form>
      </section>
    </div>
  );
}
