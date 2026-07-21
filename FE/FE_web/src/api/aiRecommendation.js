const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || "http://localhost:8080").replace(/\/$/, "");

export class AiApiError extends Error {
  constructor(message, status = 0, details = null, options = {}) {
    super(message, options);
    this.name = "AiApiError";
    this.status = status;
    this.details = details;
  }
}

function getAccessToken() {
  if (typeof localStorage === "undefined") return null;
  return localStorage.getItem("accessToken") || localStorage.getItem("access_token");
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
  if (Array.isArray(body?.detail)) {
    return body.detail.map((item) => item.msg || item.message || "Dữ liệu không hợp lệ.").join(" ");
  }
  if (body && typeof body === "object") {
    return body.message || body.detail || body.error || body.title || `Yêu cầu thất bại (${status}).`;
  }
  return `Yêu cầu thất bại (${status}).`;
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
  } catch (cause) {
    throw new AiApiError(
      `Không thể kết nối AI Recommendation Service qua API Gateway tại ${API_BASE_URL}.`,
      0,
      null,
      { cause }
    );
  }

  const body = await parseResponseBody(response);

  if (!response.ok) {
    throw new AiApiError(errorMessage(body, response.status), response.status, body);
  }

  return body;
}

export function getAiRecommendations(payload) {
  return request("/api/ai/recommendations", {
    method: "POST",
    body: JSON.stringify(payload)
  });
}
