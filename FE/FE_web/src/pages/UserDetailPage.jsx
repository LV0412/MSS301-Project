import { Link, useParams } from "react-router-dom";
import {
  Ban,
  CalendarDays,
  EyeOff,
  History,
  Lock,
  Mail,
  RotateCcw,
  Send,
  ShieldAlert,
  ShieldCheck,
  Unlock,
  UserCircle
} from "lucide-react";
import { users } from "../data/mockData.js";
import {
  deactivateUser,
  lockUser,
  requestSensitiveAccess,
  resendInvitation,
  resetOnboarding,
  sendSupportEmail,
  unlockUser
} from "../api/userManagement.js";

const userMeta = {
  elena: { accountStatus: "Hoạt động", onboarding: "Hoàn tất", healthDataStatus: "Đã ẩn", emailVerified: "Có", signupSource: "Google", savedRecipes: 18, hasMealPlan: "Có", aiRequests: 142, openTickets: 0 },
  marcus: { accountStatus: "Hoạt động", onboarding: "Chưa hoàn tất", healthDataStatus: "Bị giới hạn", emailVerified: "Có", signupSource: "Email", savedRecipes: 7, hasMealPlan: "Chưa", aiRequests: 38, openTickets: 1 },
  sarah: { accountStatus: "Không hoạt động", onboarding: "Chưa hoàn tất", healthDataStatus: "Chưa có", emailVerified: "Chưa", signupSource: "Admin invite", savedRecipes: 3, hasMealPlan: "Chưa", aiRequests: 9, openTickets: 2 },
  julia: { accountStatus: "Bị khóa", onboarding: "Hoàn tất", healthDataStatus: "Đã ẩn", emailVerified: "Có", signupSource: "Email", savedRecipes: 24, hasMealPlan: "Có", aiRequests: 186, openTickets: 1 }
};

const supportLogs = [
  { title: "Reset onboarding", admin: "Admin Linh", time: "2 ngày trước" },
  { title: "Gửi email hỗ trợ", admin: "Admin Panel", time: "5 ngày trước" },
  { title: "Kiểm tra đăng nhập", admin: "CSKH Team", time: "1 tuần trước" },
  { title: "Mở khóa tài khoản", admin: "Security Admin", time: "2 tuần trước" }
];

const maskedSections = [
  { title: "Hồ sơ sức khỏe", description: "Bệnh lý, cân nặng, chiều cao và tình trạng sức khỏe chi tiết đã bị masking." },
  { title: "Mục tiêu dinh dưỡng", description: "Mục tiêu calo, macro, goal completion và tiến độ dinh dưỡng không hiển thị cho CSKH." },
  { title: "Dị ứng & sở thích", description: "Tên dị ứng cụ thể, sở thích ăn uống và hạn chế cá nhân được bảo vệ theo quyền." },
  { title: "Meal plan & AI history", description: "Không hiển thị thực đơn, recipe cụ thể, prompt hoặc response AI cá nhân hóa." }
];

function requestReason(actionLabel, userName) {
  return window.prompt(`Nhập lý do để ${actionLabel.toLowerCase()} cho ${userName}:`);
}

async function runAction(actionLabel, handler, user, requiresReason = false) {
  if (requiresReason) {
    const reason = requestReason(actionLabel, user.name);
    if (!reason) return;
    if (!window.confirm(`Xác nhận ${actionLabel.toLowerCase()} cho ${user.name}?`)) return;
    await handler(user.id, reason);
    return;
  }

  if (!window.confirm(`Xác nhận ${actionLabel.toLowerCase()} cho ${user.name}?`)) return;
  await handler(user.id);
}

export default function UserDetailPage() {
  const { id } = useParams();
  const user = users.find((item) => item.id === id) ?? users[0];
  const meta = userMeta[user.id] ?? userMeta.elena;

  return (
    <div className="page-stack">
      <div className="profile-hero restricted-profile-hero user-detail-hero">
        <div className="large-avatar">{user.avatar}</div>
        <div>
          <p className="eyebrow">Hồ sơ CSKH</p>
          <h2>{user.name}</h2>
          <span>{user.email}</span>
          <div className="chip-row profile-badges">
            <span className={`chip ${meta.accountStatus === "Hoạt động" ? "active" : ""}`}>{meta.accountStatus}</span>
            <span className="chip">{meta.onboarding}</span>
            <span className="masked-pill">Dữ liệu sức khỏe {meta.healthDataStatus.toLowerCase()}</span>
          </div>
        </div>
        <Link className="ghost-btn" to="/users">Quay lại danh sách</Link>
      </div>

      <section className="privacy-banner">
        <ShieldCheck size={24} />
        <div>
          <strong>Hồ sơ đang ở chế độ tối thiểu dữ liệu</strong>
          <p>Thông tin riêng tư và dữ liệu sức khỏe chi tiết đã được masking để tránh lộ dữ liệu cá nhân.</p>
        </div>
      </section>

      <section className="dashboard-grid">
        <article className="panel span-2">
          <h2><UserCircle size={18} /> Thông tin tài khoản</h2>
          <dl className="info-list account-info-grid">
            <dt>Tên</dt><dd>{user.name}</dd>
            <dt>Email</dt><dd>{user.email}</dd>
            <dt>Quốc gia</dt><dd>{user.country}</dd>
            <dt>Trạng thái tài khoản</dt><dd><span className={`status-dot ${meta.accountStatus !== "Hoạt động" ? "muted" : ""}`}>{meta.accountStatus}</span></dd>
            <dt>Email đã xác thực</dt><dd>{meta.emailVerified}</dd>
            <dt>Ngày tham gia</dt><dd>{user.joined}</dd>
            <dt>Hoạt động cuối</dt><dd>{user.lastActive}</dd>
            <dt>Onboarding</dt><dd>{meta.onboarding}</dd>
            <dt>Nguồn đăng ký</dt><dd>{meta.signupSource}</dd>
          </dl>
        </article>

        <article className="panel">
          <h2><Lock size={18} /> Hành động hỗ trợ</h2>
          <div className="support-action-list vertical-actions">
            <button className="ghost-btn" onClick={() => sendSupportEmail(user.id)} title="Gửi email hỗ trợ"><Mail size={16} /> Gửi email hỗ trợ</button>
            <button className="ghost-btn" onClick={() => resendInvitation(user.id)} title="Gửi lại email kích hoạt"><Send size={16} /> Gửi lại email kích hoạt</button>
            <button className="ghost-btn" onClick={() => runAction("Reset onboarding", resetOnboarding, user, true)} title="Reset onboarding"><RotateCcw size={16} /> Reset onboarding</button>
            <button className="ghost-btn" onClick={() => runAction("Khóa tài khoản", lockUser, user, true)} title="Khóa tài khoản"><Lock size={16} /> Khóa tài khoản</button>
            <button className="ghost-btn" onClick={() => runAction("Mở khóa tài khoản", unlockUser, user, true)} title="Mở khóa tài khoản"><Unlock size={16} /> Mở khóa tài khoản</button>
            <button className="danger-link" onClick={() => runAction("Vô hiệu hóa tài khoản", deactivateUser, user, true)} title="Vô hiệu hóa tài khoản"><Ban size={16} /> Vô hiệu hóa tài khoản</button>
          </div>
        </article>
      </section>

      <section className="dashboard-grid">
        <article className="panel">
          <h2><History size={18} /> Lịch sử hoạt động cơ bản</h2>
          <dl className="info-list">
            <dt>Lần đăng nhập gần nhất</dt><dd>{user.lastActive}</dd>
            <dt>Số công thức đã lưu</dt><dd>{meta.savedRecipes} mục</dd>
            <dt>Có meal plan hay chưa</dt><dd>{meta.hasMealPlan}</dd>
            <dt>Số AI requests</dt><dd>{meta.aiRequests}</dd>
            <dt>Khiếu nại mở</dt><dd>{meta.openTickets} yêu cầu</dd>
          </dl>
        </article>

        <article className="panel">
          <h2><CalendarDays size={18} /> Nhật ký hỗ trợ</h2>
          <ul className="timeline-list support-log-list">
            {supportLogs.map((item) => (
              <li key={`${item.title}-${item.time}`}>
                <strong>{item.title}</strong>
                <span>{item.time} · {item.admin}</span>
              </li>
            ))}
          </ul>
        </article>
      </section>

      <section className="masked-grid">
        {maskedSections.map((section) => (
          <article className="masked-card" key={section.title}>
            <EyeOff size={20} />
            <strong>{section.title}</strong>
            <p>{section.description}</p>
            <span className="masked-pill">MASKED</span>
            <small>Cần quyền USER_HEALTH_READ để xem.</small>
            <button className="ghost-btn" onClick={() => runAction("Yêu cầu quyền truy cập", requestSensitiveAccess, user, true)}>
              Yêu cầu quyền truy cập
            </button>
          </article>
        ))}
      </section>

      <section className="warning-panel access-note-panel">
        <ShieldAlert size={20} />
        <div>
          <strong>Ghi chú quyền truy cập</strong>
          <p>Màn hình CSKH mặc định không mở khóa dữ liệu sức khỏe. Mọi truy cập dữ liệu nhạy cảm cần quyền cao hơn, lý do nghiệp vụ rõ ràng và được ghi vào audit log.</p>
        </div>
      </section>
    </div>
  );
}
