import { Download, FileText, Sparkles } from "lucide-react";
import { Bar, BarChart, CartesianGrid, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { allergyDistribution, goalDistribution, growthData, ratingDistribution, reportKpis } from "../data/mockData.js";

export default function ReportsPage() {
  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div><p className="eyebrow">Analytics Center</p><h2>Báo cáo hệ thống</h2></div>
        <div className="button-row"><button className="ghost-btn"><Download size={16} /> Xuất CSV</button><button className="primary-btn"><FileText size={16} /> Xuất PDF</button></div>
      </div>

      <section className="filter-bar">
        <select><option>30 ngày gần nhất</option><option>Quý này</option></select>
        <select><option>Tất cả quốc gia</option></select>
        <select><option>Mọi chế độ ăn</option></select>
        <select><option>Tình trạng sức khỏe</option></select>
        <select><option>Nhóm tuổi</option></select>
        <select><option>Loại mục tiêu</option></select>
      </section>

      <section className="kpi-grid three">
        {reportKpis.map((item, index) => (
          <article className={`report-card ${index === 1 ? "highlight" : ""}`} key={item.label}>
            <span>{item.label}</span>
            <strong>{item.value}</strong>
            <p>{item.note}</p>
          </article>
        ))}
      </section>

      <section className="dashboard-grid">
        <article className="panel span-2">
          <h2>Tỷ lệ đạt mục tiêu theo thời gian</h2>
          <ResponsiveContainer width="100%" height={270}>
            <LineChart data={growthData}>
              <CartesianGrid stroke="#e7eadc" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="retention" stroke="#536b58" strokeWidth={3} />
              <Line type="monotone" dataKey="premium" stroke="#8a6a46" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </article>
        <article className="panel">
          <h2>Chế độ ăn phổ biến</h2>
          <ResponsiveContainer width="100%" height={270}>
            <BarChart data={goalDistribution}>
              <XAxis dataKey="name" />
              <YAxis hide />
              <Tooltip />
              <Bar dataKey="value" fill="#8da290" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </article>
      </section>

      <section className="panel">
        <h2>Phân tích đánh giá công thức</h2>
        <div className="rating-list">
          {ratingDistribution.map((item) => (
            <div className="rating-row" key={item.label}>
              <strong>{item.label}</strong>
              <div className="meter"><span style={{ width: `${item.value}%` }} /></div>
              <b>{item.value}%</b>
            </div>
          ))}
        </div>
      </section>

      <section className="report-insight">
        <div>
          <span className="eyebrow">AI Insight</span>
          <h2>Xu hướng Keto đang tăng ở khu vực Đông Bắc</h2>
          <p>Recommendation engine đề xuất ưu tiên chiến dịch công thức low-carb mùa hè. Tương tác với nhóm nguyên liệu "Almond Crust" tăng 45% trong tháng này.</p>
          <button className="ghost-btn">Cập nhật chiến lược marketing</button>
        </div>
        <img src="https://images.unsplash.com/photo-1543353071-873f17a7a088?auto=format&fit=crop&w=520&q=80" alt="Healthy ingredients" />
      </section>

      <section className="panel">
        <h2>Sự cố an toàn dị ứng</h2>
        <div className="allergy-grid">
          {allergyDistribution.map((item) => <span key={item.name}><Sparkles size={14} /> {item.name}: {item.value}%</span>)}
        </div>
      </section>
    </div>
  );
}
