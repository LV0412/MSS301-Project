export async function createUser(payload) {
  return { ok: true, payload };
}

export async function resendInvitation(userId) {
  return { ok: true, userId };
}

export async function resetOnboarding(userId, reason) {
  return { ok: true, userId, reason };
}

export async function lockUser(userId, reason) {
  return { ok: true, userId, reason };
}

export async function unlockUser(userId, reason) {
  return { ok: true, userId, reason };
}

export async function deactivateUser(userId, reason) {
  return { ok: true, userId, reason };
}

export async function sendSupportEmail(userId) {
  return { ok: true, userId };
}

export async function requestSensitiveAccess(userId, reason) {
  return { ok: true, userId, reason };
}
