const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || "http://localhost:8080").replace(/\/$/, "");

export const AUTH_STORAGE_KEY = "nutrichef_admin_auth";

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
}

export function clearStoredAuth() {
  localStorage.removeItem(AUTH_STORAGE_KEY);
}

export function getAccessToken() {
  return readStoredAuth()?.accessToken || null;
}

export class ApiError extends Error {
  constructor(message, status, payload) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.payload = payload;
  }
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

export async function apiRequest(path, options = {}) {
  const {
    method = "GET",
    body,
    headers = {},
    auth = true
  } = options;

  const requestHeaders = {
    Accept: "application/json",
    ...headers
  };

  let requestBody = body;
  if (body !== undefined && !(body instanceof FormData)) {
    requestHeaders["Content-Type"] = "application/json";
    requestBody = JSON.stringify(body);
  }

  if (auth) {
    const token = getAccessToken();
    if (token) requestHeaders.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    method,
    headers: requestHeaders,
    body: requestBody
  });

  const payload = await parseResponse(response);

  if (!response.ok) {
    const message = payload?.message || payload?.error || "Không thể kết nối đến máy chủ.";
    throw new ApiError(message, response.status, payload);
  }

  return payload;
}

