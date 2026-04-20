/* SmartBus Super Admin Dashboard JS — v3 (wrapped in IIFE, isolated from global scope; explicit exports at bottom) */
(function () {
'use strict';

// ── State ──────────────────────────────────────────────────────────────────
let schoolsPage = 1, schoolsTotalPages = 1;
let _currentFilter = 'all';
let _allSchools = [];        // current page items
let _filteredSchools = [];   // post-filter/search items
let _selectedIds = new Set();
let _drawerSchool = null;    // school object currently in drawer
let _searchQuery = '';

const pageNames = {
  overview: window.T?.pageOverview  || 'نظرة عامة',
  schools:  window.T?.pageSchools   || 'إدارة المدارس',
  admins:   window.T?.pageAdmins    || 'المديرون',
  plans:    window.T?.pagePlans     || 'خطط الاشتراك',
  settings: window.T?.pageSettings  || 'الإعدادات'
};
const planLabels  = { 0: 'أساسية', 1: 'معيارية', 2: 'مميزة ⭐' };
const planClasses = { 0: 'plan-basic', 1: 'plan-standard', 2: 'plan-premium' };

// ── Init ───────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  setDateChip();
  loadOverview();

  // Close modals on overlay click
  document.querySelectorAll('.modal-overlay').forEach(o => {
    o.addEventListener('click', e => { if (e.target === o) o.classList.remove('open'); });
  });
});

function setDateChip() {
  const el = document.getElementById('sa-date-chip');
  if (!el) return;
  const days   = ['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
  const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
  const d = new Date();
  el.textContent = `${days[d.getDay()]}، ${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`;
}

// ── Navigation ─────────────────────────────────────────────────────────────
function showPage(id, navEl) {
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  const page = document.getElementById('sa-page-' + id);
  if (page) page.classList.add('active');
  if (navEl) navEl.classList.add('active');
  setText('sa-page-title', pageNames[id] || id);

  // Show/hide topbar search & export only on schools page
  const topbarSearch = document.getElementById('topbar-search');
  const btnExport    = document.getElementById('btn-export');
  if (topbarSearch) topbarSearch.style.display = id === 'schools' ? '' : 'none';
  if (btnExport)    btnExport.style.display    = id === 'schools' ? '' : 'none';

  if (id === 'schools') { _searchQuery = ''; clearSearchUI(); loadSchools(1); }
  if (id === 'plans')   loadPlanStats();
  if (id === 'admins')  loadAdmins();
  if (id === 'overview') loadOverview();
}

// ── API Helpers ────────────────────────────────────────────────────────────
async function apiGet(path) {
  try {
    const res = await fetch('/api-proxy' + path, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    if (!res.ok) return null;
    return await res.json();
  } catch { return null; }
}

async function apiPost(path, body) {
  try {
    const res = await fetch('/api-proxy' + path, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
      body: JSON.stringify(body)
    });
    return { ok: res.ok, data: await res.json().catch(() => null) };
  } catch { return { ok: false, data: null }; }
}

async function apiPut(path, body) {
  try {
    const res = await fetch('/api-proxy' + path, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
      body: JSON.stringify(body)
    });
    return { ok: res.ok, data: await res.json().catch(() => null) };
  } catch { return { ok: false, data: null }; }
}

async function apiDelete(path) {
  try {
    const res = await fetch('/api-proxy' + path, {
      method: 'DELETE', headers: { 'X-Requested-With': 'XMLHttpRequest' }
    });
    return res.ok;
  } catch { return false; }
}

// ── Overview ───────────────────────────────────────────────────────────────
async function loadOverview() {
  const data = await apiGet('/schools?pageNumber=1&pageSize=100');
  if (!data) return;

  const items = data.items || [];
  _allSchools = items;
  const total  = data.totalCount || 0;
  const active = items.filter(s => s.isActive).length;
  const premium = items.filter(s => s.plan === 2).length;
  const totalBuses = items.reduce((sum, s) => sum + (s.maxBuses || 0), 0);

  animateCounter('stat-total-schools', total);
  animateCounter('stat-premium', premium);
  animateCounter('stat-buses', totalBuses);
  animateCounter('stat-admins', active);
  setText('stat-active-schools', `${active} نشطة`);
  setText('schools-count-badge', total);

  const tbody = document.getElementById('overview-schools-tbody');
  if (!tbody) return;
  if (!items.length) {
    tbody.innerHTML = `<tr><td colspan="5"><div class="empty-state" style="padding:32px 24px;">
      <div class="empty-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2" stroke-linecap="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg></div>
      <div class="empty-title">لا توجد مدارس بعد</div>
      <div class="empty-sub">ابدأ بإضافة أول مدرسة في المنصة</div>
    </div></td></tr>`;
  } else {
    tbody.innerHTML = items.slice(0, 5).map(s => renderOverviewRow(s)).join('');
  }
}

function renderOverviewRow(s) {
  const planClass = planClasses[s.plan] || 'plan-basic';
  const planLabel = planLabels[s.plan] || 'أساسية';
  const statusLabel = s.isActive ? '<span style="color:#15803D;font-weight:700;">نشطة ●</span>' : '<span style="color:#94A3B8;">موقوفة</span>';
  return `<tr>
    <td><div class="td-name">${escHtml(s.name)}</div><div class="td-sub">${escHtml(s.contactEmail)}</div></td>
    <td>${escHtml(s.city)}</td>
    <td><span class="plan-badge ${planClass}">${planLabel}</span></td>
    <td style="font-weight:700;">${s.maxBuses}</td>
    <td>${statusLabel}</td>
  </tr>`;
}

// ── Schools ────────────────────────────────────────────────────────────────
async function loadSchools(page) {
  if (page < 1) return;
  if (page > schoolsTotalPages && schoolsTotalPages > 0) return;
  schoolsPage = page;

  // show skeleton
  showSchoolsSkeleton();

  const data = await apiGet(`/schools?pageNumber=${page}&pageSize=10`);
  const tbody = document.getElementById('schools-tbody');
  if (!data || !tbody) { if (tbody) tbody.innerHTML = '<tr><td colspan="9" style="text-align:center;padding:32px;color:var(--text3);">تعذر تحميل البيانات</td></tr>'; return; }

  schoolsTotalPages = data.totalPages || 1;
  _allSchools = data.items || [];
  _selectedIds.clear();
  updateBulkBar();

  setText('schools-pager-info', `عرض ${_allSchools.length} من ${data.totalCount} مدرسة`);
  setText('schools-pager-num', `${page} / ${schoolsTotalPages}`);
  setText('schools-total', data.totalCount || 0);
  setText('schools-count-badge', data.totalCount || 0);
  updatePager('schools', page, schoolsTotalPages);

  // re-apply search + filter
  applyFilterAndSearch();
}

function showSchoolsSkeleton() {
  const tbody = document.getElementById('schools-tbody');
  if (!tbody) return;
  tbody.innerHTML = [1,2,3,4].map(() => `<tr class="skel-row">
    <td></td>
    <td><div class="skel" style="height:16px;width:150px;"></div></td>
    <td><div class="skel" style="height:14px;width:80px;"></div></td>
    <td><div class="skel" style="height:14px;width:120px;"></div></td>
    <td><div class="skel" style="height:14px;width:60px;"></div></td>
    <td><div class="skel" style="height:14px;width:30px;"></div></td>
    <td><div class="skel" style="height:14px;width:90px;"></div></td>
    <td><div class="skel" style="height:14px;width:55px;"></div></td>
    <td></td>
  </tr>`).join('');
}

function applyFilterAndSearch() {
  let items = [..._allSchools];

  // filter
  if (_currentFilter === 'active')   items = items.filter(s => s.isActive);
  else if (_currentFilter === 'inactive') items = items.filter(s => !s.isActive);
  else if (_currentFilter === 'premium')  items = items.filter(s => s.plan === 2);

  // search
  if (_searchQuery) {
    const q = _searchQuery.toLowerCase();
    items = items.filter(s =>
      (s.name || '').toLowerCase().includes(q) ||
      (s.city || '').toLowerCase().includes(q) ||
      (s.contactEmail || '').toLowerCase().includes(q) ||
      (s.adminEmail || '').toLowerCase().includes(q)
    );
  }

  _filteredSchools = items;
  renderSchoolsTable(items);
}

function renderSchoolsTable(items) {
  const tbody = document.getElementById('schools-tbody');
  if (!tbody) return;

  if (!items.length) {
    const isSearching = !!_searchQuery;
    tbody.innerHTML = `<tr><td colspan="9"><div class="empty-state">
      <div class="empty-icon">
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2" stroke-linecap="round">
          ${isSearching
            ? '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>'
            : '<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>'}
        </svg>
      </div>
      <div class="empty-title">${isSearching ? 'لا توجد نتائج' : 'لا توجد مدارس'}</div>
      <div class="empty-sub">${isSearching ? `لم يتم إيجاد مدارس تطابق "<strong>${escHtml(_searchQuery)}</strong>"` : 'ابدأ بإضافة أول مدرسة في المنصة'}</div>
      ${isSearching ? `<button class="btn-secondary" style="margin-top:12px;" onclick="clearSearch()">مسح البحث</button>` : `<button class="add-btn" style="margin:16px auto 0;" onclick="openSchoolModal()"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#111" stroke-width="3" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>إضافة مدرسة</button>`}
    </div></td></tr>`;
    const chkAll = document.getElementById('chk-all');
    if (chkAll) chkAll.checked = false;
    return;
  }

  tbody.innerHTML = items.map(s => renderSchoolRow(s)).join('');

  // restore selection state for visible rows
  items.forEach(s => {
    const chk = document.getElementById(`chk-${s.id}`);
    if (chk) chk.checked = _selectedIds.has(s.id);
    const row = chk?.closest('tr');
    if (row) row.classList.toggle('selected', _selectedIds.has(s.id));
  });

  const chkAll = document.getElementById('chk-all');
  if (chkAll) {
    const visibleIds = items.map(s => s.id);
    chkAll.checked = visibleIds.length > 0 && visibleIds.every(id => _selectedIds.has(id));
    chkAll.indeterminate = !chkAll.checked && visibleIds.some(id => _selectedIds.has(id));
  }
}

function renderSchoolRow(s) {
  const planClass = planClasses[s.plan] || 'plan-basic';
  const planLabel = planLabels[s.plan] || 'أساسية';
  const statusBg = s.isActive ? '#F0FDF4' : '#F1F5F9';
  const statusColor = s.isActive ? '#15803D' : '#475569';
  const statusLabel = s.isActive ? 'نشطة ●' : 'موقوفة';
  const initials = s.name ? s.name.trim().split(' ').map(w => w[0]).slice(0, 2).join('') : '؟';
  const av = getAvatarColor(s.id);
  const name = highlight(escHtml(s.name), _searchQuery);
  const city = highlight(escHtml(s.city), _searchQuery);
  const admin = highlight(escHtml(s.adminEmail), _searchQuery);
  const email = highlight(escHtml(s.contactEmail), _searchQuery);
  const isChecked = _selectedIds.has(s.id) ? 'checked' : '';
  const isSelected = _selectedIds.has(s.id) ? 'selected' : '';

  return `<tr class="${isSelected}" id="row-${s.id}">
    <td onclick="event.stopPropagation()">
      <input type="checkbox" class="cb" id="chk-${s.id}" ${isChecked}
        onchange="toggleRowSelect('${s.id}',this.checked)"/>
    </td>
    <td onclick="openDrawer(getSchoolById('${s.id}'))" style="cursor:pointer;">
      <div style="display:flex;align-items:center;gap:10px;">
        <div style="width:34px;height:34px;border-radius:10px;background:${av.bg};color:${av.text};display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:800;flex-shrink:0;">${initials}</div>
        <div><div class="td-name">${name}</div><div class="td-sub">${email}</div></div>
      </div>
    </td>
    <td onclick="openDrawer(getSchoolById('${s.id}'))">${city}</td>
    <td onclick="openDrawer(getSchoolById('${s.id}'))">${admin}</td>
    <td onclick="openDrawer(getSchoolById('${s.id}'))"><span class="plan-badge ${planClass}">${planLabel}</span></td>
    <td onclick="openDrawer(getSchoolById('${s.id}'))" style="font-weight:700;">${s.maxBuses}</td>
    <td onclick="openDrawer(getSchoolById('${s.id}'))">${formatDate(s.createdAt)}</td>
    <td onclick="event.stopPropagation()">
      <button class="st-toggle ${s.isActive ? 'on' : 'off'}" title="${s.isActive ? 'إيقاف' : 'تفعيل'}"
        onclick="toggleStatus('${s.id}', ${s.isActive})">
        <span class="st-toggle-knob"></span>
      </button>
    </td>
    <td onclick="event.stopPropagation()">
      <div class="tbl-actions">
        <button class="tbl-btn tbl-view" title="عرض التفاصيل" onclick="openDrawer(getSchoolById('${s.id}'))">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2.5" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
        </button>
        <button class="tbl-btn tbl-edit" title="تعديل" onclick="openEditSchool(getSchoolById('${s.id}'))">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4z"/></svg>
        </button>
        <button class="tbl-btn tbl-del" title="حذف" onclick="confirmDeleteSchool('${escHtml(s.name)}','${s.id}')">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
        </button>
      </div>
    </td>
  </tr>`;
}

// ── Detail Drawer ──────────────────────────────────────────────────────────
function openDrawer(school) {
  if (!school) return;
  _drawerSchool = school;

  const initials = school.name ? school.name.trim().split(' ').map(w => w[0]).slice(0, 2).join('') : '؟';
  setText('drw-avatar', initials);
  setText('drw-name', school.name);
  setText('drw-city', school.city);
  setText('drw-email', school.contactEmail);
  setText('drw-phone', school.phoneNumber);
  setText('drw-admin', school.adminEmail);
  setText('drw-max-buses', school.maxBuses);
  setText('drw-date', `أُنشئت ${formatDate(school.createdAt)}`);

  const planBadge = document.getElementById('drw-plan-badge');
  if (planBadge) {
    planBadge.className = `plan-badge ${planClasses[school.plan] || 'plan-basic'}`;
    planBadge.textContent = planLabels[school.plan] || 'أساسية';
  }
  setText('drw-plan-big', planLabels[school.plan] || 'أساسية');

  const statusBadge = document.getElementById('drw-status-badge');
  if (statusBadge) {
    statusBadge.style.background = school.isActive ? '#F0FDF4' : '#F1F5F9';
    statusBadge.style.color = school.isActive ? '#15803D' : '#475569';
    statusBadge.textContent = school.isActive ? 'نشطة ●' : 'موقوفة';
  }

  const toggleBtn = document.getElementById('drw-toggle-btn');
  if (toggleBtn) toggleBtn.textContent = school.isActive ? 'إيقاف تشغيل' : 'تفعيل';

  // notes section
  const notesSection = document.getElementById('drw-notes-section');
  if (notesSection) {
    notesSection.style.display = school.notes ? '' : 'none';
    setText('drw-notes', school.notes || '');
  }

  // highlight active plan button
  document.querySelectorAll('.plan-quick-btn').forEach(btn => {
    btn.style.fontWeight = parseInt(btn.dataset.plan) === school.plan ? '800' : '600';
    btn.style.transform = parseInt(btn.dataset.plan) === school.plan ? 'scale(1.04)' : '';
  });

  document.getElementById('drawer-overlay')?.classList.add('open');
  document.getElementById('school-drawer')?.classList.add('open');
}

function closeDrawer() {
  document.getElementById('drawer-overlay')?.classList.remove('open');
  document.getElementById('school-drawer')?.classList.remove('open');
  _drawerSchool = null;
}

function editFromDrawer() {
  if (!_drawerSchool) return;
  closeDrawer();
  openEditSchool(_drawerSchool);
}

function deleteFromDrawer() {
  if (!_drawerSchool) return;
  const s = _drawerSchool;
  closeDrawer();
  confirmDeleteSchool(s.name, s.id);
}

async function toggleStatusFromDrawer() {
  if (!_drawerSchool) return;
  await toggleStatus(_drawerSchool.id, _drawerSchool.isActive);
  closeDrawer();
}

async function quickChangePlan(planNum) {
  if (!_drawerSchool) return;
  const s = _drawerSchool;
  const body = {
    name: s.name, city: s.city, contactEmail: s.contactEmail,
    phoneNumber: s.phoneNumber, adminEmail: s.adminEmail,
    plan: planNum, maxBuses: s.maxBuses, isActive: s.isActive, notes: s.notes || null
  };
  const res = await apiPut(`/schools/${s.id}`, body);
  if (res?.ok) {
    ShowMessage(`${window.T?.planChanged || 'تم تغيير الخطة إلى'} ${planLabels[planNum]}`, 'success');
    const updated = { ..._drawerSchool, plan: planNum };
    // update cache
    const idx = _allSchools.findIndex(x => x.id === s.id);
    if (idx >= 0) _allSchools[idx] = updated;
    _drawerSchool = updated;
    openDrawer(updated);
    applyFilterAndSearch();
    loadOverview();
  } else {
    ShowMessage(window.T?.planFailed || 'فشل تغيير الخطة', 'error');
  }
}

// ── Status Quick Toggle ────────────────────────────────────────────────────
async function toggleStatus(id, currentIsActive) {
  const school = getSchoolById(id);
  if (!school) return;
  const body = {
    name: school.name, city: school.city, contactEmail: school.contactEmail,
    phoneNumber: school.phoneNumber, adminEmail: school.adminEmail,
    plan: school.plan, maxBuses: school.maxBuses,
    isActive: !currentIsActive, notes: school.notes || null
  };
  const res = await apiPut(`/schools/${id}`, body);
  if (res?.ok) {
    const newVal = !currentIsActive;
    const updated = { ...school, isActive: newVal };
    const idx = _allSchools.findIndex(x => x.id === id);
    if (idx >= 0) _allSchools[idx] = updated;
    ShowMessage(newVal ? (window.T?.statusActivated || 'تم تفعيل المدرسة') : (window.T?.statusDeactivated || 'تم إيقاف المدرسة'), 'success');
    applyFilterAndSearch();
    loadOverview();
  } else {
    ShowMessage(window.T?.statusFailed || 'فشل تغيير الحالة', 'error');
  }
}

// ── Search ─────────────────────────────────────────────────────────────────
function onSearchInput(val) {
  _searchQuery = val.trim();
  const clearBtn = document.getElementById('search-clear');
  if (clearBtn) clearBtn.style.display = _searchQuery ? '' : 'none';
  applyFilterAndSearch();
}

function clearSearch() {
  _searchQuery = '';
  clearSearchUI();
  applyFilterAndSearch();
}

function clearSearchUI() {
  const input = document.getElementById('schools-search-input');
  const clearBtn = document.getElementById('search-clear');
  if (input) input.value = '';
  if (clearBtn) clearBtn.style.display = 'none';
}

function highlight(text, query) {
  if (!query) return text;
  const escaped = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return text.replace(new RegExp(`(${escaped})`, 'gi'), '<mark>$1</mark>');
}

// ── Filter ─────────────────────────────────────────────────────────────────
function filterSchools(filter, btn) {
  document.querySelectorAll('#sa-page-schools .filter-btn').forEach(b => b.classList.remove('active'));
  if (btn) btn.classList.add('active');
  _currentFilter = filter;
  applyFilterAndSearch();
}

function applyFilter(filter, items) { // legacy compat
  _currentFilter = filter;
  applyFilterAndSearch();
}

// ── Bulk Select ────────────────────────────────────────────────────────────
function toggleSelectAll(checked) {
  _filteredSchools.forEach(s => {
    if (checked) _selectedIds.add(s.id);
    else _selectedIds.delete(s.id);
    const chk = document.getElementById(`chk-${s.id}`);
    const row = document.getElementById(`row-${s.id}`);
    if (chk) chk.checked = checked;
    if (row) row.classList.toggle('selected', checked);
  });
  updateBulkBar();
}

function toggleRowSelect(id, checked) {
  if (checked) _selectedIds.add(id);
  else _selectedIds.delete(id);
  const row = document.getElementById(`row-${id}`);
  if (row) row.classList.toggle('selected', checked);

  // update select-all state
  const chkAll = document.getElementById('chk-all');
  if (chkAll) {
    const visibleIds = _filteredSchools.map(s => s.id);
    chkAll.checked = visibleIds.length > 0 && visibleIds.every(i => _selectedIds.has(i));
    chkAll.indeterminate = !chkAll.checked && visibleIds.some(i => _selectedIds.has(i));
  }
  updateBulkBar();
}

function clearSelection() {
  _selectedIds.clear();
  document.querySelectorAll('.cb').forEach(c => { c.checked = false; c.indeterminate = false; });
  document.querySelectorAll('.table tr.selected').forEach(r => r.classList.remove('selected'));
  updateBulkBar();
}

function updateBulkBar() {
  const bar = document.getElementById('bulk-bar');
  const label = document.getElementById('bulk-count-label');
  if (!bar) return;
  const count = _selectedIds.size;
  bar.style.display = count > 0 ? 'flex' : 'none';
  if (label) label.textContent = `${count} ${count === 1 ? 'مدرسة محددة' : 'مدارس محددة'}`;
}

async function bulkDelete() {
  const count = _selectedIds.size;
  if (!count) return;
  const ids = [..._selectedIds];

  document.getElementById('del-count-label').textContent = `${count} مدارس`;
  document.getElementById('del-school-name').textContent = ids.length === 1
    ? (getSchoolById(ids[0])?.name || '') : `(${count} مدارس)`;

  const btn = document.getElementById('del-confirm-btn');
  btn.onclick = async () => {
    closeModal('modal-delete');
    let failed = 0;
    for (const id of ids) {
      const ok = await apiDelete(`/schools/${id}`);
      if (!ok) failed++;
    }
    _selectedIds.clear();
    if (failed === 0) ShowMessage(`تم حذف ${count} مدارس بنجاح`, 'success');
    else ShowMessage(`تم حذف ${count - failed}، فشل ${failed}`, 'error');
    loadSchools(schoolsPage);
    loadOverview();
  };
  openModal('modal-delete');
}

// ── CSV Export ─────────────────────────────────────────────────────────────
function exportCSV() {
  const items = _filteredSchools.length ? _filteredSchools : _allSchools;
  if (!items.length) { ShowMessage(window.T?.exportNoData || 'لا توجد بيانات للتصدير', 'error'); return; }

  const headers = ['الاسم', 'المدينة', 'البريد الإلكتروني', 'الهاتف', 'بريد المدير', 'الخطة', 'أقصى باصات', 'الحالة', 'تاريخ الإنشاء'];
  const rows = items.map(s => [
    s.name, s.city, s.contactEmail, s.phoneNumber, s.adminEmail,
    planLabels[s.plan] || s.plan, s.maxBuses,
    s.isActive ? 'نشطة' : 'موقوفة',
    formatDate(s.createdAt)
  ].map(v => `"${String(v ?? '').replace(/"/g, '""')}"`).join(','));

  const csv = '\uFEFF' + [headers.join(','), ...rows].join('\r\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `schools_${new Date().toISOString().slice(0, 10)}.csv`;
  a.click();
  URL.revokeObjectURL(url);
  ShowMessage(`${window.T?.exportDone || 'تم تصدير'} ${items.length} ${window.T?.exportCSV || 'مدارس كـ CSV'}`, 'success');
}

// ── School Modal ───────────────────────────────────────────────────────────
function openSchoolModal() {
  clearSchoolForm();
  setText('school-modal-title', 'إضافة مدرسة جديدة');
  document.getElementById('sch-id').value = '';
  // Show password field only when creating
  const pwGroup = document.getElementById('sch-password-group');
  if (pwGroup) pwGroup.style.display = '';
  openModal('modal-school');
}

function openEditSchool(data) {
  if (!data) return;
  clearSchoolForm();
  setText('school-modal-title', 'تعديل بيانات المدرسة');
  document.getElementById('sch-id').value = data.id || '';
  // Hide password field when editing (password was set at creation)
  const pwGroup = document.getElementById('sch-password-group');
  if (pwGroup) pwGroup.style.display = 'none';
  document.getElementById('sch-name').value = data.name || '';
  document.getElementById('sch-city').value = data.city || '';
  document.getElementById('sch-email').value = data.contactEmail || '';
  document.getElementById('sch-phone').value = data.phoneNumber || '';
  document.getElementById('sch-admin').value = data.adminEmail || '';
  document.getElementById('sch-plan').value = String(data.plan ?? 0);
  document.getElementById('sch-buses').value = data.maxBuses || 5;
  document.getElementById('sch-active').value = String(data.isActive !== false);
  document.getElementById('sch-notes').value = data.notes || '';
  openModal('modal-school');
}

function clearSchoolForm() {
  ['sch-name','sch-city','sch-email','sch-phone','sch-admin'].forEach(id => {
    const el = document.getElementById(id);
    if (el) { el.value = ''; el.classList.remove('err'); }
  });
  ['err-sch-name','err-sch-city','err-sch-email','err-sch-phone','err-sch-admin'].forEach(id => {
    document.getElementById(id)?.classList.remove('show');
  });
  const buses = document.getElementById('sch-buses');    if (buses) buses.value = '5';
  const plan  = document.getElementById('sch-plan');     if (plan)  plan.value  = '0';
  const act   = document.getElementById('sch-active');   if (act)   act.value   = 'true';
  const notes = document.getElementById('sch-notes');    if (notes) notes.value = '';
  const pw    = document.getElementById('sch-password'); if (pw)    pw.value    = '';
}

async function saveSchool() {
  // inline validation
  let valid = true;
  const required = [
    { id: 'sch-name',  err: 'err-sch-name',  test: v => v.length > 0 },
    { id: 'sch-city',  err: 'err-sch-city',  test: v => v.length > 0 },
    { id: 'sch-email', err: 'err-sch-email', test: v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) },
    { id: 'sch-phone', err: 'err-sch-phone', test: v => v.length >= 7 },
    { id: 'sch-admin', err: 'err-sch-admin', test: v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) },
  ];
  required.forEach(({ id, err, test }) => {
    const el = document.getElementById(id);
    const errEl = document.getElementById(err);
    const val = el?.value.trim() || '';
    const ok = test(val);
    el?.classList.toggle('err', !ok);
    errEl?.classList.toggle('show', !ok);
    if (!ok) valid = false;
  });
  if (!valid) return;

  const name  = document.getElementById('sch-name').value.trim();
  const city  = document.getElementById('sch-city').value.trim();
  const email = document.getElementById('sch-email').value.trim();
  const phone = document.getElementById('sch-phone').value.trim();
  const admin = document.getElementById('sch-admin').value.trim();
  const id    = document.getElementById('sch-id').value;

  const body = {
    name, city, contactEmail: email, phoneNumber: phone, adminEmail: admin,
    plan: parseInt(document.getElementById('sch-plan').value),
    maxBuses: parseInt(document.getElementById('sch-buses').value) || 5,
    isActive: document.getElementById('sch-active').value === 'true',
    notes: document.getElementById('sch-notes').value.trim() || null,
    adminPassword: document.getElementById('sch-password')?.value.trim() || 'Admin@123456'
  };

  const btn = document.getElementById('btn-save-school');
  if (btn) { btn.disabled = true; btn.textContent = window.T?.saving || 'جاري الحفظ...'; }

  const res = id ? await apiPut(`/schools/${id}`, body) : await apiPost('/schools', body);

  if (btn) { btn.disabled = false; btn.innerHTML = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#111" stroke-width="2.5" stroke-linecap="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>${window.T?.saveSchoolBtn || 'حفظ المدرسة'}`; }

  if (res?.ok) {
    closeModal('modal-school');
    ShowMessage(id ? (window.T?.schoolUpdated || 'تم تحديث بيانات المدرسة ✓') : (window.T?.schoolSaved || 'تمت إضافة المدرسة بنجاح ✓'), 'success');
    loadSchools(schoolsPage);
    loadOverview();
  } else {
    const errMsg = res?.data?.error || 'فشل الحفظ. تحقق من البيانات.';
    ShowMessage(errMsg, 'error');
  }
}

// ── Delete ─────────────────────────────────────────────────────────────────
function confirmDeleteSchool(name, id) {
  document.getElementById('del-count-label').textContent = 'المدرسة';
  document.getElementById('del-school-name').textContent = name;
  const btn = document.getElementById('del-confirm-btn');
  btn.onclick = async () => {
    const ok = await apiDelete(`/schools/${id}`);
    closeModal('modal-delete');
    if (ok) {
      ShowMessage(window.T?.schoolDeleted || 'تم حذف المدرسة بنجاح', 'success');
      _selectedIds.delete(id);
      loadSchools(schoolsPage);
      loadOverview();
    } else {
      ShowMessage(window.T?.schoolDeleteFailed || 'فشل الحذف. حاول مرة أخرى.', 'error');
    }
  };
  openModal('modal-delete');
}

// ── Admins ─────────────────────────────────────────────────────────────────
async function loadAdmins() {
  const data = await apiGet('/schools?pageNumber=1&pageSize=100');
  const tbody = document.getElementById('admins-tbody');
  if (!tbody) return;
  if (!data?.items?.length) {
    tbody.innerHTML = `<tr><td colspan="5"><div class="empty-state"><div class="empty-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2" stroke-linecap="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg></div><div class="empty-title">لا يوجد مديرون بعد</div><div class="empty-sub">أضف مدارس أولاً لتظهر بيانات المديرين هنا</div></div></td></tr>`;
    return;
  }
  tbody.innerHTML = data.items.map(s => {
    const planClass = planClasses[s.plan] || 'plan-basic';
    const planLabel = planLabels[s.plan] || 'أساسية';
    const statusLabel = s.isActive ? '<span style="color:#15803D;font-weight:700;">نشطة ●</span>' : '<span style="color:#94A3B8;">موقوفة</span>';
    return `<tr>
      <td><div class="td-name">${escHtml(s.name)}</div></td>
      <td><div class="td-sub">${escHtml(s.adminEmail)}</div></td>
      <td>${escHtml(s.city)}</td>
      <td><span class="plan-badge ${planClass}">${planLabel}</span></td>
      <td>${statusLabel}</td>
    </tr>`;
  }).join('');
}

// ── Plan Stats ─────────────────────────────────────────────────────────────
async function loadPlanStats() {
  const data = await apiGet('/schools?pageNumber=1&pageSize=100');
  if (!data?.items) return;
  const items = data.items;
  animateCounter('plan-basic-count',    items.filter(s => s.plan === 0).length);
  animateCounter('plan-standard-count', items.filter(s => s.plan === 1).length);
  animateCounter('plan-premium-count',  items.filter(s => s.plan === 2).length);
  animateCounter('plan-total-buses',    items.reduce((sum, s) => sum + (s.maxBuses || 0), 0));
}

// ── Modal ──────────────────────────────────────────────────────────────────
function openModal(id) { document.getElementById(id)?.classList.add('open'); }
function closeModal(id) { document.getElementById(id)?.classList.remove('open'); }

// ── Pager ──────────────────────────────────────────────────────────────────
function updatePager(prefix, page, totalPages) {
  const prev = document.getElementById(`${prefix}-prev`);
  const next = document.getElementById(`${prefix}-next`);
  if (prev) prev.disabled = page <= 1;
  if (next) next.disabled = page >= totalPages;
}

// ── Helpers ────────────────────────────────────────────────────────────────
function getSchoolById(id) {
  return _allSchools.find(s => s.id === id) || null;
}

function setText(id, val) {
  const el = document.getElementById(id);
  if (el) el.textContent = val;
}

function escHtml(str) {
  if (!str) return '';
  return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function formatDate(dt) {
  if (!dt) return '—';
  try { return new Date(dt).toLocaleDateString('ar-EG', { year: 'numeric', month: 'short', day: 'numeric' }); }
  catch { return dt; }
}

const avatarPalette = [
  { bg: '#F5F3FF', text: '#7C3AED' }, { bg: '#EFF6FF', text: '#3B82F6' },
  { bg: '#F0FDF4', text: '#16A34A' }, { bg: '#FFFDE7', text: '#B8960C' },
  { bg: '#FEF2F2', text: '#DC2626' }, { bg: '#FFF7ED', text: '#C2410C' }
];
function getAvatarColor(id) {
  const idx = id ? id.charCodeAt(0) % avatarPalette.length : 0;
  return avatarPalette[idx];
}

function animateCounter(id, target) {
  const el = document.getElementById(id);
  if (!el) return;
  const start = 0, duration = 600;
  const t0 = performance.now();
  const step = ts => {
    const progress = Math.min((ts - t0) / duration, 1);
    const ease = 1 - Math.pow(1 - progress, 3);
    el.textContent = Math.round(start + (target - start) * ease);
    if (progress < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}

function ShowMessage(msg, type = 'success') {
  const icons = {
    success: '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg>',
    error:   '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>'
  };
  const t = document.createElement('div');
  t.className = `toast ${type}`;
  t.innerHTML = `<span class="toast-icon">${icons[type] || icons.success}</span>${escHtml(msg)}`;
  document.body.appendChild(t);
  setTimeout(() => { t.style.opacity = '0'; t.style.transform = 'translateY(10px)'; t.style.transition = 'all .3s'; }, 2700);
  setTimeout(() => t.remove(), 3100);
}

// ── Change Password ────────────────────────────────────────────────────────
function openChangePassword() {
  ['cp-current', 'cp-new', 'cp-confirm'].forEach(id => {
    const el = document.getElementById(id);
    if (el) { el.value = ''; el.classList.remove('err'); }
  });
  ['err-cp-current', 'err-cp-new', 'err-cp-confirm'].forEach(id => {
    document.getElementById(id)?.classList.remove('show');
  });
  const srv = document.getElementById('cp-server-err');
  if (srv) srv.style.display = 'none';
  openModal('modal-change-password');
}

async function changePassword() {
  const current = document.getElementById('cp-current')?.value ?? '';
  const newPwd  = document.getElementById('cp-new')?.value     ?? '';
  const confirm = document.getElementById('cp-confirm')?.value ?? '';

  let valid = true;
  const setErr = (errId, inputId, show) => {
    document.getElementById(errId)?.classList.toggle('show', show);
    document.getElementById(inputId)?.classList.toggle('err', show);
    if (show) valid = false;
  };

  setErr('err-cp-current', 'cp-current', !current);
  setErr('err-cp-new',     'cp-new',     newPwd.length < 8);
  setErr('err-cp-confirm', 'cp-confirm', newPwd !== confirm);
  if (!valid) return;

  const btn = document.getElementById('btn-save-password');
  if (btn) { btn.disabled = true; btn.textContent = window.T?.saving || 'جاري الحفظ...'; }

  const res = await apiPost('/auth/change-password', {
    currentPassword: current,
    newPassword: newPwd
  });

  if (btn) { btn.disabled = false; btn.innerHTML = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#111" stroke-width="2.5" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>حفظ كلمة المرور`; }

  const srv = document.getElementById('cp-server-err');
  if (res?.ok) {
    if (srv) srv.style.display = 'none';
    closeModal('modal-change-password');
    ShowMessage(window.T?.passwordChanged || 'تم تغيير كلمة المرور بنجاح ✓', 'success');
  } else {
    const msg = res?.data?.error || 'فشل تغيير كلمة المرور.';
    if (srv) { srv.textContent = msg; srv.style.display = 'block'; }
  }
}

// ── Window exports ─────────────────────────────────────────────────────────
Object.defineProperty(window, 'schoolsPage', { get: () => schoolsPage });
window.showPage              = showPage;
window.openModal             = openModal;
window.closeModal            = closeModal;
window.openSchoolModal       = openSchoolModal;
window.openEditSchool        = openEditSchool;
window.saveSchool            = saveSchool;
window.confirmDeleteSchool   = confirmDeleteSchool;
window.filterSchools         = filterSchools;
window.loadSchools           = loadSchools;
window.onSearchInput         = onSearchInput;
window.clearSearch           = clearSearch;
window.openDrawer            = openDrawer;
window.closeDrawer           = closeDrawer;
window.editFromDrawer        = editFromDrawer;
window.deleteFromDrawer      = deleteFromDrawer;
window.toggleStatusFromDrawer = toggleStatusFromDrawer;
window.quickChangePlan       = quickChangePlan;
window.toggleStatus          = toggleStatus;
window.toggleSelectAll       = toggleSelectAll;
window.toggleRowSelect       = toggleRowSelect;
window.clearSelection        = clearSelection;
window.bulkDelete            = bulkDelete;
window.exportCSV             = exportCSV;
window.getSchoolById         = getSchoolById;
window.openChangePassword    = openChangePassword;

})();
window.changePassword        = changePassword;
