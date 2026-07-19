import { apiRequest } from "./client.js";

export function getUsers({ page = 0, size = 10, sort = "createdAt,desc" } = {}) {
  const params = new URLSearchParams({
    page: String(page),
    size: String(size),
    sort
  });
  return apiRequest(`/api/v1/users?${params.toString()}`);
}

export async function getAllUsers({ size = 100, sort = "createdAt,desc" } = {}) {
  const firstPage = await getUsers({ page: 0, size, sort });
  const totalPages = firstPage?.totalPages || 1;
  const content = [...(firstPage?.content || [])];

  for (let page = 1; page < totalPages; page += 1) {
    const nextPage = await getUsers({ page, size, sort });
    content.push(...(nextPage?.content || []));
  }

  return {
    ...firstPage,
    content,
    number: 0,
    size: content.length,
    numberOfElements: content.length
  };
}

export function getUserById(userId) {
  return apiRequest(`/api/v1/users/${userId}`);
}

export function createUser(payload) {
  return apiRequest("/api/v1/users", {
    method: "POST",
    body: {
      email: payload.email,
      passwordHash: payload.passwordHash,
      fullName: payload.fullName,
      dob: payload.dob || null,
      gender: payload.gender
    }
  });
}

export function updateUser(userId, payload) {
  return apiRequest(`/api/v1/users/${userId}`, {
    method: "PUT",
    body: payload
  });
}

export function deleteUser(userId) {
  return apiRequest(`/api/v1/users/${userId}`, {
    method: "DELETE"
  });
}

function unsupportedAction(action) {
  return async () => {
    throw new Error(`${action} chưa có API trong user-service hiện tại.`);
  };
}

export const resendInvitation = unsupportedAction("Gửi lại email kích hoạt");
export const resetOnboarding = unsupportedAction("Reset onboarding");
export const lockUser = unsupportedAction("Khóa tài khoản");
export const unlockUser = unsupportedAction("Mở khóa tài khoản");
export const deactivateUser = unsupportedAction("Vô hiệu hóa tài khoản");
export const sendSupportEmail = unsupportedAction("Gửi email hỗ trợ");
export const requestSensitiveAccess = unsupportedAction("Yêu cầu quyền truy cập dữ liệu nhạy cảm");
