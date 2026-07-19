import { useEffect, useMemo, useState } from "react";
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
import {
  deactivateUser,
  getAllUsers,
  lockUser,
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

const actionItems = [
  { label: "Gửi email hỗ trợ", icon: Mail, handler: sendSupportEmail },
  { label: "Gửi lại email kích hoạt", icon: Send, handler: resendInvitation },
  { label: "Reset onboarding", icon: RotateCcw, handler: resetOnboarding, requiresReason: true },
  { label: "Khóa tài khoản", icon: ShieldAlert, handler: lockUser, requiresReason: true, danger: true },
  { label: "Mở khóa tài khoản", icon: Unlock, handler: unlockUser, requiresReason: true },
  { label: "Vô hiệu hóa tài khoản", icon: Ban, handler: deactivateUser, requiresReason: true, danger: true }
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

function matchesSearch(user, query) {
  if (!query) return true;
  return user.fullName?.toLowerCase().includes(query)
    || user.email?.toLowerCase().includes(query)
    || String(user.userId).includes(query);
}

function matchesSelect(selectedValue, userValue) {
  return selectedValue === "all" || userValue === selectedValue;
}

function matchesDobStatus(status, dob) {
  if (status === "hasDob") return Boolean(dob);
  if (status === "missingDob") return !dob;
  return true;
}

function toDateOnly(value) {
  if (!value) return null;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;
  date.setHours(0, 0, 0, 0);
  return date;
}

function matchesDateRange(value, from, to) {
  const date = toDateOnly(value);
  const fromDate = toDateOnly(from);
  const toDate = toDateOnly(to);

  if (fromDate && (!date || date < fromDate)) return false;
  if (toDate && (!date || date > toDate)) return false;
  return true;
}

async function runSupportAction(action, user) {
  try {
    if (action.requiresReason) {
      const reason = window.prompt(`Nhập lý do để ${action.label.toLowerCase()} cho ${user.fullName}:`);
      if (!reason) return;
      await action.handler(user.userId, reason);
      return;
    }
    await action.handler(user.userId);
  } catch (error) {
    window.alert(error.message || "Chức năng này chưa có API trong user-service hiện tại.");
  }
}

export default function UsersPage() {
  const [usersPage, setUsersPage] = useState({ content: [], totalElements: 0, number: 0, totalPages: 1 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [searchTerm, setSearchTerm] = useState("");
  const [filters, setFilters] = useState({
    gender: "all",
    dobStatus: "all",
    createdFrom: "",
    createdTo: "",
    updatedFrom: "",
    updatedTo: ""
  });
  const [actionMenu, setActionMenu] = useState(null);

  useEffect(() => {
    let cancelled = false;

    async function loadUsers() {
      setLoading(true);
      setError("");
      try {
        const data = await getAllUsers({ size: 100 });
        if (!cancelled) setUsersPage(data);
      } catch (err) {
        if (!cancelled) setError(err.message || "Không tải được danh sách người dùng.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    loadUsers();

    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (!actionMenu) return undefined;

    function closeMenu() {
      setActionMenu(null);
    }

    window.addEventListener("click", closeMenu);
    window.addEventListener("resize", closeMenu);
    window.addEventListener("scroll", closeMenu, true);

    return () => {
      window.removeEventListener("click", closeMenu);
      window.removeEventListener("resize", closeMenu);
      window.removeEventListener("scroll", closeMenu, true);
    };
  }, [actionMenu]);

  const rows = usersPage.content || [];
  const filteredRows = useMemo(() => {
    const query = searchTerm.trim().toLowerCase();
    return rows.filter((user) =>
      matchesSearch(user, query)
      && matchesSelect(filters.gender, user.gender)
      && matchesDobStatus(filters.dobStatus, user.dob)
      && matchesDateRange(user.createdAt, filters.createdFrom, filters.createdTo)
      && matchesDateRange(user.updatedAt, filters.updatedFrom, filters.updatedTo)
    );
  }, [rows, searchTerm, filters]);

  const kpis = [
    { label: "Tổng hồ sơ", value: usersPage.totalElements ?? rows.length, icon: Users },
    { label: "Đang hiển thị", value: filteredRows.length, icon: UserCheck },
    { label: "Có ngày sinh", value: rows.filter((user) => Boolean(user.dob)).length, icon: ShieldCheck },
    { label: "Thiếu ngày sinh", value: rows.filter((user) => !user.dob).length, icon: ShieldAlert },
    { label: "API", value: error ? "Lỗi" : "OK", icon: ShieldCheck, danger: Boolean(error) }
  ];

  function toggleActionMenu(event, user) {
    event.stopPropagation();
    const rect = event.currentTarget.getBoundingClientRect();
    const menuWidth = 250;
    const left = Math.min(window.innerWidth - menuWidth - 16, Math.max(16, rect.right - menuWidth));
    const top = Math.min(window.innerHeight - 300, rect.bottom + 8);

    setActionMenu((current) =>
      current?.user.userId === user.userId
        ? null
        : { user, top: Math.max(16, top), left }
    );
  }

  async function handleActionClick(action, user) {
    setActionMenu(null);
    await runSupportAction(action, user);
  }

  function updateFilter(field, value) {
    setFilters((current) => ({ ...current, [field]: value }));
  }

  function clearFilters() {
    setSearchTerm("");
    setFilters({
      gender: "all",
      dobStatus: "all",
      createdFrom: "",
      createdTo: "",
      updatedFrom: "",
      updatedTo: ""
    });
  }

  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">User Service</p>
          <h2>Quản lý người dùng</h2>
          <p>Đồng bộ với UserResponse: mã người dùng, tên, email, ngày sinh, giới tính, ngày tạo và ngày cập nhật.</p>
        </div>
        <div className="button-row">
          <Link className="primary-btn" to="/users/new"><UserPlus size={16} /> Mời người dùng</Link>
          <button className="ghost-btn" type="button" disabled><Download size={16} /> Xuất danh sách</button>
        </div>
      </div>

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
          <label>Tìm kiếm
            <div className="field">
              <Search size={15} />
              <input
                value={searchTerm}
                onChange={(event) => setSearchTerm(event.target.value)}
                placeholder="Tìm theo ID, tên hoặc email..."
              />
            </div>
          </label>
          <label>Giới tính
            <select value={filters.gender} onChange={(event) => updateFilter("gender", event.target.value)}>
              <option value="all">Tất cả</option>
              <option value="MALE">Nam</option>
              <option value="FEMALE">Nữ</option>
              <option value="OTHER">Khác</option>
            </select>
          </label>
          <label>Ngày sinh
            <select value={filters.dobStatus} onChange={(event) => updateFilter("dobStatus", event.target.value)}>
              <option value="all">Tất cả</option>
              <option value="hasDob">Đã có ngày sinh</option>
              <option value="missingDob">Chưa có ngày sinh</option>
            </select>
          </label>
          <label>Tạo từ ngày
            <input
              type="date"
              value={filters.createdFrom}
              onChange={(event) => updateFilter("createdFrom", event.target.value)}
            />
          </label>
          <label>Tạo đến ngày
            <input
              type="date"
              value={filters.createdTo}
              onChange={(event) => updateFilter("createdTo", event.target.value)}
            />
          </label>
          <label>Cập nhật từ ngày
            <input
              type="date"
              value={filters.updatedFrom}
              onChange={(event) => updateFilter("updatedFrom", event.target.value)}
            />
          </label>
          <label>Cập nhật đến ngày
            <input
              type="date"
              value={filters.updatedTo}
              onChange={(event) => updateFilter("updatedTo", event.target.value)}
            />
          </label>
          <button className="ghost-btn" type="button" onClick={clearFilters}>Xóa bộ lọc</button>
        </div>
      </section>

      <section className="panel">
        {loading ? <p>Đang tải danh sách người dùng...</p> : null}
        {error ? (
          <div className="login-error" role="alert">
            <ShieldAlert size={18} />
            <span>{error}. Hãy kiểm tra user-service và gateway route /api/v1/users/**.</span>
          </div>
        ) : null}

        {!loading && !error ? (
          <>
            <div className="table-scroll">
              <table className="data-table user-table">
                <thead>
                  <tr>
                    <th>Người dùng</th>
                    <th>Email</th>
                    <th>Ngày sinh</th>
                    <th>Giới tính</th>
                    <th>Ngày tạo</th>
                    <th>Cập nhật</th>
                    <th>Dữ liệu sức khỏe</th>
                    <th>Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredRows.map((user) => (
                    <tr key={user.userId}>
                      <td className="person-cell">
                        <span className="avatar-xs">{initials(user.fullName)}</span>
                        <div>
                          <strong>{user.fullName}</strong>
                          <small>ID #{user.userId}</small>
                        </div>
                      </td>
                      <td>{user.email}</td>
                      <td>{formatDate(user.dob)}</td>
                      <td>{genderLabels[user.gender] || user.gender || "Chưa có"}</td>
                      <td>{formatDate(user.createdAt)}</td>
                      <td>{formatDate(user.updatedAt)}</td>
                      <td><span className="masked-pill">Không có trong UserResponse</span></td>
                      <td className="actions-cell">
                        <Link className="icon-link" to={`/users/${user.userId}`} title="Xem chi tiết" aria-label="Xem chi tiết người dùng"><Eye size={17} /></Link>
                        <button
                          className="icon-link action-trigger"
                          type="button"
                          title="Mở menu hành động"
                          aria-label="Mở menu hành động"
                          onClick={(event) => toggleActionMenu(event, user)}
                        >
                          <MoreVertical size={17} />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <div className="table-footer">
              <span>Hiển thị {filteredRows.length} trong {usersPage.totalElements ?? rows.length} hồ sơ</span>
              <div className="pagination"><button disabled>‹</button><button className="active">1</button><button disabled>›</button></div>
            </div>
          </>
        ) : null}
      </section>

      {actionMenu ? (
        <div
          className="action-floating-menu"
          style={{ top: actionMenu.top, left: actionMenu.left }}
          onClick={(event) => event.stopPropagation()}
        >
          <div className="action-floating-header">
            <strong>{actionMenu.user.fullName}</strong>
            <span>ID #{actionMenu.user.userId}</span>
          </div>
          <div className="action-menu-list">
            {actionItems.map(({ icon: Icon, ...action }) => (
              <button
                className={action.danger ? "danger-action" : ""}
                key={action.label}
                onClick={() => handleActionClick(action, actionMenu.user)}
                title={`${action.label} - chưa có API BE`}
              >
                <Icon size={15} />
                {action.label}
              </button>
            ))}
          </div>
        </div>
      ) : null}
    </div>
  );
}
