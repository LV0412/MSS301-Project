import { useEffect, useMemo, useState } from "react";
import { Link, useLocation, useParams } from "react-router-dom";
import { AlertTriangle, ArrowLeft, CalendarDays, CheckCircle2, Mail, ShieldCheck, UserCircle } from "lucide-react";
import { getInternalUser, getUsers } from "../api/userManagement.js";

function initials(name = "") {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .slice(-2)
    .map((part) => part[0])
    .join("")
    .toUpperCase() || "U";
}

function genderLabel(value) {
  return { MALE: "Nam", FEMALE: "Nữ", OTHER: "Khác" }[value] || "Chưa có";
}

function formatDate(value, withTime = false) {
  if (!value) return "Chưa có";
  return new Intl.DateTimeFormat("vi-VN", withTime
    ? { dateStyle: "medium", timeStyle: "short" }
    : { day: "2-digit", month: "2-digit", year: "numeric" }
  ).format(new Date(value));
}

function getErrorMessage(error) {
  if (error?.status === 401) return "Phiên đăng nhập không hợp lệ hoặc gateway chưa xác thực được token admin.";
  if (error?.status === 404) return "Không tìm thấy hồ sơ người dùng.";
  return error?.message || "Không tải được hồ sơ người dùng.";
}

export default function UserDetailPage() {
  const { id } = useParams();
  const location = useLocation();
  const listUser = location.state?.user || null;
  const [listLookupUser, setListLookupUser] = useState(null);
  const [internalUser, setInternalUser] = useState(null);
  const [loading, setLoading] = useState(!listUser);
  const [error, setError] = useState("");

  async function loadUser() {
    setLoading(true);
    setError("");
    try {
      const [internalResponse, usersResponse] = await Promise.all([
        getInternalUser(id),
        listUser ? Promise.resolve(null) : getUsers({ page: 0, size: 200, sort: "createdAt,desc" })
      ]);
      setInternalUser(internalResponse);
      if (usersResponse?.content) {
        const matchedUser = usersResponse.content.find((item) => String(item.userId) === String(id));
        setListLookupUser(matchedUser || null);
      }
    } catch (requestError) {
      setError(getErrorMessage(requestError));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadUser();
  }, [id]);

  const sourceUser = listUser || listLookupUser;
  const user = useMemo(() => ({
    userId: sourceUser?.userId ?? internalUser?.userId ?? id,
    authAccountId: sourceUser?.authAccountId ?? null,
    email: sourceUser?.email ?? "",
    fullName: sourceUser?.fullName ?? internalUser?.fullName ?? "",
    dob: sourceUser?.dob ?? internalUser?.dob ?? "",
    gender: sourceUser?.gender ?? internalUser?.gender ?? "",
    createdAt: sourceUser?.createdAt ?? "",
    updatedAt: sourceUser?.updatedAt ?? ""
  }), [id, internalUser, sourceUser]);

  const linkedAuth = user.authAccountId != null;

  if (loading && !listUser) {
    return <div className="panel">Đang tải hồ sơ cơ bản...</div>;
  }

  if (!user.fullName && error) {
    return (
      <div className="page-stack">
        <section className="warning-panel">
          <AlertTriangle size={20} />
          <div>
            <strong>Không tải được hồ sơ người dùng</strong>
            <p>{error}</p>
            <button className="ghost-btn" type="button" onClick={loadUser}>Thử lại</button>
          </div>
        </section>
        <Link className="ghost-btn" to="/users"><ArrowLeft size={16} /> Quay lại danh sách</Link>
      </div>
    );
  }

  return (
    <div className="page-stack user-basic-profile">
      <div className="user-profile-hero">
        <div className="large-avatar">{initials(user.fullName)}</div>
        <div className="user-profile-main">
          <p className="eyebrow">Hồ sơ người dùng</p>
          <h2>{user.fullName || `Người dùng #${user.userId}`}</h2>
          <span>{user.email || "Chưa có email"}</span>
          <div className="chip-row profile-badges">
            <span className="chip active">User #{user.userId}</span>
            <span className="chip">{genderLabel(user.gender)}</span>
            <span className={linkedAuth ? "chip active" : "chip"}>{linkedAuth ? "Đã liên kết Auth" : "Chưa liên kết Auth"}</span>
          </div>
        </div>
        <Link className="ghost-btn" to="/users"><ArrowLeft size={16} /> Quay lại</Link>
      </div>

      {error ? (
        <section className="warning-panel mini">
          <AlertTriangle size={18} />
          <div>
            <strong>Không đồng bộ được toàn bộ thông tin</strong>
            <p>{error}</p>
          </div>
        </section>
      ) : null}

      <section className="user-profile-grid">
        <article className="panel user-profile-card span-2">
          <div className="panel-heading">
            <div>
              <h2><UserCircle size={18} /> Thông tin cơ bản</h2>
              <p>Thông tin phục vụ xác minh tài khoản và hỗ trợ người dùng.</p>
            </div>
          </div>
          <dl className="user-profile-fields">
            <div>
              <dt>Họ và tên</dt>
              <dd>{user.fullName || "Chưa có"}</dd>
            </div>
            <div>
              <dt>Email</dt>
              <dd>{user.email || "Chưa có"}</dd>
            </div>
            <div>
              <dt>Giới tính</dt>
              <dd>{genderLabel(user.gender)}</dd>
            </div>
            <div>
              <dt>Ngày sinh</dt>
              <dd>{user.dob || "Chưa có"}</dd>
            </div>
          </dl>
        </article>

        <article className="panel user-profile-side-card">
          <div className="kpi-icon"><ShieldCheck size={18} /></div>
          <h2>Trạng thái tài khoản</h2>
          <strong>{linkedAuth ? "Đã liên kết" : "Hồ sơ độc lập"}</strong>
          <p>{linkedAuth ? `Auth Account #${user.authAccountId}` : "Chưa có tài khoản đăng nhập liên kết."}</p>
        </article>

        <article className="panel user-profile-side-card">
          <div className="kpi-icon"><Mail size={18} /></div>
          <h2>Email hỗ trợ</h2>
          <strong>{user.email || "Chưa có email"}</strong>
          <p>Dùng email này cho các thao tác gửi OTP hoặc đặt lại mật khẩu.</p>
        </article>

        <article className="panel user-profile-card span-2">
          <div className="panel-heading">
            <div>
              <h2><CalendarDays size={18} /> Mốc thời gian</h2>
              <p>Theo dõi thời điểm hồ sơ được tạo và cập nhật gần nhất.</p>
            </div>
          </div>
          <div className="user-profile-timeline">
            <div>
              <span><CheckCircle2 size={16} /> Ngày tạo</span>
              <strong>{formatDate(user.createdAt, true)}</strong>
            </div>
            <div>
              <span><CheckCircle2 size={16} /> Cập nhật cuối</span>
              <strong>{formatDate(user.updatedAt, true)}</strong>
            </div>
          </div>
        </article>
      </section>
    </div>
  );
}
