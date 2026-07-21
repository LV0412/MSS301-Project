const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || "http://localhost:8080").replace(/\/$/, "");

export class RecipeApiError extends Error {
  constructor(message, status = 0, details = null, options = {}) {
    super(message, options);
    this.name = "RecipeApiError";
    this.status = status;
    this.details = details;
  }
}

function getAccessToken() {
  if (typeof localStorage === "undefined") return null;
  return localStorage.getItem("accessToken") || localStorage.getItem("access_token");
}

function queryString(params = {}) {
  const query = new URLSearchParams();

  Object.entries(params).forEach(([key, rawValue]) => {
    const values = Array.isArray(rawValue)
      ? rawValue
      : rawValue instanceof Set
        ? [...rawValue]
        : [rawValue];

    values.forEach((value) => {
      if (value !== undefined && value !== null && value !== "") {
        query.append(key, String(value));
      }
    });
  });

  const value = query.toString();
  return value ? `?${value}` : "";
}

async function parseResponseBody(response) {
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

function errorMessage(body, status) {
  if (typeof body === "string" && body.trim()) return body;
  if (body && typeof body === "object") {
    return body.message || body.detail || body.error || body.title || `Yêu cầu thất bại (${status}).`;
  }
  return `Yêu cầu thất bại (${status}).`;
}

async function request(path, options = {}) {
  const token = getAccessToken();
  const headers = {
    Accept: "application/json",
    ...options.headers
  };

  const isFormData = typeof FormData !== "undefined" && options.body instanceof FormData;
  if (options.body !== undefined && !isFormData) {
    headers["Content-Type"] = "application/json";
  }
  if (token) headers.Authorization = `Bearer ${token}`;

  let response;
  try {
    response = await fetch(`${API_BASE_URL}${path}`, { ...options, headers });
  } catch (cause) {
    throw new RecipeApiError(
      `Không thể kết nối Recipe Service. Hãy kiểm tra API Gateway tại ${API_BASE_URL}.`,
      0,
      null,
      { cause }
    );
  }

  let body;
  try {
    body = await parseResponseBody(response);
  } catch (cause) {
    throw new RecipeApiError(
      `Không thể đọc phản hồi từ Recipe Service (${response.status}).`,
      response.status,
      null,
      { cause }
    );
  }

  if (!response.ok) {
    throw new RecipeApiError(errorMessage(body, response.status), response.status, body);
  }

  return body;
}

function resourcePath(resource, id) {
  return `/api/v1/${resource}/${encodeURIComponent(String(id))}`;
}

function createResource(resource, payload) {
  return request(`/api/v1/${resource}`, {
    method: "POST",
    body: JSON.stringify(payload)
  });
}

function updateResource(resource, id, payload) {
  return request(resourcePath(resource, id), {
    method: "PUT",
    body: JSON.stringify(payload)
  });
}

function deleteResource(resource, id) {
  return request(resourcePath(resource, id), { method: "DELETE" });
}

export function getRecipes(params = {}) {
  return request(`/api/v1/recipes${queryString(params)}`);
}

export function getRecipe(recipeId) {
  return request(resourcePath("recipes", recipeId));
}

export function createRecipe(payload) {
  return createResource("recipes", payload);
}

export function updateRecipe(recipeId, payload) {
  return updateResource("recipes", recipeId, payload);
}

export function deleteRecipe(recipeId) {
  return deleteResource("recipes", recipeId);
}

export function uploadRecipeImage(file) {
  const body = new FormData();
  body.append("file", file);
  return request("/api/v1/recipes/upload-image", {
    method: "POST",
    body
  });
}

export function getIngredients(params = {}) {
  return request(`/api/v1/ingredients${queryString(params)}`);
}

export function getIngredient(ingredientId) {
  return request(resourcePath("ingredients", ingredientId));
}

export function createIngredient(payload) {
  return createResource("ingredients", payload);
}

export function updateIngredient(ingredientId, payload) {
  return updateResource("ingredients", ingredientId, payload);
}

export function deleteIngredient(ingredientId) {
  return deleteResource("ingredients", ingredientId);
}

export function getCategories(params = {}) {
  return request(`/api/v1/categories${queryString(params)}`);
}

export function getCategory(categoryId) {
  return request(resourcePath("categories", categoryId));
}

export function createCategory(payload) {
  return createResource("categories", payload);
}

export function updateCategory(categoryId, payload) {
  return updateResource("categories", categoryId, payload);
}

export function deleteCategory(categoryId) {
  return deleteResource("categories", categoryId);
}

export function getAllergens(params = {}) {
  return request(`/api/v1/allergens${queryString(params)}`);
}

export function getAllergen(allergenId) {
  return request(resourcePath("allergens", allergenId));
}

export function createAllergen(payload) {
  return createResource("allergens", payload);
}

export function updateAllergen(allergenId, payload) {
  return updateResource("allergens", allergenId, payload);
}

export function deleteAllergen(allergenId) {
  return deleteResource("allergens", allergenId);
}
