import { apiRequest } from "./client.js";

export function loginAdmin(credentials) {
  return apiRequest("/api/v1/auth/login", {
    method: "POST",
    body: credentials,
    auth: false
  });
}

export function getCurrentAccount() {
  return apiRequest("/api/v1/auth/me");
}

export function refreshSession(refreshToken) {
  return apiRequest("/api/v1/auth/refresh", {
    method: "POST",
    body: { refreshToken },
    auth: false
  });
}

export function logoutAdmin(refreshToken) {
  return apiRequest("/api/v1/auth/logout", {
    method: "POST",
    body: { refreshToken }
  });
}

