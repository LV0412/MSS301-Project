import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { Download, Eye, Search, Trash2, UserCheck, UserPlus, Users, UserX } from "lucide-react";
import { deleteUser, getUsers } from "../api/userManagement.js";

const PAGE_SIZE = 10;

function initials(name = "") {
  return name.split(/\s+/).filter(Boolean).slice(-2).map((part) => part[0]).join("").toUpperCase() || "U";
}

function formatDate(value) {
  if (!value) return "—";
  return new Intl.DateTimeFormat("vi-VN", { dateStyle: "short", timeStyle: "short" }).format(new Date(value));
}

function genderLabel(value) {
  return { MALE: "Nam", FEMALE: "Nữ", OTHER: "Khác" }[value] || "—";
}

export default function UsersPage() {
  const [page, setPage] = useState(0);
  const [data, setData] = useState({ content: [], totalElements: 0, totalPages: 0, number: 0 });
  const [search, setSearch] = useState("");
  const [gender, setGender] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  async function loadUsers(targetPage = page) {
    setLoading(true);
    setError("");
    try {
      const response = await getUsers({ page: targetPage, size: PAGE_SIZE, sort: "createdAt,desc" });
      setData(response);
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadUsers(page);
  }, [page]);

  const rows = useMemo(() => {
    const keyword = search.trim().toLowerCase();
    return (data.content || []).filter((user) => {
      const matchesSearch = !keyword || user.fullName?.toLowerCase().includes(keyword) || user.email?.toLowerCase().includes(keyword) || String(user.userId).includes(keyword);
      return matchesSearch && (!gender || user.gender === gender);
    });
  }, [data.content, search, gender]);

  const linkedCount = (data.content || []).filter((user) => user.authAccountId != null).length;

  async function handleDelete(user) {
    if (!window.confirm(`Xóa hồ sơ ${user.fullName} (#${user.userId})? Hành động này không thể hoàn tác.`)) return;
    try {
      await deleteUser(user.userId);
      await loadUsers(page);
    } catch (requestError) {
      setError(requestError.message);
    }
  }

  function exportCurrentPage() {
    const header = ["userId", "authAccountId", "fullName", "email", "gender", "dob", "createdAt"];
    const csv = [header, ...rows.map((user) => header.map((key) => user[key] ?? ""))]
      .map((row) => row.map((value) => `"${String(value).replaceAll('"', '""')}"`).join(","))
      .join("\n");
    const link = document.createElement("a");
    link.href = URL.createObjectURL(new Blob([`\uFEFF${csv}`], { type: "text/csv;charset=utf-8" }));
    link.download = `users-page-${page + 1}.csv`;
    link.click();
    URL.revokeObjectURL(link.href);
  }

  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">User Service</p>
          <h2>Quản lý người dùng</h2>
          <p>Dữ liệu được tải trực tiếp từ API User Service qua API Gateway.</p>
        </div>
        <div className="button-row">
          <Link className="primary-btn" to="/users/new"><UserPlus size={16} /> Tạo hồ sơ</Link>
          <button className="ghost-btn" onClick={exportCurrentPage} disabled={!rows.length}><Download size={16} /> Xuất trang hiện tại</button>
        </div>
      </div>

      <section className="kpi-grid overview-main-kpis">
        <article className="kpi-card compact-kpi"><div className="kpi-icon"><Users size={19} /></div><span>Tổng hồ sơ</span><strong>{data.totalElements ?? 0}</strong></article>
        <article className="kpi-card compact-kpi"><div className="kpi-icon"><UserCheck size={19} /></div><span>Đã liên kết Auth (trang này)</span><strong>{linkedCount}</strong></article>
        <article className="kpi-card compact-kpi"><div className="kpi-icon"><UserX size={19} /></div><span>Chưa liên kết (trang này)</span><strong>{(data.content || []).length - linkedCount}</strong></article>
      </section>

      <section className="panel">
        <div className="filter-grid user-management-filter-grid">
          <label>Giới tính
            <select value={gender} onChange={(event) => setGender(event.target.value)}>
              <option value="">Tất cả</option><option value="MALE">Nam</option><option value="FEMALE">Nữ</option><option value="OTHER">Khác</option>
            </select>
          </label>
          <label>Tìm trong trang hiện tại
            <div className="field"><Search size={15} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Tên, email hoặc user ID..." /></div>
          </label>
          <button className="ghost-btn" onClick={() => { setSearch(""); setGender(""); }}>Xóa bộ lọc</button>
        </div>
      </section>

      {error ? <section className="warning-panel"><div><strong>Không tải được dữ liệu</strong><p>{error}</p><button className="ghost-btn" onClick={() => loadUsers(page)}>Thử lại</button></div></section> : null}

      <section className="panel">
        <table className="data-table user-table">
          <thead><tr><th>Người dùng</th><th>Email</th><th>Giới tính</th><th>Ngày sinh</th><th>Liên kết Auth</th><th>Ngày tạo</th><th>Hành động</th></tr></thead>
          <tbody>
            {loading ? <tr><td colSpan="7">Đang tải người dùng...</td></tr> : null}
            {!loading && !rows.length ? <tr><td colSpan="7">Không có người dùng phù hợp.</td></tr> : null}
            {!loading && rows.map((user) => (
              <tr key={user.userId}>
                <td className="person-cell"><span className="avatar-xs">{initials(user.fullName)}</span><div><strong>{user.fullName}</strong><small>User ID: {user.userId}</small></div></td>
                <td>{user.email}</td><td>{genderLabel(user.gender)}</td><td>{user.dob || "—"}</td>
                <td>{user.authAccountId != null ? <span className="chip active">Account #{user.authAccountId}</span> : <span className="chip">Chưa liên kết</span>}</td>
                <td>{formatDate(user.createdAt)}</td>
                <td className="actions-cell">
                  <Link className="icon-link" to={`/users/${user.userId}`} title="Xem và chỉnh sửa"><Eye size={17} /></Link>
                  <button className="icon-link" onClick={() => handleDelete(user)} title="Xóa hồ sơ"><Trash2 size={17} /></button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="table-footer">
          <span>Trang {data.totalPages ? page + 1 : 0}/{data.totalPages || 0} · {data.totalElements || 0} hồ sơ</span>
          <div className="pagination">
            <button disabled={loading || page === 0} onClick={() => setPage((value) => value - 1)}>‹</button>
            <button className="active" disabled>{page + 1}</button>
            <button disabled={loading || page + 1 >= (data.totalPages || 0)} onClick={() => setPage((value) => value + 1)}>›</button>
          </div>
        </div>
      </section>
    </div>
  );
}
