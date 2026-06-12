/* ============================================================
   contacts.js — contacts.html logic
============================================================ */

let currentPage = 1;
const PAGE_SIZE = 15;
let companyMap = {};
let allContacts = [];
let searchQuery = '';

async function loadCompanyOptions() {
  try {
    const data = await CompanyAPI.getAll(1, 100);
    const companies = data.companies || [];
    companies.forEach(c => companyMap[c.id] = c.name);

    const filterSel = document.getElementById('filter-company');
    const modalSel  = document.getElementById('f-company-id');

    companies.forEach(c => {
      [filterSel, modalSel].forEach(sel => {
        const opt = document.createElement('option');
        opt.value = c.id;
        opt.textContent = c.name;
        sel.appendChild(opt);
      });
    });
  } catch (e) {
    showToast('Could not load companies: ' + e.message, 'error');
  }
}

async function loadContacts() {
  const tbody = document.getElementById('contacts-table');
  tbody.innerHTML = `<tr><td colspan="6"><div class="loading"><div class="spinner"></div> Loading…</div></td></tr>`;

  const companyId = document.getElementById('filter-company').value;

  try {
    const data = await ContactAPI.getAll({
      page: currentPage,
      page_size: PAGE_SIZE,
      company_id: companyId || undefined,
    });
    allContacts = data.contacts || [];
    renderTable(allContacts);
    renderPagination('pagination', data.total, currentPage, PAGE_SIZE, 'goToPage');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="6" style="padding:24px;color:var(--red);text-align:center;">${e.message}</td></tr>`;
    showToast(e.message, 'error');
  }
}

function renderTable(contacts) {
  const tbody = document.getElementById('contacts-table');
  const filtered = contacts.filter(c =>
    !searchQuery || c.name.toLowerCase().includes(searchQuery)
  );

  if (!filtered.length) {
    tbody.innerHTML = `<tr><td colspan="6"><div class="empty"><p>${searchQuery ? 'No contacts match your search.' : 'No contacts yet.'}</p></div></td></tr>`;
    return;
  }

  tbody.innerHTML = filtered.map(c => `
    <tr>
      <td><strong>${c.name}</strong></td>
      <td class="cell-muted">${c.role || '—'}</td>
      <td>${companyMap[c.company_id] || `#${c.company_id}`}</td>
      <td>${c.email ? `<a class="row-link" href="mailto:${c.email}">${c.email}</a>` : '—'}</td>
      <td>${c.linkedin ? `<a class="row-link" href="${c.linkedin.startsWith('http') ? c.linkedin : 'https://' + c.linkedin}" target="_blank" rel="noopener">Profile ↗</a>` : '—'}</td>
      <td style="text-align:right;white-space:nowrap;">
        <button class="btn btn-ghost btn-sm" onclick="openEditModal(${c.id})">Edit</button>
        <button class="btn btn-danger btn-sm" onclick="deleteContact(${c.id}, '${c.name.replace(/'/g, "\\'")}')">Delete</button>
      </td>
    </tr>
  `).join('');
}

function onSearch() {
  searchQuery = document.getElementById('search-input').value.trim().toLowerCase();
  renderTable(allContacts);
}

function onFilter() {
  currentPage = 1;
  loadContacts();
}

function goToPage(page) {
  currentPage = page;
  loadContacts();
}

// ─── MODAL ─────────────────────────────────────────────────

function openAddModal() {
  document.getElementById('modal-title').textContent = 'Add Contact';
  document.getElementById('edit-id').value = '';
  document.getElementById('f-company-id').value = '';
  document.getElementById('f-name').value     = '';
  document.getElementById('f-role').value     = '';
  document.getElementById('f-email').value    = '';
  document.getElementById('f-linkedin').value = '';
  document.getElementById('modal').classList.add('open');
  document.getElementById('f-name').focus();
}

async function openEditModal(id) {
  try {
    const c = await ContactAPI.getById(id);
    document.getElementById('modal-title').textContent = 'Edit Contact';
    document.getElementById('edit-id').value            = c.id;
    document.getElementById('f-company-id').value      = c.company_id;
    document.getElementById('f-name').value            = c.name || '';
    document.getElementById('f-role').value            = c.role || '';
    document.getElementById('f-email').value           = c.email || '';
    document.getElementById('f-linkedin').value        = c.linkedin || '';
    document.getElementById('modal').classList.add('open');
  } catch (e) {
    showToast(e.message, 'error');
  }
}

function closeModal() {
  document.getElementById('modal').classList.remove('open');
}

async function saveContact() {
  const id        = document.getElementById('edit-id').value;
  const companyId = document.getElementById('f-company-id').value;
  const name      = document.getElementById('f-name').value.trim();

  if (!companyId) { showToast('Please select a company.', 'error'); return; }
  if (!name)      { showToast('Name is required.', 'error'); return; }

  const body = {
    company_id: parseInt(companyId),
    name,
    role:     document.getElementById('f-role').value.trim()     || null,
    email:    document.getElementById('f-email').value.trim()    || null,
    linkedin: document.getElementById('f-linkedin').value.trim() || null,
  };

  try {
    if (id) {
      const updateBody = { ...body };
      delete updateBody.company_id;
      await ContactAPI.update(id, updateBody);
      showToast('Contact updated.', 'success');
    } else {
      await ContactAPI.create(body);
      showToast('Contact added.', 'success');
    }
    closeModal();
    loadContacts();
  } catch (e) {
    showToast(e.message, 'error');
  }
}

async function deleteContact(id, name) {
  const deleted = await confirmDelete(name, () => ContactAPI.delete(id));
  if (deleted) loadContacts();
}

document.getElementById('modal').addEventListener('click', function (e) {
  if (e.target === this) closeModal();
});

(async () => {
  await loadCompanyOptions();
  await loadContacts();
})();
