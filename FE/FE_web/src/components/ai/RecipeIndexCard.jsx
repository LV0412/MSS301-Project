import { DatabaseZap, RefreshCw, RotateCw } from "lucide-react";
import { recipeVectorIndex } from "../../data/mockData.js";

const indexRows = [
  ["Total recipes from Recipe Service", recipeVectorIndex.totalRecipes],
  ["Indexed recipes", recipeVectorIndex.indexedRecipes],
  ["Pending recipes", recipeVectorIndex.pendingRecipes],
  ["Failed embeddings", recipeVectorIndex.failedEmbeddings],
  ["Last sync time", recipeVectorIndex.lastSync]
];

export default function RecipeIndexCard() {
  return (
    <article className="panel recipe-index-card">
      <div className="panel-heading">
        <div>
          <h2><DatabaseZap size={20} /> Recipe Vector Index</h2>
          <p>Đồng bộ công thức từ Recipe Service vào vector database để phục vụ retrieval.</p>
        </div>
        <span className="chip active">Connected</span>
      </div>
      <div className="recipe-index-metrics">
        {indexRows.map(([label, value]) => (
          <div className="recipe-status-metric" key={label}>
            <span>{label}</span>
            <strong>{value}</strong>
          </div>
        ))}
      </div>
      <div className="button-row">
        <button className="primary-btn"><RefreshCw size={16} /> Sync from Recipe Service</button>
        <button className="ghost-btn"><RotateCw size={16} /> Re-index Recipes</button>
      </div>
    </article>
  );
}
