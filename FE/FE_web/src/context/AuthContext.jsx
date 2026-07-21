import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import {
  clearStoredAuth,
  getCurrentAccount,
  loginAccount,
  logoutAccount,
  readStoredAuth,
  refreshSession,
  registerAccount,
  writeStoredAuth
} from "../api/auth.js";

const AuthContext = createContext(null);

function toSession(response) {
  return {
    accessToken: response.accessToken,
    refreshToken: response.refreshToken,
    tokenType: response.tokenType || "Bearer",
    expiresIn: response.expiresIn,
    account: response.account
  };
}

function isAdmin(account) {
  return account?.role === "ADMIN";
}

export function AuthProvider({ children }) {
  const [session, setSession] = useState(() => readStoredAuth());
  const [bootstrapping, setBootstrapping] = useState(true);

  const persistSession = useCallback((nextSession) => {
    setSession(nextSession);
    writeStoredAuth(nextSession);
  }, []);

  const clearSession = useCallback(() => {
    setSession(null);
    clearStoredAuth();
  }, []);

  useEffect(() => {
    let cancelled = false;

    async function restore() {
      const stored = readStoredAuth();
      if (!stored?.accessToken) {
        if (!cancelled) setBootstrapping(false);
        return;
      }

      try {
        const account = await getCurrentAccount();
        if (cancelled) return;
        if (!isAdmin(account)) {
          clearSession();
          return;
        }
        persistSession({ ...stored, account });
      } catch {
        if (!stored.refreshToken) {
          clearSession();
        } else {
          try {
            const refreshed = await refreshSession(stored.refreshToken);
            if (cancelled) return;
            if (!isAdmin(refreshed.account)) {
              clearSession();
              return;
            }
            persistSession(toSession(refreshed));
          } catch {
            clearSession();
          }
        }
      } finally {
        if (!cancelled) setBootstrapping(false);
      }
    }

    restore();
    return () => {
      cancelled = true;
    };
  }, [clearSession, persistSession]);

  const login = useCallback(async ({ email, password }) => {
    const response = await loginAccount({ email, password });
    if (!isAdmin(response.account)) {
      clearSession();
      throw new Error("Tài khoản này không có quyền truy cập dashboard Admin.");
    }
    const nextSession = toSession(response);
    persistSession(nextSession);
    return nextSession;
  }, [clearSession, persistSession]);

  const register = useCallback((payload) => registerAccount(payload), []);

  const logout = useCallback(async () => {
    const refreshToken = readStoredAuth()?.refreshToken;
    try {
      if (refreshToken) await logoutAccount(refreshToken);
    } catch {
      // Vẫn đăng xuất local nếu phiên phía BE đã hết hạn hoặc gateway không phản hồi.
    } finally {
      clearSession();
    }
  }, [clearSession]);

  const value = useMemo(() => ({
    account: session?.account || null,
    accessToken: session?.accessToken || null,
    isAuthenticated: Boolean(session?.accessToken && isAdmin(session?.account)),
    bootstrapping,
    login,
    register,
    logout
  }), [bootstrapping, login, logout, register, session]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuth must be used inside AuthProvider");
  return context;
}
