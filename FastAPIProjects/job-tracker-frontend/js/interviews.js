/* ============================================================
   interviews.js — interviews.html logic
============================================================ */

let currentPage = 1;
const PAGE_SIZE = 15;
let applicationMap = {};   // id → "Company — Role"

async function loadApplicationOptions() {
  try {
    // Load applications in Interview status only (these are the ones you can log interviews for)
    const data = await ApplicationAPI.getAll({ page: 1, page_size: 100, status: 'Interview' });
    const apps  = data.applications || [];

    // Also load company names
    const cData   = await CompanyAPI.getAll(1, 100);
    const cMap    = {};
    (cData.companies || []).forEach(c => cMap[c.id] = c.name);

    apps.forEach(a => {
      applicationMap[a.id] = `${cMap[a.company_id] || `#${a.company_id}`} — ${a.role}`;
    });

    const filterSel = document.getElementById('filter-application');
    const modalSel  = document.getElementById('f-application-id');

    apps.forEach(a => {
      const label = applicationMap[a.id];
      [filterSel, modalSel].forEach(sel => {
        const opt = document.createElement('option');
        opt.value = a.id;
        opt.textContent = label;
        sel.appendChild(opt);
      });
    });

    if (!apps.length) {
      const info = document.createElement('option');
      info.disabled = true;
      info.textContent = 'No applications in Interview status';
      modalSel.appendChild(info);
    }
  } catch (e) {
    showToast('Could not load applications: ' + e.message, 'error');
  }
}

// Also build a full app map (all statuses) for display in the table
let fullAppMap = {};
async function loadFullAppMap() {
  try {
    const data  = await ApplicationAPI.getAll({ page: 1, page_size: 100 });
    const cData = await CompanyAPI.getAll(1, 100);
    const cMap  = {};
    (cData.companies || []).forEach(c => cMap[c.id] = c.name);
    (data.applications || []).forEach(a => {
      fullAppMap[a.id] = `${cMap[a.company_id] || `#${a.company_id}`} — ${a.role}`;
    });
  } catch (_) {}
}

async function loadInterviews() {
  const tbody = document.getElementById('interviews-table');
  tbody.innerHTML = `<tr><td colspan="7"><div class="loading"><div class="spinner"></div> Loading…</div></td></tr>`;

  const appId = document.getElementById('filter-application').value;

  try {
    const data = await InterviewAPI.getAll({
      page: currentPage,
      page_size: PAGE_SIZE,
      application_id: appId || undefined,
    });

    renderTable(data.interviews || []);
    renderPagination('pagination', data.total, currentPage, PAGE_SIZE, 'goToPage');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="7" style="padding:24px;color:var(--red);text-align:center;">${e.message}</td></tr>`;
    showToast(e.message, 'error');
  }
}

function renderTable(interviews) {
  const tbody = document.getElementById('interviews-table');

  if (!interviews.length) {
    tbody.innerHTML = `<tr><td colspan="7"><div class="empty"><p>No interviews logged yet. Set an application to "Interview" status first, then log a round here.</p></div></td></tr>`;
    return;
  }

  tbody.innerHTML = interviews.map(i => `
    <tr>
      <td>${fullAppMap[i.application_id] || `App #${i.application_id}`}</td>
      <td class="cell-mono">Round ${i.round}</td>
      <td>${badge(i.interview_type)}</td>
      <td class="cell-muted">${fmtDateTime(i.interview_date)}</td>
      <td>${badge(i.outcome)}</td>
      <td class="cell-muted" style="max-width:180px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;" title="${i.notes || ''}">${i.notes || '—'}</td>
      <td style="text-align:right;white-space:nowrap;">
        <button class="btn btn-ghost btn-sm" onclick="openEditModal(${i.id})">Edit</button>
        <button class="btn btn-danger btn-sm" onclick="deleteInterview(${i.id})">Delete</button>
      </td>
    </tr>
  `).join('');
}

function onFilter() {
  currentPage = 1;
  loadInterviews();
}

function goToPage(page) {
  currentPage = page;
  loadInterviews();
}

// ─── MODAL ─────────────────────────────────────────────────

function openAddModal() {
  document.getElementById('modal-title').textContent = 'Log Interview';
  document.getElementById('edit-id').value = '';
  document.getElementById('f-application-id').value = '';
  document.getElementById('f-round').value  = '1';
  document.getElementById('f-type').value   = 'Phone';
  document.getElementById('f-date').value   = '';
  document.getElementById('f-notes').value  = '';
  document.getElementById('outcome-group').style.display = 'none';
  document.getElementById('modal').classList.add('open');
}

async function openEditModal(id) {
  try {
    const i = await InterviewAPI.getById(id);
    document.getElementById('modal-title').textContent = 'Edit Interview';
    document.getElementById('edit-id').value               = i.id;
    document.getElementById('f-application-id').value     = i.application_id;
    document.getElementById('f-round').value              = i.round;
    document.getElementById('f-type').value               = i.interview_type;
    document.getElementById('f-outcome').value            = i.outcome;
    document.getElementById('f-notes').value              = i.notes || '';

    // Format datetime-local value
    if (i.interview_date) {
      const dt = new Date(i.interview_date);
      const local = new Date(dt.getTime() - dt.getTimezoneOffset() * 60000)
        .toISOString().slice(0, 16);
      document.getElementById('f-date').value = local;
    }

    document.getElementById('outcome-group').style.display = 'block';
    document.getElementById('modal').classList.add('open');
  } catch (e) {
    showToast(e.message, 'error');
  }
}

function closeModal() {
  document.getElementById('modal').classList.remove('open');
}

async function saveInterview() {
  const id    = document.getElementById('edit-id').value;
  const appId = document.getElementById('f-application-id').value;
  const date  = document.getElementById('f-date').value;
  const round = document.getElementById('f-round').value;

  if (!appId) { showToast('Please select an application.', 'error'); return; }
  if (!date)  { showToast('Interview date is required.', 'error'); return; }
  if (!round || round < 1) { showToast('Round must be 1 or higher.', 'error'); return; }

  try {
    if (id) {
      const body = {
        round:          parseInt(round),
        interview_date: new Date(date).toISOString(),
        interview_type: document.getElementById('f-type').value,
        outcome:        document.getElementById('f-outcome').value,
        notes:          document.getElementById('f-notes').value.trim() || null,
      };
      await InterviewAPI.update(id, body);
      showToast('Interview updated.', 'success');
    } else {
      const body = {
        application_id: parseInt(appId),
        round:          parseInt(round),
        interview_date: new Date(date).toISOString(),
        interview_type: document.getElementById('f-type').value,
        notes:          document.getElementById('f-notes').value.trim() || null,
      };
      await InterviewAPI.create(body);
      showToast('Interview logged.', 'success');
    }
    closeModal();
    loadInterviews();
  } catch (e) {
    showToast(e.message, 'error');
  }
}

async function deleteInterview(id) {
  const deleted = await confirmDelete(`Interview #${id}`, () => InterviewAPI.delete(id));
  if (deleted) loadInterviews();
}

document.getElementById('modal').addEventListener('click', function (e) {
  if (e.target === this) closeModal();
});

// ─── INIT ──────────────────────────────────────────────────
(async () => {
  await loadFullAppMap();
  await loadApplicationOptions();
  await loadInterviews();
})();
