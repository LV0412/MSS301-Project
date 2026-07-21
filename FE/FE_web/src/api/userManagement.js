const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || "http://localhost:8080").replace(/\/$/, "");

export class UserApiError extends Error {
  constructor(message, status = 0, details = null) {
    super(message);
    this.name = "UserApiError";
    this.status = status;
    this.details = details;
  }
}

function getAccessToken() {
  if (typeof localStorage === "undefined") return null;
  return localStorage.getItem("accessToken") || localStorage.getItem("access_token");
}

async function parseResponse(response) {
  if (response.status === 204 || response.status === 205) return null;

  const text = await response.text();
  if (!text) return null;

  const contentType = response.headers.get("content-type") || "";
  if (contentType.includes("json")) {
    try {
      return JSON.parse(text);
    } catch {
      return text;
    }
  }

  return text;
}

async function request(path, options = {}) {
  const token = getAccessToken();
  const headers = {
    Accept: "application/json",
    ...(options.headers || {})
  };

  if (options.body !== undefined) headers["Content-Type"] = "application/json";
  if (token) headers.Authorization = `Bearer ${token}`;

  let response;
  try {
    response = await fetch(`${API_BASE_URL}${path}`, { ...options, headers });
  } catch {
    throw new UserApiError(`Không thể kết nối API Gateway tại ${API_BASE_URL}.`, 0);
  }

  const body = await parseResponse(response);

  if (!response.ok) {
    const message = body?.message || body?.error || body || `Yêu cầu thất bại (${response.status}).`;
    throw new UserApiError(message, response.status, body);
  }

  return body;
}

function queryString(params = {}) {
  const query = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== "") query.append(key, String(value));
  });
  const value = query.toString();
  return value ? `?${value}` : "";
}

export function getUsers(params = {}) {
  return request(`/api/v1/users${queryString(params)}`);
}

export function getInternalUser(userId) {
  return request(`/api/internal/users/${encodeURIComponent(String(userId))}`);
}

export function createUserProfile(payload) {
  return request("/api/v1/users", { method: "POST", body: JSON.stringify(payload) });
}

export function inviteUserByAdmin(payload) {
  return request("/api/v1/auth/admin/accounts", { method: "POST", body: JSON.stringify(payload) });
}

export function resendVerificationOtp(email) {
  return request("/api/v1/auth/resend-otp", {
    method: "POST",
    body: JSON.stringify({ email })
  });
}

export function requestPasswordReset(email) {
  return request("/api/v1/auth/forgot-password", {
    method: "POST",
    body: JSON.stringify({ email })
  });
}

export const createAccountByAdmin = inviteUserByAdmin;
