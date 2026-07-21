import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { CalendarDays, Download, Eye, KeyRound, MailCheck, MoreVertical, RefreshCw, Search, ShieldAlert, UserCheck, UserPlus, Users, UserX, X } from "lucide-react";
import { getUsers, requestPasswordReset, resendVerificationOtp } from "../api/userManagement.js";

const PAGE_SIZE = 10;

function initials(name = "") {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .slice(-2)
    .map((part) => part[0])
    .join("")
    .toUpperCase() || "U";
}

function formatDate(value, withTime = false) {
  if (!value) return "Chưa có";
  return new Intl.DateTimeFormat("vi-VN", withTime
    ? { dateStyle: "short", timeStyle: "short" }
    : { day: "2-digit", month: "2-digit", year: "numeric" }
  ).format(new Date(value));
}

function genderLabel(value) {
  return { MALE: "Nam", FEMALE: "Nữ", OTHER: "Khác" }[value] || "Chưa có";
}

function getErrorMessage(error) {
  if (error?.status === 401) {
    return "API Gateway đang từ chối phiên đăng nhập. Kiểm tra JWT_SECRET của api-gateway-service phải trùng với auth-service, đồng thời token admin còn hợp lệ.";
  }
  if (error?.status === 403) {
    return "Tài khoản hiện tại không có quyền truy cập danh sách người dùng.";
  }
  return error?.message || "Không tải được dữ liệu người dùng.";
}

export default function UsersPage() {
  const [page, setPage] = useState(0);
  const [data, setData] = useState({ content: [], totalElements: 0, totalPages: 0, number: 0 });
  const [search, setSearch] = useState("");
  const [gender, setGender] = useState("");
  const [dobStatus, setDobStatus] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [actionMenu, setActionMenu] = useState(null);
  const [actionLoading, setActionLoading] = useState("");
  const [notice, setNotice] = useState(null);

  async function loadUsers(targetPage = page) {
    setLoading(true);
    setError("");
    try {
      const response = await getUsers({ page: targetPage, size: PAGE_SIZE, sort: "createdAt,desc" });
      setData(response || { content: [], totalElements: 0, totalPages: 0, number: targetPage });
    } catch (requestError) {
      setError(getErrorMessage(requestError));
      setData({ content: [], totalElements: 0, totalPages: 0, number: targetPage });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadUsers(page);
  }, [page]);

  const currentPageRows = data.content || [];
  const rows = useMemo(() => {
    const keyword = search.trim().toLowerCase();
    return currentPageRows.filter((user) => {
      const matchesSearch = !keyword
        || user.fullName?.toLowerCase().includes(keyword)
        || user.email?.toLowerCase().includes(keyword)
        || String(user.userId).includes(keyword)
        || String(user.authAccountId || "").includes(keyword);
      const matchesGender = !gender || user.gender === gender;
      const matchesDob = !dobStatus
        || (dobStatus === "hasDob" && Boolean(user.dob))
        || (dobStatus === "missingDob" && !user.dob);
      return matchesSearch && matchesGender && matchesDob;
    });
  }, [currentPageRows, dobStatus, gender, search]);

  const linkedCount = currentPageRows.filter((user) => user.authAccountId != null).length;
  const hasDobCount = currentPageRows.filter((user) => Boolean(user.dob)).length;

  function clearFilters() {
    setSearch("");
    setGender("");
    setDobStatus("");
  }

  function exportCurrentPage() {
    const header = ["userId", "authAccountId", "fullName", "email", "gender", "dob", "createdAt", "updatedAt"];
    const csv = [header, ...rows.map((user) => header.map((key) => user[key] ?? ""))]
      .map((row) => row.map((value) => `"${String(value).replaceAll('"', '""')}"`).join(","))
      .join("\n");
    const link = document.createElement("a");
    link.href = URL.createObjectURL(new Blob([`\uFEFF${csv}`], { type: "text/csv;charset=utf-8" }));
    link.download = `users-page-${page + 1}.csv`;
    link.click();
    URL.revokeObjectURL(link.href);
  }

  function openActionMenu(event, user) {
    const rect = event.currentTarget.getBoundingClientRect();
    const menuWidth = 270;
    const left = Math.min(rect.right - menuWidth, window.innerWidth - menuWidth - 16);
    setActionMenu({
      user,
      top: rect.bottom + 8,
      left: Math.max(16, left)
    });
  }

  async function runEmailAction(type, user) {
    if (!user.email) {
      setNotice({ type: "error", message: "Hồ sơ này chưa có email nên không thể gửi yêu cầu." });
      return;
    }

    setActionLoading(`${type}-${user.userId}`);
    setNotice(null);
    try {
      const response = type === "otp"
        ? await resendVerificationOtp(user.email)
        : await requestPasswordReset(user.email);
      setNotice({
        type: "success",
        message: response?.message || (type === "otp" ? "Đã gửi lại OTP xác minh email." : "Đã gửi hướng dẫn đặt lại mật khẩu.")
      });
      setActionMenu(null);
    } catch (requestError) {
      setNotice({ type: "error", message: requestError.message || "Không thực hiện được hành động." });
    } finally {
      setActionLoading("");
    }
  }

  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">User Service</p>
          <h2>Quản lý người dùng</h2>
          <p>Danh sách được tải trực tiếp từ `GET /api/v1/users`. Màn CSKH chỉ hiển thị thông tin hồ sơ cơ bản, không hiển thị dữ liệu sức khỏe, meal plan hoặc lịch sử AI.</p>
        </div>
        <div className="button-row">
          <Link className="primary-btn" to="/users/new"><UserPlus size={16} /> Mời người dùng</Link>
          <button className="ghost-btn" type="button" onClick={exportCurrentPage} disabled={!rows.length}><Download size={16} /> Xuất trang</button>
          <button className="ghost-btn" type="button" onClick={() => loadUsers(page)} disabled={loading}><RefreshCw size={16} /> Làm mới</button>
        </div>
      </div>

      <section className="kpi-grid overview-main-kpis">
        <article className="kpi-card compact-kpi">
          <div className="kpi-icon"><Users size={19} /></div>
          <span>Tổng hồ sơ</span>
          <strong>{data.totalElements ?? 0}</strong>
          <small>Theo User Service</small>
        </article>
        <article className="kpi-card compact-kpi">
          <div className="kpi-icon"><UserCheck size={19} /></div>
          <span>Đã liên kết Auth</span>
          <strong>{linkedCount}</strong>
          <small>Trong trang hiện tại</small>
        </article>
        <article className="kpi-card compact-kpi">
          <div className="kpi-icon"><UserX size={19} /></div>
          <span>Chưa liên kết</span>
          <strong>{currentPageRows.length - linkedCount}</strong>
          <small>Trong trang hiện tại</small>
        </article>
        <article className="kpi-card compact-kpi">
          <div className="kpi-icon"><CalendarDays size={19} /></div>
          <span>Có ngày sinh</span>
          <strong>{hasDobCount}</strong>
          <small>Trong trang hiện tại</small>
        </article>
      </section>

      <section className="panel">
        <div className="filter-grid user-management-filter-grid">
          <label>Tìm trong trang hiện tại
            <div className="field">
              <Search size={15} />
              <input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Tên, email, user ID hoặc auth ID..." />
            </div>
          </label>
          <label>Giới tính
            <select value={gender} onChange={(event) => setGender(event.target.value)}>
              <option value="">Tất cả</option>
              <option value="MALE">Nam</option>
              <option value="FEMALE">Nữ</option>
              <option value="OTHER">Khác</option>
            </select>
          </label>
          <label>Ngày sinh
            <select value={dobStatus} onChange={(event) => setDobStatus(event.target.value)}>
              <option value="">Tất cả</option>
              <option value="hasDob">Đã có ngày sinh</option>
              <option value="missingDob">Chưa có ngày sinh</option>
            </select>
          </label>
          <button className="ghost-btn" type="button" onClick={clearFilters}>Xóa bộ lọc</button>
        </div>
      </section>

      {error ? (
        <section className="warning-panel">
          <ShieldAlert size={20} />
          <div>
            <strong>Không tải được dữ liệu User Service</strong>
            <p>{error}</p>
            <button className="ghost-btn" type="button" onClick={() => loadUsers(page)}>Thử lại</button>
          </div>
        </section>
      ) : null}

      {notice ? (
        <section className={notice.type === "success" ? "success-note" : "warning-panel mini"}>
          <span>{notice.message}</span>
        </section>
      ) : null}

      <section className="panel">
        <div className="table-scroll">
          <table className="data-table user-table">
            <thead>
              <tr>
                <th>Người dùng</th>
                <th>Email</th>
                <th>Giới tính</th>
                <th>Ngày sinh</th>
                <th>Liên kết Auth</th>
                <th>Ngày tạo</th>
                <th>Cập nhật</th>
                <th>Hành động</th>
              </tr>
            </thead>
            <tbody>
              {loading ? <tr><td colSpan="8">Đang tải người dùng từ User Service...</td></tr> : null}
              {!loading && !rows.length ? <tr><td colSpan="8">Không có người dùng phù hợp.</td></tr> : null}
              {!loading && rows.map((user) => (
                <tr key={user.userId}>
                  <td className="person-cell">
                    <span className="avatar-xs">{initials(user.fullName)}</span>
                    <div>
                      <strong>{user.fullName || "Chưa có tên"}</strong>
                      <small>User ID: {user.userId}</small>
                    </div>
                  </td>
                  <td>{user.email}</td>
                  <td>{genderLabel(user.gender)}</td>
                  <td>{user.dob || "Chưa có"}</td>
                  <td>
                    {user.authAccountId != null
                      ? <span className="chip active">Account #{user.authAccountId}</span>
                      : <span className="chip">Chưa liên kết</span>}
                  </td>
                  <td>{formatDate(user.createdAt, true)}</td>
                  <td>{formatDate(user.updatedAt, true)}</td>
                  <td className="actions-cell">
                    <Link
                      className="icon-link"
                      to={`/users/${user.userId}`}
                      state={{ user }}
                      title="Xem hồ sơ cơ bản"
                      aria-label="Xem hồ sơ cơ bản"
                    >
                      <Eye size={17} />
                    </Link>
                    <button
                      className="icon-link"
                      type="button"
                      onClick={(event) => openActionMenu(event, user)}
                      title="Mở hành động"
                      aria-label="Mở hành động"
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
          <span>Trang {data.totalPages ? page + 1 : 0}/{data.totalPages || 0} · {data.totalElements || 0} hồ sơ</span>
          <div className="pagination">
            <button disabled={loading || page === 0} onClick={() => setPage((value) => Math.max(0, value - 1))}>‹</button>
            <button className="active" disabled>{page + 1}</button>
            <button disabled={loading || page + 1 >= (data.totalPages || 0)} onClick={() => setPage((value) => value + 1)}>›</button>
          </div>
        </div>
      </section>

      {actionMenu ? (
        <div className="floating-action-menu" style={{ top: actionMenu.top, left: actionMenu.left }}>
          <div className="floating-action-header">
            <strong>Hành động theo API</strong>
            <button type="button" onClick={() => setActionMenu(null)} aria-label="Đóng menu">
              <X size={15} />
            </button>
          </div>
          <Link
            to={`/users/${actionMenu.user.userId}`}
            state={{ user: actionMenu.user }}
            onClick={() => setActionMenu(null)}
          >
            <Eye size={16} />
            Xem hồ sơ cơ bản
          </Link>
          <button
            type="button"
            onClick={() => runEmailAction("otp", actionMenu.user)}
            disabled={actionLoading === `otp-${actionMenu.user.userId}`}
          >
            <MailCheck size={16} />
            {actionLoading === `otp-${actionMenu.user.userId}` ? "Đang gửi OTP..." : "Gửi lại OTP xác minh"}
          </button>
          <button
            type="button"
            onClick={() => runEmailAction("reset", actionMenu.user)}
            disabled={actionLoading === `reset-${actionMenu.user.userId}`}
          >
            <KeyRound size={16} />
            {actionLoading === `reset-${actionMenu.user.userId}` ? "Đang gửi email..." : "Gửi email đặt lại mật khẩu"}
          </button>
          <small>Không hiển thị khóa, mở khóa hoặc xóa vì BE chưa có API admin tương ứng.</small>
        </div>
      ) : null}
    </div>
  );
}
