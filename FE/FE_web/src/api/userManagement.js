const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || "http://localhost:8080").replace(/\/$/, "");

export class UserApiError extends Error {
  constructor(message, status, details) {
    super(message);
    this.name = "UserApiError";
    this.status = status;
    this.details = details;
  }
}

function getAccessToken() {
  return localStorage.getItem("accessToken") || localStorage.getItem("access_token");
}

async function request(path, options = {}) {
  const token = getAccessToken();
  const headers = {
    Accept: "application/json",
    ...options.headers
  };

  if (options.body !== undefined) headers["Content-Type"] = "application/json";
  if (token) headers.Authorization = `Bearer ${token}`;

  let response;
  try {
    response = await fetch(`${API_BASE_URL}${path}`, { ...options, headers });
  } catch {
    throw new UserApiError(
      "Không thể kết nối User Service. Hãy kiểm tra API Gateway tại " + API_BASE_URL + ".",
      0
    );
  }

  const contentType = response.headers.get("content-type") || "";
  const body = response.status === 204
    ? null
    : contentType.includes("application/json")
      ? await response.json()
      : await response.text();

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

export function getUser(userId) {
  return request(`/api/v1/users/${userId}`);
}

export function createUser(payload) {
  return request("/api/v1/users", { method: "POST", body: JSON.stringify(payload) });
}

export function createAccountByAdmin(payload) {
  return request("/api/v1/auth/admin/accounts", { method: "POST", body: JSON.stringify(payload) });
}

export function updateUser(userId, payload) {
  return request(`/api/v1/users/${userId}`, { method: "PUT", body: JSON.stringify(payload) });
}

export function deleteUser(userId) {
  return request(`/api/v1/users/${userId}`, { method: "DELETE" });
}

export function getHealthProfile(userId) {
  return request(`/api/v1/users/${userId}/health-profile`);
}

export function createHealthProfile(userId, payload) {
  return request(`/api/v1/users/${userId}/health-profile`, { method: "POST", body: JSON.stringify(payload) });
}

export function updateHealthProfile(userId, payload) {
  return request(`/api/v1/users/${userId}/health-profile`, { method: "PUT", body: JSON.stringify(payload) });
}

export function deleteHealthProfile(userId) {
  return request(`/api/v1/users/${userId}/health-profile`, { method: "DELETE" });
}

export function getNutritionGoal(userId) {
  return request(`/api/v1/users/${userId}/nutrition-goal`);
}

export function createNutritionGoal(userId, payload) {
  return request(`/api/v1/users/${userId}/nutrition-goal`, { method: "POST", body: JSON.stringify(payload) });
}

export function updateNutritionGoal(userId, payload) {
  return request(`/api/v1/users/${userId}/nutrition-goal`, { method: "PUT", body: JSON.stringify(payload) });
}

export function deleteNutritionGoal(userId) {
  return request(`/api/v1/users/${userId}/nutrition-goal`, { method: "DELETE" });
}

export function getDietPreferences(userId) {
  return request(`/api/v1/users/${userId}/diet-preferences`);
}

export function addDietPreference(userId, payload) {
  return request(`/api/v1/users/${userId}/diet-preferences`, { method: "POST", body: JSON.stringify(payload) });
}

export function updateDietPreference(userId, preferenceId, payload) {
  return request(`/api/v1/users/${userId}/diet-preferences/${preferenceId}`, { method: "PUT", body: JSON.stringify(payload) });
}

export function deleteDietPreference(userId, preferenceId) {
  return request(`/api/v1/users/${userId}/diet-preferences/${preferenceId}`, { method: "DELETE" });
}

export function getAllergies(userId) {
  return request(`/api/v1/users/${userId}/allergies`);
}

export function addAllergy(userId, payload) {
  return request(`/api/v1/users/${userId}/allergies`, { method: "POST", body: JSON.stringify(payload) });
}

export function updateAllergy(userId, allergyId, payload) {
  return request(`/api/v1/users/${userId}/allergies/${allergyId}`, { method: "PUT", body: JSON.stringify(payload) });
}

export function deleteAllergy(userId, allergyId) {
  return request(`/api/v1/users/${userId}/allergies/${allergyId}`, { method: "DELETE" });
}

export function getFavorites(userId) {
  return request(`/api/v1/users/${userId}/favorites`);
}

export function addFavorite(userId, payload) {
  return request(`/api/v1/users/${userId}/favorites`, { method: "POST", body: JSON.stringify(payload) });
}

export function updateFavorite(userId, favoriteId, payload) {
  return request(`/api/v1/users/${userId}/favorites/${favoriteId}`, { method: "PUT", body: JSON.stringify(payload) });
}

export function deleteFavorite(userId, favoriteId) {
  return request(`/api/v1/users/${userId}/favorites/${favoriteId}`, { method: "DELETE" });
}

export function getFoodLogs(userId, params = {}) {
  return request(`/api/v1/users/${userId}/food-logs${queryString(params)}`);
}

export function createFoodLog(userId, payload) {
  return request(`/api/v1/users/${userId}/food-logs`, { method: "POST", body: JSON.stringify(payload) });
}

export function updateFoodLog(userId, logId, payload) {
  return request(`/api/v1/users/${userId}/food-logs/${logId}`, { method: "PUT", body: JSON.stringify(payload) });
}

export function deleteFoodLog(userId, logId) {
  return request(`/api/v1/users/${userId}/food-logs/${logId}`, { method: "DELETE" });
}

export async function optionalResource(loader) {
  try {
    return await loader();
  } catch (error) {
    if (error instanceof UserApiError && error.status === 404) return null;
    throw error;
  }
}
