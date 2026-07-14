import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { getCurrentAccount, loginAdmin, logoutAdmin, refreshSession } from "../api/auth.js";
import { clearStoredAuth, readStoredAuth, writeStoredAuth } from "../api/client.js";

const AuthContext = createContext(null);

function toSession(authResponse) {
  return {
    accessToken: authResponse.accessToken,
    refreshToken: authResponse.refreshToken,
    tokenType: authResponse.tokenType || "Bearer",
    expiresIn: authResponse.expiresIn,
    account: authResponse.account
  };
}

function isAdminAccount(account) {
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

    async function restoreSession() {
      const stored = readStoredAuth();
      if (!stored?.accessToken) {
        if (!cancelled) setBootstrapping(false);
        return;
      }

      try {
        const account = await getCurrentAccount();
        if (!isAdminAccount(account)) {
          clearSession();
          return;
        }
        if (!cancelled) persistSession({ ...stored, account });
      } catch {
        if (!stored.refreshToken) {
          clearSession();
          return;
        }

        try {
          const refreshed = await refreshSession(stored.refreshToken);
          if (!isAdminAccount(refreshed.account)) {
            clearSession();
            return;
          }
          if (!cancelled) persistSession(toSession(refreshed));
        } catch {
          clearSession();
        }
      } finally {
        if (!cancelled) setBootstrapping(false);
      }
    }

    restoreSession();

    return () => {
      cancelled = true;
    };
  }, [clearSession, persistSession]);

  const login = useCallback(async ({ email, password }) => {
    const authResponse = await loginAdmin({ email, password });

    if (!isAdminAccount(authResponse.account)) {
      clearSession();
      throw new Error("Tài khoản này không có quyền truy cập dashboard Admin.");
    }

    const nextSession = toSession(authResponse);
    persistSession(nextSession);
    return nextSession;
  }, [clearSession, persistSession]);

  const logout = useCallback(async () => {
    const refreshToken = readStoredAuth()?.refreshToken;

    try {
      if (refreshToken) await logoutAdmin(refreshToken);
    } catch {
      // Local logout should still complete if the backend session is already unavailable.
    } finally {
      clearSession();
    }
  }, [clearSession]);

  const value = useMemo(() => ({
    account: session?.account || null,
    accessToken: session?.accessToken || null,
    isAuthenticated: Boolean(session?.accessToken && isAdminAccount(session?.account)),
    bootstrapping,
    login,
    logout
  }), [bootstrapping, login, logout, session]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used inside AuthProvider");
  }
  return context;
}
