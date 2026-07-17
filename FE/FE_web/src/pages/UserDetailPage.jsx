import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { Activity, AlertTriangle, Heart, Save, Target, Trash2, UserCircle, Utensils } from "lucide-react";
import {
  deleteUser,
  getAllergies,
  getDietPreferences,
  getFavorites,
  getFoodLogs,
  getHealthProfile,
  getNutritionGoal,
  getUser,
  optionalResource,
  updateUser
} from "../api/userManagement.js";

function initials(name = "") {
  return name.split(/\s+/).filter(Boolean).slice(-2).map((part) => part[0]).join("").toUpperCase() || "U";
}

function formatDateTime(value) {
  if (!value) return "—";
  return new Intl.DateTimeFormat("vi-VN", { dateStyle: "medium", timeStyle: "short" }).format(new Date(value));
}

const mealLabels = { BREAKFAST: "Bữa sáng", LUNCH: "Bữa trưa", DINNER: "Bữa tối", SNACK: "Bữa phụ" };
const severityLabels = { LOW: "Thấp", MEDIUM: "Trung bình", HIGH: "Cao" };
const activityLabels = { SEDENTARY: "Ít vận động", LIGHT: "Nhẹ", MODERATE: "Vừa", ACTIVE: "Năng động", VERY_ACTIVE: "Rất năng động" };

export default function UserDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [form, setForm] = useState({ fullName: "", email: "", dob: "", gender: "OTHER" });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  async function load() {
    setLoading(true);
    setError("");
    try {
      const user = await getUser(id);
      const [healthProfile, nutritionGoal, dietPreferences, allergies, favorites, foodLogs] = await Promise.all([
        optionalResource(() => getHealthProfile(id)),
        optionalResource(() => getNutritionGoal(id)),
        getDietPreferences(id),
        getAllergies(id),
        getFavorites(id),
        getFoodLogs(id, { page: 0, size: 5, sort: "logDate,desc" })
      ]);
      setData({ user, healthProfile, nutritionGoal, dietPreferences, allergies, favorites, foodLogs });
      setForm({ fullName: user.fullName || "", email: user.email || "", dob: user.dob || "", gender: user.gender || "OTHER" });
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, [id]);

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
    setSuccess("");
  }

  async function handleSave(event) {
    event.preventDefault();
    setSaving(true);
    setError("");
    setSuccess("");
    try {
      const user = await updateUser(id, {
        fullName: form.fullName.trim(),
        email: form.email.trim().toLowerCase(),
        dob: form.dob || null,
        gender: form.gender
      });
      setData((current) => ({ ...current, user }));
      setSuccess("Đã cập nhật hồ sơ người dùng.");
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete() {
    if (!window.confirm(`Xóa vĩnh viễn hồ sơ user #${id}?`)) return;
    try {
      await deleteUser(id);
      navigate("/users", { replace: true });
    } catch (requestError) {
      setError(requestError.message);
    }
  }

  if (loading) return <div className="panel">Đang tải hồ sơ và dữ liệu liên quan...</div>;
  if (!data) return <div className="page-stack"><section className="warning-panel"><div><strong>Không tải được hồ sơ</strong><p>{error}</p><button className="ghost-btn" onClick={load}>Thử lại</button></div></section><Link className="ghost-btn" to="/users">Quay lại danh sách</Link></div>;

  const { user, healthProfile, nutritionGoal, dietPreferences, allergies, favorites, foodLogs } = data;

  return (
    <div className="page-stack">
      <div className="profile-hero user-detail-hero">
        <div className="large-avatar">{initials(user.fullName)}</div>
        <div><p className="eyebrow">User Service · #{user.userId}</p><h2>{user.fullName}</h2><span>{user.email}</span><div className="chip-row profile-badges"><span className="chip active">{user.gender}</span><span className="chip">Auth #{user.authAccountId ?? "chưa liên kết"}</span></div></div>
        <Link className="ghost-btn" to="/users">Quay lại danh sách</Link>
      </div>

      {error ? <section className="warning-panel"><AlertTriangle size={20} /><div><strong>Yêu cầu thất bại</strong><p>{error}</p></div></section> : null}
      {success ? <div className="success-note">{success}</div> : null}

      <section className="dashboard-grid">
        <form className="panel span-2" onSubmit={handleSave}>
          <h2><UserCircle size={18} /> Thông tin hồ sơ</h2>
          <div className="filter-grid">
            <label>Họ và tên<input value={form.fullName} onChange={(event) => updateField("fullName", event.target.value)} required /></label>
            <label>Email<input type="email" value={form.email} onChange={(event) => updateField("email", event.target.value)} required /></label>
            <label>Ngày sinh<input type="date" value={form.dob} onChange={(event) => updateField("dob", event.target.value)} /></label>
            <label>Giới tính<select value={form.gender} onChange={(event) => updateField("gender", event.target.value)}><option value="MALE">Nam</option><option value="FEMALE">Nữ</option><option value="OTHER">Khác</option></select></label>
          </div>
          <dl className="info-list account-info-grid"><dt>User ID</dt><dd>{user.userId}</dd><dt>Auth Account ID</dt><dd>{user.authAccountId ?? "Chưa liên kết"}</dd><dt>Ngày tạo</dt><dd>{formatDateTime(user.createdAt)}</dd><dt>Cập nhật cuối</dt><dd>{formatDateTime(user.updatedAt)}</dd></dl>
          <div className="form-actions"><button className="primary-btn" type="submit" disabled={saving}><Save size={16} /> {saving ? "Đang lưu..." : "Lưu thay đổi"}</button><button className="danger-link" type="button" onClick={handleDelete}><Trash2 size={16} /> Xóa hồ sơ</button></div>
        </form>

        <article className="panel">
          <h2><Activity size={18} /> Hồ sơ sức khỏe</h2>
          {healthProfile ? <dl className="info-list"><dt>Chiều cao</dt><dd>{healthProfile.height} cm</dd><dt>Cân nặng</dt><dd>{healthProfile.weight} kg</dd><dt>BMI</dt><dd>{healthProfile.bmi}</dd><dt>Mức vận động</dt><dd>{activityLabels[healthProfile.activityLevel] || healthProfile.activityLevel}</dd></dl> : <p>Chưa có hồ sơ sức khỏe.</p>}
        </article>
      </section>

      <section className="dashboard-grid">
        <article className="panel">
          <h2><Target size={18} /> Mục tiêu dinh dưỡng</h2>
          {nutritionGoal ? <dl className="info-list"><dt>Calories</dt><dd>{nutritionGoal.calories} kcal</dd><dt>Protein</dt><dd>{nutritionGoal.protein} g</dd><dt>Carbs</dt><dd>{nutritionGoal.carbs} g</dd><dt>Fat</dt><dd>{nutritionGoal.fat} g</dd></dl> : <p>Chưa có mục tiêu dinh dưỡng.</p>}
        </article>
        <article className="panel">
          <h2><Heart size={18} /> Sở thích và dị ứng</h2>
          <dl className="info-list"><dt>Chế độ ăn</dt><dd>{dietPreferences.length ? dietPreferences.map((item) => item.dietType).join(", ") : "Chưa có"}</dd><dt>Dị ứng</dt><dd>{allergies.length ? allergies.map((item) => `Allergen #${item.allergenId} (${severityLabels[item.severity] || item.severity})`).join(", ") : "Chưa có"}</dd></dl>
        </article>
        <article className="panel">
          <h2><Utensils size={18} /> Hoạt động ăn uống</h2>
          <dl className="info-list"><dt>Công thức yêu thích</dt><dd>{favorites.length}</dd><dt>Tổng food log</dt><dd>{foodLogs.totalElements || 0}</dd></dl>
        </article>
      </section>

      <section className="panel">
        <h2>Food log gần nhất</h2>
        <table className="data-table"><thead><tr><th>Ngày</th><th>Bữa</th><th>Recipe ID</th><th>Số lượng</th></tr></thead><tbody>
          {!foodLogs.content?.length ? <tr><td colSpan="4">Chưa có food log.</td></tr> : foodLogs.content.map((log) => <tr key={log.logId}><td>{log.logDate}</td><td>{mealLabels[log.mealType] || log.mealType}</td><td>#{log.recipeId}</td><td>{log.quantity}</td></tr>)}
        </tbody></table>
      </section>
    </div>
  );
}
