import { Link } from "react-router-dom";
import {
  Ban,
  Download,
  Eye,
  Mail,
  MoreVertical,
  RotateCcw,
  Search,
  Send,
  ShieldAlert,
  ShieldCheck,
  Unlock,
  UserCheck,
  UserPlus,
  Users
} from "lucide-react";
import { users } from "../data/mockData.js";
import {
  deactivateUser,
  lockUser,
  resendInvitation,
  resetOnboarding,
  sendSupportEmail,
  unlockUser
} from "../api/userManagement.js";

const userRows = [
  { ...users[0], accountStatus: "Hoạt động", onboarding: "Hoàn tất", emailVerified: "Có", healthDataStatus: "Đã ẩn", savedRecipes: 18, hasMealPlan: "Có", supportRequests: 0 },
  { ...users[1], accountStatus: "Hoạt động", onboarding: "Chưa hoàn tất", emailVerified: "Có", healthDataStatus: "Bị giới hạn", savedRecipes: 7, hasMealPlan: "Chưa", supportRequests: 1 },
  { ...users[2], accountStatus: "Không hoạt động", onboarding: "Chưa hoàn tất", emailVerified: "Chưa", healthDataStatus: "Chưa có", savedRecipes: 3, hasMealPlan: "Chưa", supportRequests: 2 },
  { ...users[3], accountStatus: "Bị khóa", onboarding: "Hoàn tất", emailVerified: "Có", healthDataStatus: "Đã ẩn", savedRecipes: 24, hasMealPlan: "Có", supportRequests: 1 }
];

const kpis = [
  { label: "Tổng người dùng", value: "1,284", icon: Users },
  { label: "Đang hoạt động", value: "982", icon: UserCheck },
  { label: "Không hoạt động", value: "182", icon: Ban },
  { label: "Chưa onboarding", value: "96", icon: RotateCcw },
  { label: "Bị khóa", value: "24", icon: ShieldAlert, danger: true }
];

function requestReason(actionLabel, userName) {
  return window.prompt(`Nhập lý do để ${actionLabel.toLowerCase()} cho ${userName}:`);
}

async function runSupportAction(action, user) {
  if (action.requiresReason) {
    const reason = requestReason(action.label, user.name);
    if (!reason) return;
    if (!window.confirm(`Xác nhận ${action.label.toLowerCase()} cho ${user.name}?`)) return;
    await action.handler(user.id, reason);
    return;
  }

  if (action.confirm && !window.confirm(`Xác nhận ${action.label.toLowerCase()} cho ${user.name}?`)) return;
  await action.handler(user.id);
}

const actionItems = [
  { label: "Gửi email hỗ trợ", icon: Mail, handler: sendSupportEmail },
  { label: "Gửi lại email kích hoạt", icon: Send, handler: resendInvitation },
  { label: "Reset onboarding", icon: RotateCcw, handler: resetOnboarding, requiresReason: true },
  { label: "Khóa tài khoản", icon: ShieldAlert, handler: lockUser, requiresReason: true, danger: true },
  { label: "Mở khóa tài khoản", icon: Unlock, handler: unlockUser, requiresReason: true },
  { label: "Vô hiệu hóa tài khoản", icon: Ban, handler: deactivateUser, requiresReason: true, danger: true }
];

export default function UsersPage() {
  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">Quyền CSKH</p>
          <h2>Quản lý người dùng</h2>
          <p>Quản lý tài khoản, trạng thái hoạt động và hỗ trợ người dùng mà không hiển thị dữ liệu sức khỏe nhạy cảm.</p>
        </div>
        <div className="button-row">
          <Link className="primary-btn" to="/users/new"><UserPlus size={16} /> Mời người dùng</Link>
          <button className="ghost-btn"><Download size={16} /> Xuất danh sách</button>
        </div>
      </div>

      <section className="privacy-banner">
        <ShieldCheck size={24} />
        <div>
          <strong>Chế độ bảo vệ dữ liệu sức khỏe đang bật</strong>
          <p>Support Admin chỉ xem dữ liệu cần thiết cho chăm sóc khách hàng. Bệnh lý, cân nặng, mục tiêu calo, dị ứng, macro, meal plan cụ thể và lịch sử AI cá nhân hóa được masking theo quyền.</p>
        </div>
      </section>

      <section className="kpi-grid overview-main-kpis">
        {kpis.map(({ label, value, icon: Icon, danger }) => (
          <article className={`kpi-card compact-kpi ${danger ? "danger-card" : ""}`} key={label}>
            <div className="kpi-icon"><Icon size={19} /></div>
            <span>{label}</span>
            <strong>{value}</strong>
          </article>
        ))}
      </section>

      <section className="panel">
        <div className="filter-grid user-management-filter-grid">
          <label>Quốc gia
            <select>
              <option>Tất cả quốc gia</option>
              <option>Việt Nam</option>
              <option>Hoa Kỳ</option>
              <option>Canada</option>
              <option>Đức</option>
              <option>Anh</option>
            </select>
          </label>
          <label>Trạng thái tài khoản
            <select>
              <option>Tất cả</option>
              <option>Hoạt động</option>
              <option>Không hoạt động</option>
              <option>Chờ kích hoạt</option>
              <option>Bị khóa</option>
            </select>
          </label>
          <label>Onboarding
            <select>
              <option>Tất cả</option>
              <option>Hoàn tất</option>
              <option>Chưa hoàn tất</option>
            </select>
          </label>
          <label>Dữ liệu sức khỏe
            <select>
              <option>Tất cả</option>
              <option>Đã ẩn</option>
              <option>Chưa có</option>
              <option>Bị giới hạn</option>
            </select>
          </label>
          <label>Tìm kiếm
            <div className="field">
              <Search size={15} />
              <input placeholder="Tìm theo tên hoặc email..." />
            </div>
          </label>
          <button className="ghost-btn">Xóa bộ lọc</button>
        </div>
      </section>

      <section className="panel">
        <table className="data-table user-table">
          <thead>
            <tr>
              <th>Người dùng</th>
              <th>Email</th>
              <th>Quốc gia</th>
              <th>Trạng thái tài khoản</th>
              <th>Onboarding</th>
              <th>Hoạt động cuối</th>
              <th>Dữ liệu sức khỏe</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            {userRows.map((user) => (
              <tr className={user.accountStatus === "Không hoạt động" ? "soft-danger-row" : ""} key={user.id}>
                <td className="person-cell">
                  <span className="avatar-xs">{user.avatar}</span>
                  <div>
                    <strong>{user.name}</strong>
                    <small>{user.savedRecipes} công thức đã lưu · Kế hoạch ăn uống: {user.hasMealPlan} · {user.supportRequests} yêu cầu hỗ trợ</small>
                  </div>
                </td>
                <td>{user.email}</td>
                <td>{user.country}</td>
                <td><span className={`status-dot ${user.accountStatus !== "Hoạt động" ? "muted" : ""}`}>{user.accountStatus}</span></td>
                <td><span className={`chip ${user.onboarding === "Hoàn tất" ? "active" : ""}`}>{user.onboarding}</span></td>
                <td>{user.lastActive}</td>
                <td><span className="masked-pill">{user.healthDataStatus}</span></td>
                <td className="actions-cell">
                  <Link className="icon-link" to={`/users/${user.id}`} title="Xem chi tiết" aria-label="Xem chi tiết người dùng"><Eye size={17} /></Link>
                  <details className="action-menu">
                    <summary title="Mở menu hành động" aria-label="Mở menu hành động"><MoreVertical size={17} /></summary>
                    <div className="action-menu-list">
                      {actionItems.map(({ icon: Icon, ...action }) => (
                        <button
                          className={action.danger ? "danger-action" : ""}
                          key={action.label}
                          onClick={() => runSupportAction(action, user)}
                          title={action.label}
                        >
                          <Icon size={15} />
                          {action.label}
                        </button>
                      ))}
                    </div>
                  </details>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="table-footer">
          <span>Hiển thị 1-10 trong 1,284 người dùng</span>
          <div className="pagination"><button disabled>‹</button><button className="active">1</button><button>2</button><button>3</button><span>...</span><button>321</button><button>›</button></div>
        </div>
      </section>

      <section className="warning-panel access-note-panel">
        <ShieldAlert size={20} />
        <div>
          <strong>Ghi chú quyền truy cập</strong>
          <p>Nếu cần xem dữ liệu sức khỏe chi tiết, Admin phải có quyền USER_HEALTH_READ và lý do nghiệp vụ rõ ràng. Mọi lần truy cập dữ liệu nhạy cảm phải được ghi vào audit log.</p>
        </div>
      </section>
    </div>
  );
}
