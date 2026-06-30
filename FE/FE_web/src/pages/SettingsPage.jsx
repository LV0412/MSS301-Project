import { BadgeCheck, Bell, BrainCircuit, KeyRound, Lock, Save, ShieldAlert, Sparkles, UserCircle } from "lucide-react";

export default function SettingsPage() {
  return (
    <div className="settings-grid">
      <section className="form-card admin-profile-card">
        <h2><UserCircle size={18} /> Hồ sơ admin</h2>
        <label>Display name<input defaultValue="System Architect" /></label>
        <label>Email<input defaultValue="admin@nutrichef.ai" /></label>
        <button className="primary-btn"><Save size={16} /> Cập nhật hồ sơ</button>
      </section>

      <section className="form-card span-2">
        <div className="panel-heading"><div><h2><BrainCircuit size={18} /> Quy tắc gợi ý AI</h2><p>Điều chỉnh core logic của recipe suggestions.</p></div><Sparkles size={28} /></div>
        <div className="rule-grid">
          <label className="rule-card"><strong>Keto preference</strong><span>Ưu tiên fat cao, carb thấp khi phù hợp.</span><input type="checkbox" defaultChecked /></label>
          <label className="rule-card"><strong>Seasonal bias</strong><span>Đẩy nguyên liệu theo mùa và vùng địa lý.</span><input type="checkbox" defaultChecked /></label>
        </div>
        <label className="range-label">Strictness threshold<input type="range" defaultValue="55" /></label>
      </section>

      <section className="form-card">
        <h2><KeyRound size={18} /> API integrations</h2>
        <div className="integration-card active"><strong>USDA Database</strong><span>Active · Latency 24ms</span><BadgeCheck size={17} /></div>
        <div className="integration-card"><strong>OpenAI GPT-4</strong><span>Connected · Daily limit 82%</span></div>
        <button className="ghost-btn">Quản lý keys</button>
      </section>

      <section className="form-card">
        <h2><Lock size={18} /> Quản lý vai trò</h2>
        <div className="settings-list"><span>Super Admin <b>3 users</b></span><span>Nutritionist <b>12 users</b></span><span>Content Editor <b>8 users</b></span></div>
      </section>

      <section className="form-card">
        <h2><ShieldAlert size={18} /> Quy tắc an toàn dị ứng</h2>
        <div className="danger-box">Cảnh báo cross-contamination đang bật.</div>
        <button className="link-btn">Sửa safety matrix →</button>
      </section>

      <section className="form-card span-2">
        <h2><Bell size={18} /> Thông báo toàn cục</h2>
        <div className="toggle-row"><div><strong>User feedback alerts</strong><span>Báo khi user flag recipe sai.</span></div><input type="checkbox" defaultChecked /></div>
        <div className="toggle-row"><div><strong>Weekly system reports</strong><span>Tổng hợp performance và health trend.</span></div><input type="checkbox" defaultChecked /></div>
      </section>

      <section className="form-card">
        <h2>Quy tắc tính dinh dưỡng</h2>
        <p className="soft-copy">Chuẩn hóa macro theo khẩu phần 100g và làm tròn micronutrient theo ngưỡng an toàn.</p>
      </section>

      <section className="form-card">
        <h2>Quyền riêng tư dữ liệu</h2>
        <p className="soft-copy">Ẩn danh dữ liệu sức khỏe khi xuất báo cáo và không dùng PII trong retrieval sandbox.</p>
      </section>
    </div>
  );
}
