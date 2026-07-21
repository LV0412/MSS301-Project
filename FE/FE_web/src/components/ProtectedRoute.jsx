import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function ProtectedRoute({ children }) {
  const location = useLocation();
  const { bootstrapping, isAuthenticated } = useAuth();

  if (bootstrapping) {
    return (
      <div className="auth-loading-screen">
        <div className="brand-mark">AI</div>
        <strong>Đang kiểm tra phiên đăng nhập...</strong>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location }} />;
  }

  return children;
}
