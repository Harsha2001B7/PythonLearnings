/* ============================================================
   api.js — Central API layer
   All fetch calls to FastAPI backend go through here.
   Base URL can be changed in one place.
============================================================ */

const BASE = 'http://localhost:8000/api/v1';

// ─── CORE FETCH ────────────────────────────────────────────
async function apiFetch(path, options = {}) {
  const res = await fetch(BASE + path, {
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
    ...options,
  });

  if (res.status === 204) return null; // DELETE success

  const data = await res.json();

  if (!res.ok) {
    const msg = data.detail || `Error ${res.status}`;
    throw new Error(typeof msg === 'string' ? msg : JSON.stringify(msg));
  }

  return data;
}

// ─── COMPANIES ─────────────────────────────────────────────
const CompanyAPI = {
  getAll: (page = 1, size = 20) =>
    apiFetch(`/companies/?page=${page}&page_size=${size}`),

  getById: (id) =>
    apiFetch(`/companies/${id}`),

  create: (body) =>
    apiFetch('/companies/', { method: 'POST', body: JSON.stringify(body) }),

  update: (id, body) =>
    apiFetch(`/companies/${id}`, { method: 'PATCH', body: JSON.stringify(body) }),

  delete: (id) =>
    apiFetch(`/companies/${id}`, { method: 'DELETE' }),
};

// ─── APPLICATIONS ──────────────────────────────────────────
const ApplicationAPI = {
  getAll: (params = {}) => {
    const q = new URLSearchParams();
    if (params.page)       q.set('page', params.page);
    if (params.page_size)  q.set('page_size', params.page_size);
    if (params.status)     q.set('status', params.status);
    if (params.company_id) q.set('company_id', params.company_id);
    return apiFetch(`/applications/?${q}`);
  },

  getById: (id) =>
    apiFetch(`/applications/${id}`),

  create: (body) =>
    apiFetch('/applications/', { method: 'POST', body: JSON.stringify(body) }),

  update: (id, body) =>
    apiFetch(`/applications/${id}`, { method: 'PATCH', body: JSON.stringify(body) }),

  delete: (id) =>
    apiFetch(`/applications/${id}`, { method: 'DELETE' }),
};

// ─── CONTACTS ──────────────────────────────────────────────
const ContactAPI = {
  getAll: (params = {}) => {
    const q = new URLSearchParams();
    if (params.page)       q.set('page', params.page);
    if (params.page_size)  q.set('page_size', params.page_size);
    if (params.company_id) q.set('company_id', params.company_id);
    return apiFetch(`/contacts/?${q}`);
  },

  getById: (id) =>
    apiFetch(`/contacts/${id}`),

  create: (body) =>
    apiFetch('/contacts/', { method: 'POST', body: JSON.stringify(body) }),

  update: (id, body) =>
    apiFetch(`/contacts/${id}`, { method: 'PATCH', body: JSON.stringify(body) }),

  delete: (id) =>
    apiFetch(`/contacts/${id}`, { method: 'DELETE' }),
};

// ─── INTERVIEWS ────────────────────────────────────────────
const InterviewAPI = {
  getAll: (params = {}) => {
    const q = new URLSearchParams();
    if (params.page)           q.set('page', params.page);
    if (params.page_size)      q.set('page_size', params.page_size);
    if (params.application_id) q.set('application_id', params.application_id);
    return apiFetch(`/interviews/?${q}`);
  },

  getById: (id) =>
    apiFetch(`/interviews/${id}`),

  create: (body) =>
    apiFetch('/interviews/', { method: 'POST', body: JSON.stringify(body) }),

  update: (id, body) =>
    apiFetch(`/interviews/${id}`, { method: 'PATCH', body: JSON.stringify(body) }),

  delete: (id) =>
    apiFetch(`/interviews/${id}`, { method: 'DELETE' }),
};

// ─── SHARED UTILITIES ──────────────────────────────────────

/** Show a toast notification */
let toastTimer;
function showToast(msg, type = 'success') {
  const el = document.getElementById('toast');
  el.textContent = msg;
  el.className = `show ${type}`;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { el.className = ''; }, 3000);
}

/** Format ISO date to readable string */
function fmtDate(iso) {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('en-IN', {
    day: '2-digit', month: 'short', year: 'numeric'
  });
}

/** Format ISO datetime */
function fmtDateTime(iso) {
  if (!iso) return '—';
  return new Date(iso).toLocaleString('en-IN', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  });
}

/** Status badge HTML */
function badge(value, type = 'status') {
  if (!value) return '—';
  return `<span class="badge badge-${value}">${value}</span>`;
}

/** Confirm + delete helper, returns true if deleted */
async function confirmDelete(label, deleteFn) {
  if (!confirm(`Delete "${label}"? This cannot be undone.`)) return false;
  try {
    await deleteFn();
    showToast(`${label} deleted.`, 'success');
    return true;
  } catch (e) {
    showToast(e.message, 'error');
    return false;
  }
}

/** Render pagination buttons */
function renderPagination(containerId, total, page, pageSize, onChange) {
  const totalPages = Math.ceil(total / pageSize);
  const el = document.getElementById(containerId);
  if (!el) return;

  if (totalPages <= 1) { el.innerHTML = ''; return; }

  el.innerHTML = `
    <span>${(page - 1) * pageSize + 1}–${Math.min(page * pageSize, total)} of ${total}</span>
    <button class="btn btn-ghost btn-sm" ${page <= 1 ? 'disabled' : ''} onclick="(${onChange})(${page - 1})">← Prev</button>
    <button class="btn btn-ghost btn-sm" ${page >= totalPages ? 'disabled' : ''} onclick="(${onChange})(${page + 1})">Next →</button>
  `;
}
