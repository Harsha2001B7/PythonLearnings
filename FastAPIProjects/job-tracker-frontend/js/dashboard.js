/* ============================================================
   dashboard.js — index.html logic
============================================================ */

const PIPELINE_COLORS = {
  Applied:   '#475569',
  Screening: '#F59E0B',
  Interview: '#3B82F6',
  Offer:     '#8B5CF6',
  Accepted:  '#10B981',
  Rejected:  '#EF4444',
};

let allApps = [];

async function init() {
  try {
    // Fetch up to 100 applications for dashboard summary
    const data = await ApplicationAPI.getAll({ page: 1, page_size: 100 });
    allApps = data.applications || [];
    renderStats(allApps);
    renderPipeline(allApps);
    renderRecent(allApps.slice(0, 10));
  } catch (e) {
    showToast('Failed to load dashboard data: ' + e.message, 'error');
  }
}

function renderStats(apps) {
  const count = (status) => apps.filter(a => a.status === status).length;

  document.getElementById('stat-total').textContent    = apps.length;
  document.getElementById('stat-active').textContent   = count('Screening') + count('Interview');
  document.getElementById('stat-offers').textContent   = count('Offer');
  document.getElementById('stat-accepted').textContent = count('Accepted');
  document.getElementById('stat-rejected').textContent = count('Rejected');
}

function renderPipeline(apps) {
  const stages = ['Applied', 'Screening', 'Interview', 'Offer', 'Accepted', 'Rejected'];
  const counts = {};
  stages.forEach(s => counts[s] = 0);
  apps.forEach(a => { if (counts[a.status] !== undefined) counts[a.status]++; });

  const total = apps.length || 1;

  const bar = document.getElementById('pipeline-bar');
  const legend = document.getElementById('pipeline-legend');

  bar.innerHTML = stages
    .filter(s => counts[s] > 0)
    .map(s => {
      const pct = (counts[s] / total * 100).toFixed(1);
      return `<div class="pipeline-seg" style="flex:${counts[s]};background:${PIPELINE_COLORS[s]};" title="${s}: ${counts[s]}">${counts[s] > 1 ? counts[s] : ''}</div>`;
    }).join('');

  legend.innerHTML = stages
    .filter(s => counts[s] > 0)
    .map(s => `<span style="display:flex;align-items:center;gap:5px;"><span style="width:10px;height:10px;border-radius:2px;background:${PIPELINE_COLORS[s]};display:inline-block;"></span>${s} (${counts[s]})</span>`)
    .join('');
}

function renderRecent(apps) {
  const tbody = document.getElementById('recent-table');

  if (!apps.length) {
    tbody.innerHTML = `<tr><td colspan="4"><div class="empty"><p>No applications yet. <a href="applications.html" style="color:var(--blue)">Add your first one →</a></p></div></td></tr>`;
    return;
  }

  // Sort by applied_date desc
  const sorted = [...apps].sort((a, b) => new Date(b.applied_date) - new Date(a.applied_date));

  tbody.innerHTML = sorted.slice(0, 10).map(app => `
    <tr>
      <td>${app.company_id}</td>
      <td>${app.role}</td>
      <td>${badge(app.status)}</td>
      <td class="cell-muted">${fmtDate(app.applied_date)}</td>
    </tr>
  `).join('');

  // Enrich company names
  enrichCompanyNames(sorted.slice(0, 10), tbody, 0);
}

async function enrichCompanyNames(apps, tbody, colIndex) {
  // Fetch all companies once to map IDs to names
  try {
    const data = await CompanyAPI.getAll(1, 100);
    const map = {};
    (data.companies || []).forEach(c => map[c.id] = c.name);

    const rows = tbody.querySelectorAll('tr');
    rows.forEach((row, i) => {
      const cells = row.querySelectorAll('td');
      if (cells[colIndex] && apps[i]) {
        cells[colIndex].textContent = map[apps[i].company_id] || `Company #${apps[i].company_id}`;
      }
    });
  } catch (_) {}
}

init();
