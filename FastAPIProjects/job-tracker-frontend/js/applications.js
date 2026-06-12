/* ============================================================
   applications.js — applications.html logic
============================================================ */

let currentPage = 1;
const PAGE_SIZE = 15;
let companyMap = {};  // id → name
let currentApps = [];

async function loadCompanyOptions() {
  try {
    const data = await CompanyAPI.getAll(1, 100);
    const companies = data.companies || [];
    companies.forEach(c => companyMap[c.id] = c.name);

    // Populate filter dropdown
    const filterSel = document.getElementById('filter-company');
    companies.forEach(c => {
      const opt = document.createElement('option');
      opt.value = c.id;
      opt.textContent = c.name;
      filterSel.appendChild(opt);
    });

    // Populate modal company dropdown
    const modalSel = document.getElementById('f-company-id');
    companies.forEach(c => {
      const opt = document.createElement('option');
      opt.value = c.id;
      opt.textContent = c.name;
      modalSel.appendChild(opt);
    });
  } catch (e) {
    showToast('Could not load companies: ' + e.message, 'error');
  }
}

async function loadApplications() {
  const tbody = document.getElementById('applications-table');
  tbody.innerHTML = `<tr><td colspan="6"><div class="loading"><div class="spinner"></div> Loading…</div></td></tr>`;

  const status    = document.getElementById('filter-status').value;
  const companyId = document.getElementById('filter-company').value;

  try {
    const data = await ApplicationAPI.getAll({
      page: currentPage,
      page_size: PAGE_SIZE,
      status:     status    || undefined,
      company_id: companyId || undefined,
    });
    currentApps = data.applications || [];
    renderTable(currentApps);
    renderPagination('pagination', data.total, currentPage, PAGE_SIZE, 'goToPage');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="6" style="padding:24px;color:var(--red);text-align:center;">${e.message}</td></tr>`;
    showToast(e.message, 'error');
  }
}

function renderTable(apps) {
  const tbody = document.getElementById('applications-table');

  if (!apps.length) {
    tbody.innerHTML = `<tr><td colspan="6"><div class="empty"><p>No applications found. Try changing the filter or add a new one.</p></div></td></tr>`;
    return;
  }

  tbody.innerHTML = apps.map(a => `
    <tr>
      <td><strong>${companyMap[a.company_id] || `#${a.company_id}`}</strong></td>
      <td>
        ${a.role}
        ${a.job_url ? `<br><a class="row-link" href="${a.job_url}" target="_blank" rel="noopener" style="font-size:11px;">Job link ↗</a>` : ''}
      </td>
      <td>${badge(a.status)}</td>
      <td class="cell-muted">${fmtDate(a.applied_date)}</td>
      <td class="cell-muted" style="max-width:100px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;" title="${a.notes || ''}">${a.notes || '—'}</td>
      <td style="text-align:right;white-space:nowrap;">
        <button class="btn btn-ghost btn-sm" onclick="openEditModal(${a.id})">Edit</button>
        <button class="btn btn-danger btn-sm" onclick="deleteApp(${a.id}, '${a.role.replace(/'/g, "\\'")}')">Delete</button>
      </td>
    </tr>
  `).join('');
}

function onFilter() {
  currentPage = 1;
  loadApplications();
}

function goToPage(page) {
  currentPage = page;
  loadApplications();
}

// ─── MODAL ─────────────────────────────────────────────────

function openAddModal() {
  document.getElementById('modal-title').textContent = 'New Application';
  document.getElementById('edit-id').value = '';
  document.getElementById('f-company-id').value = '';
  document.getElementById('f-role').value = '';
  document.getElementById('f-job-url').value = '';
  document.getElementById('f-notes').value = '';
  document.getElementById('status-group').style.display = 'none';
  document.getElementById('modal').classList.add('open');
  document.getElementById('f-role').focus();
}

async function openEditModal(id) {
  try {
    const a = await ApplicationAPI.getById(id);
    document.getElementById('modal-title').textContent = 'Update Application';
    document.getElementById('edit-id').value            = a.id;
    document.getElementById('f-company-id').value      = a.company_id;
    document.getElementById('f-role').value            = a.role || '';
    document.getElementById('f-status').value          = a.status;
    document.getElementById('f-job-url').value         = a.job_url || '';
    document.getElementById('f-notes').value           = a.notes || '';
    document.getElementById('status-group').style.display = 'block';
    document.getElementById('modal').classList.add('open');
  } catch (e) {
    showToast(e.message, 'error');
  }
}

function closeModal() {
  document.getElementById('modal').classList.remove('open');
}

async function saveApplication() {
  const id        = document.getElementById('edit-id').value;
  const companyId = document.getElementById('f-company-id').value;
  const role      = document.getElementById('f-role').value.trim();

  if (!companyId) { showToast('Please select a company.', 'error'); return; }
  if (!role)      { showToast('Role is required.', 'error'); return; }

  try {
    if (id) {
      // Update — send status so transition is validated by backend
      const body = {
        role,
        status:   document.getElementById('f-status').value || undefined,
        job_url:  document.getElementById('f-job-url').value.trim() || null,
        notes:    document.getElementById('f-notes').value.trim()   || null,
      };
      await ApplicationAPI.update(id, body);
      showToast('Application updated.', 'success');
    } else {
      // Create — no status (backend defaults to Applied)
      const body = {
        company_id: parseInt(companyId),
        role,
        job_url: document.getElementById('f-job-url').value.trim() || null,
        notes:   document.getElementById('f-notes').value.trim()   || null,
      };
      await ApplicationAPI.create(body);
      showToast('Application added.', 'success');
    }
    closeModal();
    loadApplications();
  } catch (e) {
    showToast(e.message, 'error');
  }
}

async function deleteApp(id, role) {
  const deleted = await confirmDelete(role, () => ApplicationAPI.delete(id));
  if (deleted) loadApplications();
}

document.getElementById('modal').addEventListener('click', function (e) {
  if (e.target === this) closeModal();
});

// ─── INIT ──────────────────────────────────────────────────
(async () => {
  await loadCompanyOptions();
  await loadApplications();
})();
