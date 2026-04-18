/* SmartBus Admin Dashboard JS */

// ── State ──────────────────────────────────────────────────────────────────
let studentsPage = 1, studentsTotalPages = 1;
let driversPage = 1, driversTotalPages = 1;
let driversTypeFilter = '';
let tripsPage = 1, tripsTotalPages = 1;
let busesPage = 1, busesTotalPages = 1;
let alertsPage = 1, alertsTotalPages = 1;

let editingId = null;
let deleteCallback = null;
let _busesCache = [], _driversCache = [], _routesCache = [];

const busColors = ['#FFD700', '#22C55E', '#3B82F6', '#F97316', '#8B5CF6', '#EF4444'];
const mapPositions = [
  { top: '45%', left: '38%' }, { top: '65%', left: '22%' },
  { top: '28%', left: '60%' }, { top: '72%', left: '60%' },
  { top: '50%', left: '75%' }, { top: '35%', left: '45%' }
];

// ── Init ───────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  setDateChip();
  loadDashboard();
});

function setDateChip() {
  const chip = document.getElementById('date-chip');
  if (!chip) return;
  const days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  const d = new Date();
  chip.textContent = `${days[d.getDay()]}، ${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`;
}

// ── Page Navigation ────────────────────────────────────────────────────────
const pageNames = {
  'dashboard': window.T?.pageDashboard || 'لوحة المراقبة',
  'trips':     window.T?.pageTrips     || 'الرحلات',
  'students':  window.T?.pageStudents  || 'الطلاب',
  'drivers':   window.T?.pageDrivers   || 'السائقون والمساعدون',
  'buses':     window.T?.pageBuses     || 'الباصات',
  'reports':   window.T?.pageReports   || 'التقارير',
  'alerts':    window.T?.pageAlerts    || 'التنبيهات',
  'settings':  window.T?.pageSettings  || 'الإعدادات'
};

function showPage(id, navEl) {
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  const page = document.getElementById('page-' + id);
  if (page) page.classList.add('active');
  if (navEl) navEl.classList.add('active');
  const titleEl = document.getElementById('page-title');
  if (titleEl) titleEl.textContent = pageNames[id] || id;

  // Lazy-load page data
  if (id === 'students') loadStudents(1);
  if (id === 'drivers') loadDrivers(1);
  if (id === 'trips') loadTrips(1);
  if (id === 'buses') loadBuses(1);
  if (id === 'alerts') loadAlerts(1);
  if (id === 'reports') loadReports();
}

// ── API Helper ─────────────────────────────────────────────────────────────
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

async function apiDelete(path) {
  try {
    const res = await fetch('/api-proxy' + path, {
      method: 'DELETE', headers: { 'X-Requested-With': 'XMLHttpRequest' }
    });
    return res.ok;
  } catch { return false; }
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

// ── Dashboard ──────────────────────────────────────────────────────────────
async function loadDashboard() {
  // Load buses for map
  const busesData = await apiGet('/buses?pageNumber=1&pageSize=20');
  if (busesData?.items) {
    _busesCache = busesData.items;
    renderMapBuses(busesData.items);
    const activeSub = document.getElementById('active-buses-sub');
    if (activeSub) activeSub.textContent = `${busesData.items.length} باص في الأسطول`;
  }

  // Load trips for today's list
  const tripsData = await apiGet('/trips?pageNumber=1&pageSize=8');
  if (tripsData?.items) renderTodayTrips(tripsData.items);

  // Load alerts
  const alertsData = await apiGet('/alerts?pageNumber=1&pageSize=3&status=0');
  if (alertsData?.items) {
    renderDashboardAlerts(alertsData.items);
    const badge = document.getElementById('alerts-badge');
    if (badge) badge.textContent = alertsData.totalCount || 0;
    const tripsBadge = document.getElementById('trips-badge');
    if (tripsBadge && tripsData) tripsBadge.textContent = tripsData.totalCount || 0;
  }
}

function renderMapBuses(buses) {
  const container = document.getElementById('map-buses');
  if (!container) return;
  const html = buses.slice(0, 6).map((bus, i) => {
    const pos = mapPositions[i] || mapPositions[0];
    const color = busColors[i % busColors.length];
    return `
      <div class="map-bus" style="top:${pos.top};left:${pos.left};">
        <div class="mbus-pulse" style="width:46px;height:46px;background:${color}30;"></div>
        <div class="mbus-pin" style="background:${color};">
          <svg width="18" height="12" viewBox="0 0 24 16" fill="none">
            <rect x="1" y="1" width="22" height="12" rx="3" fill="white"/>
            <circle cx="6" cy="14" r="2" fill="white"/><circle cx="18" cy="14" r="2" fill="white"/>
          </svg>
        </div>
        <div class="mbus-label">${escHtml(bus.plateNumber)}</div>
      </div>`;
  }).join('');
  container.innerHTML = html;
}

function renderTodayTrips(trips) {
  const el = document.getElementById('today-trips-list');
  const sub = document.getElementById('today-trips-sub');
  if (!el) return;
  if (sub) sub.textContent = `${trips.length} رحلة`;
  if (!trips.length) {
    el.innerHTML = '<div style="padding:20px;text-align:center;color:var(--text3);">لا توجد رحلات مسجلة</div>';
    return;
  }
  el.innerHTML = trips.map(t => {
    const statusInfo = getTripStatus(t.status);
    return `
      <div class="trip-row">
        <div class="trip-status-dot" style="background:${statusInfo.dot};"></div>
        <div class="trip-info">
          <div class="trip-name">${escHtml(t.busPlateNumber)} — ${escHtml(t.routeName)}</div>
          <div class="trip-meta">${formatDateTime(t.scheduledDeparture)}</div>
        </div>
        <div class="trip-badge" style="background:${statusInfo.bg};">
          <span style="color:${statusInfo.color};">${statusInfo.label}</span>
        </div>
      </div>`;
  }).join('');
}

function renderDashboardAlerts(alerts) {
  const el = document.getElementById('dashboard-alerts');
  if (!el) return;
  if (!alerts.length) {
    el.innerHTML = '<div style="padding:20px;text-align:center;color:var(--text3);">لا توجد تنبيهات</div>';
    return;
  }
  el.innerHTML = alerts.map(a => renderAlertItem(a)).join('');
}

// ── Students ───────────────────────────────────────────────────────────────
async function loadStudents(page) {
  if (page < 1 || page > studentsTotalPages) return;
  studentsPage = page;
  const data = await apiGet(`/students?pageNumber=${page}&pageSize=10`);
  const tbody = document.getElementById('students-tbody');
  const info = document.getElementById('students-pager-info');
  const countEl = document.getElementById('students-count');
  if (!data || !tbody) return;
  studentsTotalPages = data.totalPages || 1;
  if (countEl) countEl.textContent = data.totalCount || 0;
  if (info) info.textContent = `عرض ${data.items.length} من ${data.totalCount} طالب`;
  updatePager('students', page, studentsTotalPages);
  if (!data.items.length) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:30px;color:var(--text3);">لا يوجد طلاب مسجلون</td></tr>';
    return;
  }
  tbody.innerHTML = data.items.map(s => {
    const initials = getInitials(s.fullName);
    const colors = getAvatarColor(s.id);
    return `
      <tr>
        <td><div style="display:flex;align-items:center;gap:10px;">
          <div class="table-av" style="background:${colors.bg};color:${colors.text};">${initials}</div>
          <div><div class="td-name">${escHtml(s.fullName)}</div></div>
        </div></td>
        <td>${escHtml(s.grade)}${s.class ? ' ' + escHtml(s.class) : ''}</td>
        <td>${s.routeName ? `<span style="background:#EFF6FF;color:#1E40AF;border-radius:6px;padding:2px 8px;font-size:12px;font-weight:700;">${escHtml(s.routeName)}</span>` : '—'}</td>
        <td><div class="td-sub">${escHtml(s.parentName)}</div></td>
        <td><div class="td-sub">${escHtml(s.parentPhone)}</div></td>
        <td><div class="td-sub">${formatDate(s.createdAt)}</div></td>
        <td><div class="tbl-actions">
          <button class="tbl-btn tbl-edit" title="تعديل" onclick="openEdit('student',${JSON.stringify(s).replace(/"/g,'&quot;')})">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4z"/></svg>
          </button>
          <button class="tbl-btn tbl-del" title="حذف" onclick="confirmDelete('طالب','${escHtml(s.fullName)}','student','${s.id}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
          </button>
        </div></td>
      </tr>`;
  }).join('');
}

async function saveStudent() {
  const name        = document.getElementById('sf-name').value.trim();
  const grade       = document.getElementById('sf-grade').value;
  const city        = document.getElementById('sf-city').value.trim();
  const address     = document.getElementById('sf-address').value.trim();
  const parentName  = document.getElementById('sf-parent').value.trim();
  const parentPhone = document.getElementById('sf-phone').value.trim();
  const notes       = document.getElementById('sf-notes').value.trim() || null;
  if (!name || !parentName || !parentPhone) { alert('الرجاء تعبئة الحقول الإلزامية'); return; }

  const body = { fullName: name, grade, city: city || null, address: address || null,
                 parentName, parentPhone, notes };

  let res;
  if (editingId) {
    res = await apiPut(`/students/${editingId}`, body);
  } else {
    res = await apiPost('/students', body);
  }
  if (res?.ok) {
    closeModal('modal-student');
    loadStudents(studentsPage);
    showToast(window.T?.studentSaved || 'تم حفظ الطالب بنجاح ✓');
  } else { alert('فشل الحفظ. تحقق من البيانات.'); }
}

// ── Drivers ────────────────────────────────────────────────────────────────
async function loadDrivers(page) {
  if (page < 1 || page > driversTotalPages) return;
  driversPage = page;
  const typeParam = driversTypeFilter ? `&driverType=${driversTypeFilter}` : '';
  const data = await apiGet(`/drivers?pageNumber=${page}&pageSize=10${typeParam}`);
  const tbody = document.getElementById('drivers-tbody');
  const info = document.getElementById('drivers-pager-info');
  if (!data || !tbody) return;
  driversTotalPages = data.totalPages || 1;
  if (info) info.textContent = `عرض ${data.items.length} من ${data.totalCount} موظف`;
  updatePager('drivers', page, driversTotalPages);
  if (!data.items.length) {
    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:30px;color:var(--text3);">لا يوجد سائقون مسجلون</td></tr>';
    return;
  }
  tbody.innerHTML = data.items.map(d => {
    const displayName = (window.T?.isRtl === false && d.fullNameEn) ? d.fullNameEn : d.fullName;
    const initials = getInitials(displayName);
    const colors = getAvatarColor(d.id);
    const isActive = d.isActive;
    const isAssistant = d.driverType === 'Assistant';
    const typeLabel  = isAssistant ? (window.T?.driverTypeAssist || 'مساعد سائق') : (window.T?.driverTypeDriver || 'سائق');
    const typeBg     = isAssistant ? '#F5F3FF' : '#EFF6FF';
    const typeColor  = isAssistant ? '#6D28D9'  : '#1E40AF';
    const activeLabel = isActive ? (window.T?.driverActive || 'نشط') : (window.T?.driverInactive || 'غير نشط');
    return `
      <tr>
        <td><div style="display:flex;align-items:center;gap:10px;">
          <div class="table-av" style="background:${colors.bg};color:${colors.text};">${initials}</div>
          <div><div class="td-name">${escHtml(displayName)}</div></div>
        </div></td>
        <td><div class="td-badge" style="background:${typeBg};"><span style="color:${typeColor};">${typeLabel}</span></div></td>
        <td>${escHtml(d.licenseNumber || '—')}</td>
        <td>${escHtml(d.phoneNumber)}</td>
        <td><div class="td-badge" style="background:${isActive ? '#F0FDF4' : '#F1F5F9'};">
          <span style="color:${isActive ? '#15803D' : '#475569'};">${activeLabel}${isActive ? ' 🟢' : ''}</span>
        </div></td>
        <td><div class="tbl-actions">
          <button class="tbl-btn tbl-edit" title="تعديل" onclick="openEdit('driver',${JSON.stringify(d).replace(/"/g,'&quot;')})">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4z"/></svg>
          </button>
          <button class="tbl-btn tbl-del" title="حذف" onclick="confirmDelete('سائق','${escHtml(d.fullName)}','driver','${d.id}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
          </button>
        </div></td>
      </tr>`;
  }).join('');
}

async function saveDriver() {
  const name   = document.getElementById('df-name').value.trim();
  const nameEn = document.getElementById('df-name-en').value.trim();
  const phone   = document.getElementById('df-phone').value.trim();
  const license = document.getElementById('df-license').value.trim();
  if (!name || !nameEn || !phone || !license) { alert('الرجاء تعبئة جميع الحقول الإلزامية'); return; }

  const isActive  = document.getElementById('df-active').value === 'true';
  const driverType = document.getElementById('df-type').value;
  const body = { fullName: name, fullNameEn: nameEn, phoneNumber: phone, licenseNumber: license, isActive, driverType };

  let res;
  if (editingId) {
    res = await apiPut(`/drivers/${editingId}`, body);
  } else {
    res = await apiPost('/drivers', body);
  }
  if (res?.ok) {
    closeModal('modal-driver');
    _driversCache = [];
    loadDrivers(driversPage);
    showToast(window.T?.driverSaved || 'تم حفظ السائق بنجاح ✓');
  } else { alert('فشل الحفظ. تحقق من البيانات.'); }
}

// ── Trips ──────────────────────────────────────────────────────────────────
async function loadTrips(page) {
  if (page < 1 || page > tripsTotalPages) return;
  tripsPage = page;
  const data = await apiGet(`/trips?pageNumber=${page}&pageSize=10`);
  const tbody = document.getElementById('trips-tbody');
  const info = document.getElementById('trips-pager-info');
  if (!data || !tbody) return;
  tripsTotalPages = data.totalPages || 1;
  if (info) info.textContent = `عرض ${data.items.length} من ${data.totalCount} رحلة`;
  updatePager('trips', page, tripsTotalPages);
  if (!data.items.length) {
    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:30px;color:var(--text3);">لا توجد رحلات مسجلة</td></tr>';
    return;
  }
  tbody.innerHTML = data.items.map(t => {
    const statusInfo = getTripStatus(t.status);
    return `
      <tr>
        <td><div><div class="td-name">${escHtml(t.routeName)}</div></div></td>
        <td><span style="background:#EFF6FF;color:#1E40AF;border-radius:6px;padding:2px 8px;font-size:12px;font-weight:700;">${escHtml(t.busPlateNumber)}</span></td>
        <td>${escHtml(t.routeName)}</td>
        <td>${formatDateTime(t.scheduledDeparture)}</td>
        <td><div class="td-badge" style="background:${statusInfo.bg};">
          <span style="color:${statusInfo.color};">${statusInfo.label}</span>
        </div></td>
        <td><div class="tbl-actions">
          <button class="tbl-btn tbl-edit" title="تعديل" onclick="openEdit('trip',${JSON.stringify(t).replace(/"/g,'&quot;')})">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4z"/></svg>
          </button>
          <button class="tbl-btn tbl-del" title="حذف" onclick="confirmDelete('رحلة','${escHtml(t.routeName)}','trip','${t.id}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
          </button>
        </div></td>
      </tr>`;
  }).join('');
}

async function saveTrip() {
  const name = document.getElementById('tf-name').value.trim();
  const time = document.getElementById('tf-time').value;
  const busId = document.getElementById('tf-bus').value;
  const routeId = document.getElementById('tf-route').value;
  if (!name || !time || !busId || !routeId) { alert('الرجاء تعبئة جميع الحقول الإلزامية'); return; }

  const body = {
    name,
    type: parseInt(document.getElementById('tf-type').value),
    busId,
    routeId,
    scheduledDeparture: new Date().toISOString().split('T')[0] + 'T' + time + ':00',
    repeatDays: parseInt(document.getElementById('tf-repeat').value) || 0,
    notes: document.getElementById('tf-notes').value.trim() || null
  };

  let res;
  if (editingId) {
    res = await apiPut(`/trips/${editingId}`, body);
  } else {
    res = await apiPost('/trips', body);
  }
  if (res?.ok) {
    closeModal('modal-trip');
    loadTrips(tripsPage);
    showToast(window.T?.tripSaved || 'تم حفظ الرحلة بنجاح ✓');
  } else { alert('فشل الحفظ. تحقق من البيانات.'); }
}

// ── Buses ──────────────────────────────────────────────────────────────────
async function loadBuses(page) {
  if (page < 1 || page > busesTotalPages) return;
  busesPage = page;
  const data = await apiGet(`/buses?pageNumber=${page}&pageSize=10`);
  const tbody = document.getElementById('buses-tbody');
  const info = document.getElementById('buses-pager-info');
  if (!data || !tbody) return;
  busesTotalPages = data.totalPages || 1;
  if (info) info.textContent = `عرض ${data.items.length} من ${data.totalCount} باص`;
  updatePager('buses', page, busesTotalPages);
  if (!data.items.length) {
    tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;padding:30px;color:var(--text3);">لا توجد باصات مسجلة</td></tr>';
    return;
  }
  tbody.innerHTML = data.items.map(b => {
    const statusInfo = getBusStatus(b.status);
    return `
      <tr>
        <td><div><div class="td-name">${escHtml(b.plateNumber)}</div></div></td>
        <td>${escHtml(b.model || '—')}</td>
        <td>${b.capacity}</td>
        <td><div class="td-badge" style="background:${statusInfo.bg};">
          <span style="color:${statusInfo.color};">${statusInfo.label}</span>
        </div></td>
        <td><div class="tbl-actions">
          <button class="tbl-btn tbl-edit" title="تعديل" onclick="openEdit('bus',${JSON.stringify(b).replace(/"/g,'&quot;')})">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4z"/></svg>
          </button>
          <button class="tbl-btn tbl-del" title="حذف" onclick="confirmDelete('باص','${escHtml(b.plateNumber)}','bus','${b.id}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
          </button>
        </div></td>
      </tr>`;
  }).join('');
}

async function saveBus() {
  const num = document.getElementById('bf-num').value.trim();
  const cap = document.getElementById('bf-cap').value;
  const model = document.getElementById('bf-model').value.trim();
  if (!num || !cap || !model) { alert('الرجاء تعبئة جميع الحقول'); return; }

  const body = {
    plateNumber: num,
    capacity: parseInt(cap),
    model,
    status: document.getElementById('bf-status').value
  };
  const maint = document.getElementById('bf-maint').value;
  if (maint) body.lastMaintenanceDate = maint;

  let res;
  if (editingId) {
    res = await apiPut(`/buses/${editingId}`, body);
  } else {
    res = await apiPost('/buses', body);
  }
  if (res?.ok) {
    closeModal('modal-bus');
    loadBuses(busesPage);
    showToast(window.T?.busSaved || 'تم حفظ الباص بنجاح ✓');
  } else { alert('فشل الحفظ. تحقق من البيانات.'); }
}

// ── Alerts ─────────────────────────────────────────────────────────────────
async function loadAlerts(page) {
  if (page < 1 || page > alertsTotalPages) return;
  alertsPage = page;
  const data = await apiGet(`/alerts?pageNumber=${page}&pageSize=10`);
  const el = document.getElementById('alerts-list');
  const sub = document.getElementById('alerts-header-sub');
  if (!data || !el) return;
  alertsTotalPages = data.totalPages || 1;
  updatePager('alerts', page, alertsTotalPages);
  if (sub) sub.textContent = `${data.totalCount} تنبيه`;
  if (!data.items.length) {
    el.innerHTML = '<div style="padding:30px;text-align:center;color:var(--text3);">لا توجد تنبيهات</div>';
    return;
  }
  el.innerHTML = data.items.map(a => renderAlertItem(a, true)).join('');
}

function renderAlertItem(a, full = false) {
  const sev = getAlertSeverity(a.severity);
  const time = formatRelativeTime(a.createdAt);
  const actions = full && a.status === 0 ? `
    <div class="alert-actions">
      <button class="alert-btn" style="background:#EF4444;color:#fff;" onclick="resolveAlert('${a.id}')">حل التنبيه</button>
      <button class="alert-btn" style="background:#F1F5F9;color:#475569;" onclick="ignoreAlert('${a.id}')">تجاهل</button>
    </div>` : '';
  return `
    <div class="alert-item" style="${a.status !== 0 ? 'opacity:.6;' : ''}">
      <div class="alert-icon" style="background:${sev.bg};">${sev.icon}</div>
      <div style="flex:1;">
        <div class="alert-title">${escHtml(a.title)}</div>
        <div class="alert-body">${escHtml(a.message)}</div>
        <div class="alert-time">${time}</div>
        ${actions}
      </div>
    </div>`;
}

async function resolveAlert(id) {
  const res = await apiPost(`/alerts/${id}/status`, { status: 1 });
  if (res?.ok) { loadAlerts(alertsPage); showToast(window.T?.alertResolved || 'تم حل التنبيه ✓'); }
}

async function ignoreAlert(id) {
  const res = await apiPost(`/alerts/${id}/status`, { status: 2 });
  if (res?.ok) { loadAlerts(alertsPage); showToast(window.T?.alertDismissed || 'تم تجاهل التنبيه'); }
}

// ── Reports ────────────────────────────────────────────────────────────────
async function loadReports() {
  const [tripsData, busesData] = await Promise.all([
    apiGet('/trips?pageNumber=1&pageSize=100'),
    apiGet('/buses?pageNumber=1&pageSize=100')
  ]);

  const tripsEl = document.getElementById('report-trips-perf');
  if (tripsEl && tripsData?.items) {
    const completed = tripsData.items.filter(t => t.status === 'Completed').length;
    const onTime = tripsData.items.filter(t => t.status !== 'Late').length;
    tripsEl.innerHTML = `
      <div class="trip-row"><div style="flex:1"><div class="trip-name">مكتملة</div></div><div style="font-size:14px;font-weight:700;color:#15803D;">${completed}</div></div>
      <div class="trip-row"><div style="flex:1"><div class="trip-name">في الموعد</div></div><div style="font-size:14px;font-weight:700;color:#3B82F6;">${onTime}</div></div>
      <div class="trip-row"><div style="flex:1"><div class="trip-name">الإجمالي</div></div><div style="font-size:14px;font-weight:700;">${tripsData.totalCount}</div></div>`;
  }

  const busesEl = document.getElementById('report-buses-perf');
  if (busesEl && busesData?.items) {
    busesEl.innerHTML = busesData.items.slice(0, 5).map(b => {
      const pct = b.status === 'OnRoute' ? 95 : b.status === 'Active' ? 80 : 40;
      const col = pct > 80 ? '#22C55E' : pct > 60 ? '#FFD700' : '#EF4444';
      return `<div class="trip-row">
        <div style="font-size:13px;font-weight:700;flex-shrink:0;min-width:60px;">${escHtml(b.plateNumber)}</div>
        <div style="flex:1;background:#E2E8F0;border-radius:4px;height:8px;margin:0 10px;overflow:hidden;">
          <div style="height:100%;background:${col};border-radius:4px;width:${pct}%;"></div>
        </div>
        <div style="font-size:12px;font-weight:700;color:${col};">${pct}%</div>
      </div>`;
    }).join('');
  }
}

// ── Modal Open/Close ────────────────────────────────────────────────────────
function openModal(id) { document.getElementById(id)?.classList.add('open'); }
function closeModal(id) { document.getElementById(id)?.classList.remove('open'); }

function openEdit(type, data) {
  editingId = data?.id || null;
  if (type === 'trip') { fillTripForm(data); openModal('modal-trip'); }
  if (type === 'student') { fillStudentForm(data); openModal('modal-student'); }
  if (type === 'bus') { fillBusForm(data); openModal('modal-bus'); }
  if (type === 'driver') { fillDriverForm(data); openModal('modal-driver'); }
}

function fillTripForm(d) {
  document.getElementById('trip-modal-title').textContent = d ? 'تعديل رحلة' : 'إضافة رحلة جديدة';
  document.getElementById('tf-name').value = d?.name || '';
  document.getElementById('tf-type').value = d?.type ?? 0;
  document.getElementById('tf-time').value = d?.scheduledDeparture ? new Date(d.scheduledDeparture).toTimeString().slice(0, 5) : '07:15';
  document.getElementById('tf-repeat').value = d?.repeatDays ?? 0;
  document.getElementById('tf-notes').value = d?.notes || '';
  loadBusesForModal('tf-bus', d?.busId);
  loadDriversForModal('tf-driver', d?.driverId);
  loadRoutesForTripModal('tf-route', d?.routeId);
}

function fillDriverForm(d) {
  document.getElementById('driver-modal-title').textContent =
    d ? (window.T?.driverEditTitle || 'تعديل بيانات سائق')
      : (window.T?.driverAddTitle  || 'إضافة سائق جديد');
  document.getElementById('df-name').value    = d?.fullName   || '';
  document.getElementById('df-name-en').value = d?.fullNameEn || '';
  document.getElementById('df-phone').value   = d?.phoneNumber  || '';
  document.getElementById('df-license').value = d?.licenseNumber || '';

  document.getElementById('df-type').value   = d?.driverType || 'Driver';
  document.getElementById('df-active').value = d ? String(d.isActive !== false) : 'true';

  // Localise dropdown option labels
  const optDriver = document.getElementById('df-type-opt-driver');
  const optAssist = document.getElementById('df-type-opt-assist');
  if (optDriver) optDriver.textContent = window.T?.driverTypeDriver || 'سائق';
  if (optAssist) optAssist.textContent = window.T?.driverTypeAssist || 'مساعد سائق';

  const optTrue  = document.getElementById('df-active-opt-true');
  const optFalse = document.getElementById('df-active-opt-false');
  if (optTrue)  optTrue.textContent  = window.T?.driverActive   || 'نشط';
  if (optFalse) optFalse.textContent = window.T?.driverInactive || 'غير نشط';
}

function fillStudentForm(d) {
  document.getElementById('std-modal-title').textContent =
    d ? (window.T?.stdEditTitle || 'تعديل بيانات طالب')
      : (window.T?.stdAddTitle  || 'إضافة طالب جديد');

  document.getElementById('sf-name').value    = d?.fullName    || '';
  document.getElementById('sf-city').value    = d?.city        || '';
  document.getElementById('sf-address').value = d?.address     || '';
  document.getElementById('sf-parent').value  = d?.parentName  || '';
  document.getElementById('sf-phone').value   = d?.parentPhone || '';
  document.getElementById('sf-notes').value   = d?.notes       || '';

  // Localise grade options then set value
  const grades = ['stdGrade1','stdGrade2','stdGrade3','stdGrade4','stdGrade5',
                  'stdGrade6','stdGrade7','stdGrade8','stdGrade9'];
  grades.forEach((key, i) => {
    const opt = document.getElementById(`sf-g${i + 1}`);
    if (opt) opt.textContent = window.T?.[key] || opt.textContent;
  });
  const gradeVal = d?.grade || document.getElementById('sf-g1')?.textContent || '';
  document.getElementById('sf-grade').value = gradeVal;
}

function fillBusForm(d) {
  document.getElementById('bus-modal-title').textContent = d ? 'تعديل باص' : 'إضافة باص جديد';
  document.getElementById('bf-num').value = d?.plateNumber || '';
  document.getElementById('bf-model').value = d?.model || '';
  document.getElementById('bf-cap').value = d?.capacity || '';
  document.getElementById('bf-status').value = d?.status || 'Idle';
}

async function loadBusesForModal(selectId, selectedId) {
  const sel = document.getElementById(selectId);
  if (!sel) return;
  if (!_busesCache.length) {
    const data = await apiGet('/buses?pageNumber=1&pageSize=100');
    if (data?.items) _busesCache = data.items;
  }
  sel.innerHTML = '<option value="">— اختر باصاً —</option>' +
    _busesCache.map(b => `<option value="${b.id}"${b.id === selectedId ? ' selected' : ''}>${escHtml(b.plateNumber)}</option>`).join('');
}

async function loadDriversForModal(selectId, selectedId) {
  const sel = document.getElementById(selectId);
  if (!sel) return;
  if (!_driversCache.length) {
    const data = await apiGet('/drivers?pageNumber=1&pageSize=100');
    if (data?.items) _driversCache = data.items;
  }
  sel.innerHTML = '<option value="">— اختر سائقاً —</option>' +
    _driversCache.map(d => `<option value="${d.id}"${d.id === selectedId ? ' selected' : ''}>${escHtml(d.fullName)}</option>`).join('');
}

async function loadRoutesForModal() {
  const sel = document.getElementById('sf-route');
  if (!sel) return;
  if (!_routesCache.length) {
    const data = await apiGet('/routes?pageNumber=1&pageSize=100');
    if (data?.items) _routesCache = data.items;
  }
  sel.innerHTML = '<option value="">— اختر مساراً —</option>' +
    _routesCache.map(r => `<option value="${r.id}">${escHtml(r.name)}</option>`).join('');
}

async function loadRoutesForTripModal(selectId, selectedId) {
  const sel = document.getElementById(selectId);
  if (!sel) return;
  if (!_routesCache.length) {
    const data = await apiGet('/routes?pageNumber=1&pageSize=100');
    if (data?.items) _routesCache = data.items;
  }
  sel.innerHTML = '<option value="">— اختر مساراً —</option>' +
    _routesCache.map(r => `<option value="${r.id}"${r.id === selectedId ? ' selected' : ''}>${escHtml(r.name)}</option>`).join('');
}

// ── Delete ─────────────────────────────────────────────────────────────────
function confirmDelete(type, name, entity, id) {
  document.getElementById('del-item-name').textContent = name;
  document.getElementById('del-item-type').textContent = type;
  const btn = document.getElementById('del-confirm-btn');
  btn.onclick = async () => {
    let ok = false;
    if (entity === 'student') ok = await apiDelete(`/students/${id}`);
    if (entity === 'bus') ok = await apiDelete(`/buses/${id}`);
    if (entity === 'driver') ok = await apiDelete(`/drivers/${id}`);
    if (entity === 'trip') ok = await apiDelete(`/trips/${id}`);
    closeModal('modal-delete');
    if (ok) {
      showToast(window.T?.deletedSuccess || 'تم الحذف بنجاح');
      if (entity === 'student') loadStudents(studentsPage);
      if (entity === 'bus') loadBuses(busesPage);
      if (entity === 'driver') loadDrivers(driversPage);
      if (entity === 'trip') loadTrips(tripsPage);
    } else { alert('فشل الحذف. حاول مرة أخرى.'); }
  };
  openModal('modal-delete');
}

// ── Settings ───────────────────────────────────────────────────────────────
function toggleSwitch(el) {
  el.classList.toggle('on');
  el.classList.toggle('off');
}

// ── Student Filter ─────────────────────────────────────────────────────────
function filterStudents(filter, btn) {
  document.querySelectorAll('#page-students .filter-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  loadStudents(1);
}

// ── Driver Type Filter ─────────────────────────────────────────────────────
function filterDrivers(type, btn) {
  document.querySelectorAll('#page-drivers .filter-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  driversTypeFilter = type;
  driversTotalPages = 1;
  loadDrivers(1);
}

// ── Helpers ────────────────────────────────────────────────────────────────
function updatePager(prefix, page, totalPages) {
  const prev = document.getElementById(`${prefix}-prev`);
  const next = document.getElementById(`${prefix}-next`);
  if (prev) prev.disabled = page <= 1;
  if (next) next.disabled = page >= totalPages;
}

function getTripStatus(status) {
  const map = {
    'InProgress': { dot: '#22C55E', bg: '#F0FDF4', color: '#15803D', label: 'جارية' },
    'Completed': { dot: '#94A3B8', bg: '#F1F5F9', color: '#475569', label: 'مكتملة' },
    'Late': { dot: '#EF4444', bg: '#FEF2F2', color: '#B91C1C', label: 'متأخرة ⚠️' },
    'Scheduled': { dot: '#3B82F6', bg: '#EFF6FF', color: '#1E40AF', label: 'قادمة' },
    'Cancelled': { dot: '#EF4444', bg: '#FEF2F2', color: '#B91C1C', label: 'ملغاة' }
  };
  return map[status] || { dot: '#94A3B8', bg: '#F1F5F9', color: '#475569', label: status || 'غير محدد' };
}

function getBusStatus(status) {
  const map = {
    'OnRoute': { bg: '#F0FDF4', color: '#15803D', label: 'في الطريق 🟢' },
    'Active': { bg: '#F0FDF4', color: '#15803D', label: 'نشط 🟢' },
    'Idle': { bg: '#F1F5F9', color: '#475569', label: 'متوقف' },
    'Maintenance': { bg: '#FEF2F2', color: '#B91C1C', label: 'صيانة ⚠️' }
  };
  return map[status] || { bg: '#F1F5F9', color: '#475569', label: status || 'غير محدد' };
}

function getAlertSeverity(sev) {
  const map = {
    0: { bg: '#EFF6FF', icon: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>' },
    1: { bg: '#FFF7ED', icon: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#F97316" stroke-width="2.5" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/></svg>' },
    2: { bg: '#FEF2F2', icon: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#EF4444" stroke-width="2.5" stroke-linecap="round"><polygon points="7.86 2 16.14 2 22 7.86 22 16.14 16.14 22 7.86 22 2 16.14 2 7.86 7.86 2"/><line x1="12" y1="8" x2="12" y2="12"/></svg>' },
    3: { bg: '#FEF2F2', icon: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polygon points="7.86 2 16.14 2 22 7.86 22 16.14 16.14 22 7.86 22 2 16.14 2 7.86 7.86 2"/><line x1="12" y1="8" x2="12" y2="12"/></svg>' }
  };
  return map[sev] || map[0];
}

function getInitials(name) {
  if (!name) return '؟';
  const parts = name.trim().split(' ');
  if (parts.length >= 2) return parts[0][0] + parts[1][0];
  return name.slice(0, 2);
}

const avatarPalette = [
  { bg: '#EFF6FF', text: '#3B82F6' }, { bg: '#F0FDF4', text: '#16A34A' },
  { bg: '#FFFDE7', text: '#B8960C' }, { bg: '#FEF2F2', text: '#DC2626' },
  { bg: '#F5F3FF', text: '#7C3AED' }, { bg: '#FFF7ED', text: '#C2410C' }
];
function getAvatarColor(id) {
  const idx = id ? id.charCodeAt(0) % avatarPalette.length : 0;
  return avatarPalette[idx];
}

function formatDate(dt) {
  if (!dt) return '—';
  try { return new Date(dt).toLocaleDateString('ar-EG', { year: 'numeric', month: 'short', day: 'numeric' }); }
  catch { return dt; }
}

function formatDateTime(dt) {
  if (!dt) return '—';
  try { return new Date(dt).toLocaleString('ar-EG', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }); }
  catch { return dt; }
}

function formatRelativeTime(dt) {
  if (!dt) return '';
  try {
    const diff = (Date.now() - new Date(dt).getTime()) / 1000;
    if (diff < 60) return 'منذ لحظات';
    if (diff < 3600) return `منذ ${Math.floor(diff / 60)} دقيقة`;
    if (diff < 86400) return `منذ ${Math.floor(diff / 3600)} ساعة`;
    return formatDate(dt);
  } catch { return dt; }
}

function escHtml(str) {
  if (!str) return '';
  return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function showToast(msg) {
  const t = document.createElement('div');
  t.style.cssText = 'position:fixed;bottom:24px;left:24px;background:#111;color:#fff;padding:12px 20px;border-radius:12px;font-family:Cairo,sans-serif;font-size:13px;font-weight:600;z-index:9999;animation:mslide .2s ease;box-shadow:0 4px 16px rgba(0,0,0,.2);';
  t.textContent = msg;
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 3000);
}

// Close modals on overlay click
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.modal-overlay').forEach(o => {
    o.addEventListener('click', e => { if (e.target === o) o.classList.remove('open'); });
  });
});

// ── Explicit global exports for inline onclick attributes ──────────────────
// expose pager state variables so inline onclick pager buttons can read them
Object.defineProperty(window, 'studentsPage', { get: () => studentsPage });
Object.defineProperty(window, 'driversPage',  { get: () => driversPage });
Object.defineProperty(window, 'tripsPage',    { get: () => tripsPage });
Object.defineProperty(window, 'busesPage',    { get: () => busesPage });
Object.defineProperty(window, 'alertsPage',   { get: () => alertsPage });

// ── Change Password ────────────────────────────────────────────────────────
function openChangePassword() {
  // clear previous state
  ['cp-current', 'cp-new', 'cp-confirm'].forEach(id => {
    const el = document.getElementById(id);
    if (el) { el.value = ''; el.classList.remove('form-control-err'); el.style.borderColor = ''; }
  });
  ['err-cp-current', 'err-cp-new', 'err-cp-confirm'].forEach(id => {
    const el = document.getElementById(id);
    if (el) el.style.display = 'none';
  });
  const srv = document.getElementById('cp-server-err');
  if (srv) srv.style.display = 'none';
  openModal('modal-change-password');
}

async function changePassword() {
  const current  = document.getElementById('cp-current')?.value  ?? '';
  const newPwd   = document.getElementById('cp-new')?.value      ?? '';
  const confirm  = document.getElementById('cp-confirm')?.value  ?? '';

  let valid = true;
  const setErr = (errId, inputId, show) => {
    const err = document.getElementById(errId);
    const inp = document.getElementById(inputId);
    if (err) err.style.display = show ? 'block' : 'none';
    if (inp) inp.style.borderColor = show ? '#EF4444' : '';
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

  if (btn) { btn.disabled = false; btn.textContent = 'حفظ كلمة المرور'; }

  const srv = document.getElementById('cp-server-err');
  if (res?.ok) {
    if (srv) srv.style.display = 'none';
    closeModal('modal-change-password');
    showToast(window.T?.passwordChanged || 'تم تغيير كلمة المرور بنجاح ✓');
  } else {
    if (srv) { srv.textContent = res?.data?.error || 'فشل تغيير كلمة المرور.'; srv.style.display = 'block'; }
  }
}

window.showPage        = showPage;
window.openModal       = openModal;
window.closeModal      = closeModal;
window.openChangePassword = openChangePassword;
window.changePassword     = changePassword;
window.openEdit        = openEdit;
window.confirmDelete   = confirmDelete;
window.saveTrip        = saveTrip;
window.saveStudent     = saveStudent;
window.saveBus         = saveBus;
window.saveDriver      = saveDriver;
window.resolveAlert    = resolveAlert;
window.ignoreAlert     = ignoreAlert;
window.toggleSwitch    = toggleSwitch;
window.filterStudents  = filterStudents;
window.filterDrivers   = filterDrivers;
window.loadStudents    = loadStudents;
window.loadDrivers     = loadDrivers;
window.loadTrips       = loadTrips;
window.loadBuses       = loadBuses;
window.loadAlerts      = loadAlerts;
