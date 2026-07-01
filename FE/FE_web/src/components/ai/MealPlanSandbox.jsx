import { useState } from "react";
import { CalendarDays, Wand2 } from "lucide-react";
import { mealPlanRows } from "../../data/mockData.js";

export default function MealPlanSandbox() {
  const [generated, setGenerated] = useState(false);

  return (
    <div className="page-stack">
      <div className="page-toolbar">
        <div>
          <p className="eyebrow">AI Sandbox</p>
          <h2>Meal Plan Sandbox</h2>
          <p>Test sinh kế hoạch ăn uống nhiều ngày theo calorie target, diet preference và allergy safety.</p>
        </div>
      </div>

      <section className="ai-sandbox-layout">
        <form className="panel ai-sandbox-form" onSubmit={(event) => { event.preventDefault(); setGenerated(true); }}>
          <div className="form-grid">
            <label>User ID<input defaultValue="marcus" /></label>
            <label>Number of days<input type="number" defaultValue="3" /></label>
            <label>Meals per day<input type="number" defaultValue="4" /></label>
            <label>Target calories per day<input type="number" defaultValue="1800" /></label>
            <label>Diet preference<select defaultValue="High protein"><option>Low carb</option><option>High protein</option><option>Vegetarian</option><option>Keto</option><option>Mediterranean</option></select></label>
            <label>Allergies<input defaultValue="Sữa" /></label>
          </div>
          <button className="primary-btn" type="submit"><Wand2 size={16} /> Sinh meal plan</button>
        </form>

        <section className="panel">
          <div className="panel-heading">
            <h2><CalendarDays size={20} /> Meal plan output</h2>
            <span className="chip active">3 ngày</span>
          </div>
          {!generated ? <div className="empty-state">Chạy sandbox để xem bảng meal plan được tạo.</div> : (
            <div className="table-scroll compact-table-scroll">
              <table className="data-table meal-plan-table">
                <thead><tr><th>Day</th><th>Breakfast</th><th>Lunch</th><th>Dinner</th><th>Snack</th><th>Calories</th><th>Protein</th><th>Carbs</th><th>Fat</th><th>Status</th></tr></thead>
                <tbody>
                  {mealPlanRows.map((row) => (
                    <tr key={row.day}>
                      <td><strong>{row.day}</strong></td>
                      <td>{row.breakfast}</td>
                      <td>{row.lunch}</td>
                      <td>{row.dinner}</td>
                      <td>{row.snack}</td>
                      <td>{row.calories}</td>
                      <td>{row.protein}g</td>
                      <td>{row.carbs}g</td>
                      <td>{row.fat}g</td>
                      <td><span className={`safety-badge ${row.status === "Đạt mục tiêu" ? "ok" : "warning"}`}>{row.status}</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </section>
    </div>
  );
}
