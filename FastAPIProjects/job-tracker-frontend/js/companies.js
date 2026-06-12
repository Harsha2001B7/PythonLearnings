/* ============================================================
   companies.js — companies.html logic
============================================================ */

let currentPage = 1;
const PAGE_SIZE = 15;
let allCompanies = [];
let searchQuery = '';

async function loadCompanies() {
  const tbody = document.getElementById('companies-table');
  tbody.innerHTML = `<tr><td colspan="6"><div class="loading"><div class="spinner"></div> Loading…</div></td></tr>`;

  try {
    const data = await CompanyAPI.getAll(currentPage, PAGE_SIZE);
    allCompanies = data.companies || [];
    renderTable(allCompanies);
    renderPagination('pagination', data.total, currentPage, PAGE_SIZE, 'goToPage');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="6" style="padding:24px;color:var(--red);text-align:center;">${e.message}</td></tr>`;
    showToast(e.message, 'error');
  }
}

function renderTable(companies) {
  const tbody = document.getElementById('companies-table');
  const filtered = companies.filter(c =>
    !searchQuery || c.name.toLowerCase().includes(searchQuery)
  );

  if (!filtered.length) {
    tbody.innerHTML = `<tr><td colspan="6"><div class="empty"><p>${searchQuery ? 'No companies match your search.' : 'No companies yet. Add your first one above.'}</p></div></td></tr>`;
    return;
  }

  tbody.innerHTML = filtered.map(c => `
    <tr>
      <td><strong>${c.name}</strong></td>
      <td class="cell-muted">${c.industry || '—'}</td>
      <td class="cell-muted">${c.location || '—'}</td>
      <td>${c.website ? `<a class="row-link" href="${c.website}" target="_blank" rel="noopener">Visit ↗</a>` : '—'}</td>
      <td class="cell-muted">${fmtDate(c.created_at)}</td>
      <td style="text-align:right;">
        <button class="btn btn-ghost btn-sm" onclick="openEditModal(${c.id})">Edit</button>
        <button class="btn btn-danger btn-sm" onclick="deleteCompany(${c.id}, '${c.name.replace(/'/g, "\\'")}')">Delete</button>
      </td>
    </tr>
  `).join('');
}

function onSearch() {
  searchQuery = document.getElementById('search-input').value.trim().toLowerCase();
  renderTable(allCompanies);
}

function goToPage(page) {
  currentPage = page;
  loadCompanies();
}

// ─── MODAL ─────────────────────────────────────────────────

function openAddModal() {
  document.getElementById('modal-title').textContent = 'Add Company';
  document.getElementById('edit-id').value = '';
  document.getElementById('f-name').value = '';
  document.getElementById('f-industry').value = '';
  document.getElementById('f-location').value = '';
  document.getElementById('f-website').value = '';
  document.getElementById('modal').classList.add('open');
  document.getElementById('f-name').focus();
}

async function openEditModal(id) {
  try {
    const c = await CompanyAPI.getById(id);
    document.getElementById('modal-title').textContent = 'Edit Company';
    document.getElementById('edit-id').value = c.id;
    document.getElementById('f-name').value     = c.name || '';
    document.getElementById('f-industry').value = c.industry || '';
    document.getElementById('f-location').value = c.location || '';
    document.getElementById('f-website').value  = c.website || '';
    document.getElementById('modal').classList.add('open');
  } catch (e) {
    showToast(e.message, 'error');
  }
}

function closeModal() {
  document.getElementById('modal').classList.remove('open');
}

async function saveCompany() {
  const id   = document.getElementById('edit-id').value;
  const name = document.getElementById('f-name').value.trim();

  if (!name) { showToast('Company name is required.', 'error'); return; }

  const body = {
    name,
    industry: document.getElementById('f-industry').value.trim() || null,
    location: document.getElementById('f-location').value.trim() || null,
    website:  document.getElementById('f-website').value.trim()  || null,
  };

  try {
    if (id) {
      await CompanyAPI.update(id, body);
      showToast('Company updated.', 'success');
    } else {
      await CompanyAPI.create(body);
      showToast('Company added.', 'success');
    }
    closeModal();
    loadCompanies();
  } catch (e) {
    showToast(e.message, 'error');
  }
}

async function deleteCompany(id, name) {
  const deleted = await confirmDelete(name, () => CompanyAPI.delete(id));
  if (deleted) loadCompanies();
}

// Close modal on overlay click
document.getElementById('modal').addEventListener('click', function (e) {
  if (e.target === this) closeModal();
});

loadCompanies();
