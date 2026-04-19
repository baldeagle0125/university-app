const TOKEN_KEY = "admin_portal_token";

const API_BASE = "/api/v1";

export function getToken() {
  return localStorage.getItem(TOKEN_KEY) || "";
}

export function setToken(token) {
  localStorage.setItem(TOKEN_KEY, token);
}

export function clearToken() {
  localStorage.removeItem(TOKEN_KEY);
}

export async function request(path, options = {}) {
  const headers = new Headers(options.headers || {});
  headers.set("Content-Type", "application/json");

  const token = getToken();
  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
  });

  if (response.status === 204) {
    return null;
  }

  const contentType = response.headers.get("content-type") || "";
  const body = contentType.includes("application/json")
    ? await response.json()
    : { error: await response.text() };

  if (!response.ok) {
    const errorMessage = body?.error || `Request failed with status ${response.status}`;
    throw new Error(errorMessage);
  }

  return body;
}

export function loginStaff(staffNumber, password) {
  return request("/staff/login", {
    method: "POST",
    body: JSON.stringify({ staff_number: staffNumber, password }),
  });
}

export function listCardRequests() {
  return request("/admin/card-requests");
}

export function processCardRequest(id, requestStatus, adminNotes) {
  return request(`/admin/card-requests/${id}/process`, {
    method: "POST",
    body: JSON.stringify({ request_status: requestStatus, admin_notes: adminNotes }),
  });
}

export function listStudents(query = "") {
  return request(`/students${query ? `?${query}` : ""}`);
}

export function createStudent(payload) {
  return request("/students", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function deleteStudent(id) {
  return request(`/students/${id}`, {
    method: "DELETE",
  });
}

export function listAssignments(query = "") {
  return request(`/admin/assignments${query ? `?${query}` : ""}`);
}

export function listFeedback(query = "") {
  return request(`/admin/feedback${query ? `?${query}` : ""}`);
}

export function listTelemetry(query = "") {
  return request(`/admin/telemetry/events${query ? `?${query}` : ""}`);
}

export function listStaff(query = "") {
  return request(`/admin/staff${query ? `?${query}` : ""}`);
}

export function createStaff(payload) {
  return request("/admin/staff", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updateStaff(id, payload) {
  return request(`/admin/staff/${id}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}
