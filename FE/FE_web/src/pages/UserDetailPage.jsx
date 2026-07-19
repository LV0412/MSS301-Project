import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import {
  Ban,
  CalendarDays,
  EyeOff,
  Lock,
  Mail,
  RotateCcw,
  Send,
  ShieldAlert,
  ShieldCheck,
  Unlock,
  UserCircle
} from "lucide-react";
import {
  deactivateUser,
  getUserById,
  lockUser,
  requestSensitiveAccess,
  resendInvitation,
  resetOnboarding,
  sendSupportEmail,
  unlockUser
} from "../api/userManagement.js";

const genderLabels = {
  MALE: "Nam",
  FEMALE: "Nữ",
  OTHER: "Khác"
};

const maskedSections = [
  {
    title: "Hồ sơ sức khỏe",
    description: "User Service hiện không trả bệnh lý, cân nặng, chiều cao hoặc chỉ số sức khỏe chi tiết."
  },
  {
    title: "Mục tiêu dinh dưỡng",
    description: "Mục tiêu calo, macro, goal completion và tiến độ dinh dưỡng không nằm trong UserResponse."
  },
  {
    title: "Dị ứng & sở thích",
    description: "Thông tin dị ứng, sở thích ăn uống và hạn chế cá nhân không được lấy từ API người dùng hiện tại."
  },
  {
    title: "Meal plan & AI history",
    description: "Lịch sử meal plan, recipe đã lưu, prompt hoặc response AI chưa có endpoint trong user-service."
  }
];

function initials(name = "") {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join("")
    .toUpperCase() || "US";
}

function formatDate(value) {
  if (!value) return "Chưa có";
  return new Intl.DateTimeFormat("vi-VN", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric"
  }).format(new Date(value));
}

function formatDateTime(value) {
  if (!value) return "Chưa có";
  return new Intl.DateTimeFormat("vi-VN", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit"
  }).format(new Date(value));
}

async function runAction(actionLabel, handler, user, requiresReason = false) {
  try {
    if (requiresReason) {
      const reason = window.prompt(`Nhập lý do để ${actionLabel.toLowerCase()} cho ${user.fullName}:`);
      if (!reason) return;
      await handler(user.userId, reason);
      return;
    }

    await handler(user.userId);
  } catch (error) {
    window.alert(error.message || `${actionLabel} chưa có API trong user-service hiện tại.`);
  }
}

export default function UserDetailPage() {
  const { id } = useParams();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let cancelled = false;

    async function loadUser() {
      setLoading(true);
      setError("");
      try {
        const data = await getUserById(id);
        if (!cancelled) setUser(data);
      } catch (err) {
        if (!cancelled) setError(err.message || "Không tải được hồ sơ người dùng.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    loadUser();

    return () => {
      cancelled = true;
    };
  }, [id]);

  if (loading) {
    return (
      <div className="page-stack">
        <section className="panel">
          <p>Đang tải hồ sơ người dùng...</p>
        </section>
      </div>
    );
  }

  if (error || !user) {
    return (
      <div className="page-stack">
        <section className="warning-panel access-note-panel">
          <ShieldAlert size={20} />
          <div>
            <strong>Không tải được hồ sơ</strong>
            <p>{error || "Người dùng không tồn tại."}</p>
            <Link className="ghost-btn" to="/users">Quay lại danh sách</Link>
          </div>
        </section>
      </div>
    );
  }

  return (
    <div className="page-stack">
      <div className="profile-hero restricted-profile-hero user-detail-hero">
        <div className="large-avatar">{initials(user.fullName)}</div>
        <div>
          <p className="eyebrow">User Service</p>
          <h2>{user.fullName}</h2>
          <span>{user.email}</span>
          <div className="chip-row profile-badges">
            <span className="chip active">ID #{user.userId}</span>
            <span className="chip">{genderLabels[user.gender] || "Chưa có giới tính"}</span>
            <span className="masked-pill">Dữ liệu sức khỏe không có trong UserResponse</span>
          </div>
        </div>
        <Link className="ghost-btn" to="/users">Quay lại danh sách</Link>
      </div>

      <section className="privacy-banner">
        <ShieldCheck size={24} />
        <div>
          <strong>Hồ sơ chỉ hiển thị dữ liệu cơ bản từ BE</strong>
          <p>Màn hình này bám theo `UserResponse`: userId, email, fullName, dob, gender, createdAt và updatedAt. Không hiển thị quốc gia, trạng thái tài khoản, sức khỏe, meal plan hoặc AI history vì BE chưa cung cấp.</p>
        </div>
      </section>

      <section className="dashboard-grid">
        <article className="panel span-2">
          <h2><UserCircle size={18} /> Thông tin người dùng</h2>
          <dl className="info-list account-info-grid">
            <dt>Mã người dùng</dt><dd>#{user.userId}</dd>
            <dt>Họ và tên</dt><dd>{user.fullName}</dd>
            <dt>Email</dt><dd>{user.email}</dd>
            <dt>Ngày sinh</dt><dd>{formatDate(user.dob)}</dd>
            <dt>Giới tính</dt><dd>{genderLabels[user.gender] || user.gender || "Chưa có"}</dd>
            <dt>Ngày tạo</dt><dd>{formatDateTime(user.createdAt)}</dd>
            <dt>Cập nhật lần cuối</dt><dd>{formatDateTime(user.updatedAt)}</dd>
          </dl>
        </article>

        <article className="panel">
          <h2><Lock size={18} /> Hành động hỗ trợ</h2>
          <p className="muted-text">Các hành động dưới đây được giữ ở UI để định hướng nghiệp vụ, nhưng user-service hiện chưa có endpoint tương ứng.</p>
          <div className="support-action-list vertical-actions">
            <button className="ghost-btn" onClick={() => runAction("Gửi email hỗ trợ", sendSupportEmail, user)} title="Chưa có API"><Mail size={16} /> Gửi email hỗ trợ</button>
            <button className="ghost-btn" onClick={() => runAction("Gửi lại email kích hoạt", resendInvitation, user)} title="Chưa có API"><Send size={16} /> Gửi lại email kích hoạt</button>
            <button className="ghost-btn" onClick={() => runAction("Reset onboarding", resetOnboarding, user, true)} title="Chưa có API"><RotateCcw size={16} /> Reset onboarding</button>
            <button className="ghost-btn" onClick={() => runAction("Khóa tài khoản", lockUser, user, true)} title="Chưa có API"><Lock size={16} /> Khóa tài khoản</button>
            <button className="ghost-btn" onClick={() => runAction("Mở khóa tài khoản", unlockUser, user, true)} title="Chưa có API"><Unlock size={16} /> Mở khóa tài khoản</button>
            <button className="danger-link" onClick={() => runAction("Vô hiệu hóa tài khoản", deactivateUser, user, true)} title="Chưa có API"><Ban size={16} /> Vô hiệu hóa tài khoản</button>
          </div>
        </article>
      </section>

      <section className="dashboard-grid">
        <article className="panel">
          <h2><CalendarDays size={18} /> Metadata từ User Service</h2>
          <dl className="info-list">
            <dt>Ngày tạo bản ghi</dt><dd>{formatDateTime(user.createdAt)}</dd>
            <dt>Ngày cập nhật bản ghi</dt><dd>{formatDateTime(user.updatedAt)}</dd>
            <dt>Trạng thái tài khoản</dt><dd><span className="masked-pill">Chưa có field trong BE</span></dd>
            <dt>Quốc gia</dt><dd><span className="masked-pill">Chưa có field trong BE</span></dd>
          </dl>
        </article>

        <article className="panel">
          <h2><ShieldAlert size={18} /> Giới hạn dữ liệu</h2>
          <p>Trang chi tiết đã bỏ các dữ liệu mock như lịch sử đăng nhập, công thức đã lưu, meal plan, AI requests và ticket hỗ trợ để tránh hiển thị sai so với BE.</p>
          <button className="ghost-btn" onClick={() => runAction("Yêu cầu quyền truy cập", requestSensitiveAccess, user, true)}>
            Yêu cầu quyền truy cập dữ liệu nhạy cảm
          </button>
        </article>
      </section>

      <section className="masked-grid">
        {maskedSections.map((section) => (
          <article className="masked-card" key={section.title}>
            <EyeOff size={20} />
            <strong>{section.title}</strong>
            <p>{section.description}</p>
            <span className="masked-pill">KHÔNG CÓ TRONG API</span>
          </article>
        ))}
      </section>
    </div>
  );
}
