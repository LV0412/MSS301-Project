const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || "http://localhost:8080").replace(/\/$/, "");
export const AUTH_STORAGE_KEY = "nutrichef_admin_auth";

export class AuthApiError extends Error {
  constructor(message, status = 0, details = null) {
    super(message);
    this.name = "AuthApiError";
    this.status = status;
    this.details = details;
  }
}

export function readStoredAuth() {
  try {
    const raw = localStorage.getItem(AUTH_STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    localStorage.removeItem(AUTH_STORAGE_KEY);
    return null;
  }
}

export function writeStoredAuth(session) {
  localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(session));
  if (session?.accessToken) {
    localStorage.setItem("accessToken", session.accessToken);
    localStorage.setItem("access_token", session.accessToken);
  }
  if (session?.refreshToken) {
    localStorage.setItem("refreshToken", session.refreshToken);
    localStorage.setItem("refresh_token", session.refreshToken);
  }
}

export function clearStoredAuth() {
  localStorage.removeItem(AUTH_STORAGE_KEY);
  localStorage.removeItem("accessToken");
  localStorage.removeItem("access_token");
  localStorage.removeItem("refreshToken");
  localStorage.removeItem("refresh_token");
}

export function getAccessToken() {
  return readStoredAuth()?.accessToken || localStorage.getItem("accessToken") || localStorage.getItem("access_token") || null;
}

async function parseResponse(response) {
  const text = await response.text();
  if (!text) return null;

  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

async function authRequest(path, options = {}) {
  const headers = {
    Accept: "application/json",
    ...(options.headers || {})
  };

  if (options.body !== undefined) headers["Content-Type"] = "application/json";

  const token = options.auth === false ? null : getAccessToken();
  if (token) headers.Authorization = `Bearer ${token}`;

  let response;
  try {
    response = await fetch(`${API_BASE_URL}${path}`, { ...options, headers });
  } catch {
    throw new AuthApiError(`Không thể kết nối Auth Service qua API Gateway tại ${API_BASE_URL}.`, 0);
  }

  const body = await parseResponse(response);
  if (!response.ok) {
    const message = body?.message || body?.error || body || `Yêu cầu thất bại (${response.status}).`;
    throw new AuthApiError(message, response.status, body);
  }

  return body;
}

export function registerAccount(payload) {
  return authRequest("/api/v1/auth/register", {
    method: "POST",
    auth: false,
    body: JSON.stringify(payload)
  });
}

export function loginAccount(payload) {
  return authRequest("/api/v1/auth/login", {
    method: "POST",
    auth: false,
    body: JSON.stringify(payload)
  });
}

export function getCurrentAccount() {
  return authRequest("/api/v1/auth/me");
}

export function refreshSession(refreshToken) {
  return authRequest("/api/v1/auth/refresh", {
    method: "POST",
    auth: false,
    body: JSON.stringify({ refreshToken })
  });
}

export function logoutAccount(refreshToken) {
  return authRequest("/api/v1/auth/logout", {
    method: "POST",
    body: JSON.stringify({ refreshToken })
  });
}
