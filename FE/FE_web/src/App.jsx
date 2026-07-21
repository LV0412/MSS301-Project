import { Navigate, Route, Routes } from "react-router-dom";
import ProtectedRoute from "./components/ProtectedRoute.jsx";
import AdminLayout from "./layouts/AdminLayout.jsx";
import LoginPage from "./pages/LoginPage.jsx";
import RegisterPage from "./pages/RegisterPage.jsx";
import OverviewPage from "./pages/OverviewPage.jsx";
import RecipesPage from "./pages/RecipesPage.jsx";
import RecipeFormPage from "./pages/RecipeFormPage.jsx";
import NutritionPage from "./pages/NutritionPage.jsx";
import IngredientFormPage from "./pages/IngredientFormPage.jsx";
import ReportsPage from "./pages/ReportsPage.jsx";
import UsersPage from "./pages/UsersPage.jsx";
import UserFormPage from "./pages/UserFormPage.jsx";
import UserDetailPage from "./pages/UserDetailPage.jsx";
import AIKnowledgePage from "./pages/AIKnowledgePage.jsx";
import AIOverview from "./components/ai/AIOverview.jsx";
import RecommendationSandbox from "./components/ai/RecommendationSandbox.jsx";
import MealPlanSandbox from "./components/ai/MealPlanSandbox.jsx";
import AILogs from "./components/ai/AILogs.jsx";
import SettingsPage from "./pages/SettingsPage.jsx";

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      <Route path="/" element={<ProtectedRoute><AdminLayout /></ProtectedRoute>}>
        <Route index element={<Navigate to="/overview" replace />} />
        <Route path="overview" element={<OverviewPage />} />
        <Route path="recipes" element={<RecipesPage />} />
        <Route path="recipes/new" element={<RecipeFormPage mode="create" />} />
        <Route path="recipes/:id/edit" element={<RecipeFormPage mode="edit" />} />
        <Route path="nutrition" element={<NutritionPage />} />
        <Route path="nutrition/new" element={<IngredientFormPage mode="create" />} />
        <Route path="nutrition/:id/edit" element={<IngredientFormPage mode="edit" />} />
        <Route path="reports" element={<ReportsPage />} />
        <Route path="users" element={<UsersPage />} />
        <Route path="users/new" element={<UserFormPage />} />
        <Route path="users/:id" element={<UserDetailPage />} />
        <Route path="ai-overview" element={<AIOverview />} />
        <Route path="ai-knowledge" element={<AIKnowledgePage />} />
        <Route path="ai-recommendation-sandbox" element={<RecommendationSandbox />} />
        <Route path="ai-meal-plan-sandbox" element={<MealPlanSandbox />} />
        <Route path="ai-logs" element={<AILogs />} />
        <Route path="settings" element={<SettingsPage />} />
        <Route path="*" element={<Navigate to="/overview" replace />} />
      </Route>
    </Routes>
  );
}
