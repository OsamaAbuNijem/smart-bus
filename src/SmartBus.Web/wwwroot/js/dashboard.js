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
let _scheduleBusId = null;   // pre-selected bus ID for the schedule modal
let _studentMap = null, _studentMarker = null;

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

async function apiPatch(path, body) {
  try {
    const res = await fetch('/api-proxy' + path, {
      method: 'PATCH',
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
        <td>${escHtml(gradeLabel(s.grade))}${s.class ? ' ' + escHtml(s.class) : ''}</td>
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
  const name             = document.getElementById('sf-name').value.trim();
  const nameEn           = document.getElementById('sf-name-en').value.trim();
  const grade            = document.getElementById('sf-grade').value;
  const parentName       = document.getElementById('sf-parent').value.trim();
  const parentNameEn     = document.getElementById('sf-parent-en').value.trim();
  const parentPhone      = document.getElementById('sf-phone').value.trim();
  const buildingNumber   = document.getElementById('sf-building').value.trim() || null;
  const latVal           = document.getElementById('sf-lat').value;
  const lngVal           = document.getElementById('sf-lng').value;
  const homeArea         = document.getElementById('sf-area').value.trim()   || null;
  const homeStreet       = document.getElementById('sf-street').value.trim() || null;
  if (!name || !parentName || !parentPhone) { alert('الرجاء تعبئة الحقول الإلزامية'); return; }

  const body = {
    fullName: name, fullNameEn: nameEn || null,
    grade, parentName, parentNameEn: parentNameEn || null, parentPhone,
    latitude:  latVal ? parseFloat(latVal) : null,
    longitude: lngVal ? parseFloat(lngVal) : null,
    homeArea, homeStreet, homeBuildingNumber: buildingNumber
  };

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
function tripTypeLabel(type) {
  if (!type) return '';
  const t = (typeof type === 'string') ? type.toLowerCase() : '';
  if (t === 'morning') return { label: 'ذهاب', bg: '#F0FDF4', color: '#15803D' };
  if (t === 'return')  return { label: 'إياب',  bg: '#EFF6FF', color: '#1D4ED8' };
  return { label: type, bg: '#F1F5F9', color: '#475569' };
}

function repeatDaysLabel(mask) {
  if (!mask) return '—';
  const names = ['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
  const bits  = [1, 2, 4, 8, 16, 32, 64];
  const days  = bits.filter(b => (mask & b) !== 0).map(b => names[bits.indexOf(b)]);
  if (days.length === 7) return 'يومي';
  if (mask === 31)  return 'الأحد — الخميس';
  if (mask === 62)  return 'الاثنين — الجمعة';
  return days.join('، ');
}

function getTripsFilterParams() {
  const name   = (document.getElementById('trip-filter-name')?.value   || '').trim();
  const date   = document.getElementById('trip-filter-date')?.value    || '';
  const status = document.getElementById('trip-filter-status')?.value  || '';
  const params = new URLSearchParams();
  if (name)   params.set('personName', name);
  if (date)   params.set('date', date);
  if (status) params.set('status', status);
  return params.toString() ? '&' + params.toString() : '';
}

function clearTripsFilter() {
  const nameEl   = document.getElementById('trip-filter-name');
  const dateEl   = document.getElementById('trip-filter-date');
  const statusEl = document.getElementById('trip-filter-status');
  if (nameEl)   nameEl.value   = '';
  if (dateEl)   dateEl.value   = '';
  if (statusEl) statusEl.value = '';
  loadTrips(1);
}

let _tripsFilterTimer = null;
function debouncedTripsFilter() {
  clearTimeout(_tripsFilterTimer);
  _tripsFilterTimer = setTimeout(() => loadTrips(1), 350);
}

async function loadTrips(page) {
  if (page < 1 || page > tripsTotalPages) return;
  tripsPage = page;
  const filters = getTripsFilterParams();
  const data = await apiGet(`/trips?pageNumber=${page}&pageSize=10${filters}`);
  const tbody = document.getElementById('trips-tbody');
  const info = document.getElementById('trips-pager-info');
  if (!data || !tbody) return;
  tripsTotalPages = data.totalPages || 1;
  if (info) info.textContent = `عرض ${data.items.length} من ${data.totalCount} رحلة`;
  updatePager('trips', page, tripsTotalPages);
  if (!data.items.length) {
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:30px;color:var(--text3);">لا توجد رحلات تطابق البحث. تأكد من تحديد جدول لكل باص (زر الجدول في صفحة الباصات) ثم اضغط "تشغيل الجدول الآن".</td></tr>';
    return;
  }
  tbody.innerHTML = data.items.map(t => {
    const typeInfo   = tripTypeLabel(t.tripType);
    const dt         = t.scheduledDeparture ? new Date(t.scheduledDeparture) : null;
    const dateStr    = dt ? dt.toLocaleDateString('ar-SA', { day: '2-digit', month: '2-digit', year: 'numeric' }) : '—';
    const timeStr    = dt ? dt.toLocaleTimeString('ar-SA', { hour: '2-digit', minute: '2-digit', hour12: false }) : '—';
    const driverName  = t.driverName          ? escHtml(t.driverName)          : '—';
    const assistName  = t.assistantDriverName ? escHtml(t.assistantDriverName) : '—';
    const statusInfo  = getTripStatus(t.status);
    const canStart    = t.status === 'Scheduled' || t.status === 'Delayed';
    const canComplete = t.status === 'InProgress';
    return `
      <tr>
        <td><div class="td-sub">${driverName}</div></td>
        <td><div class="td-sub">${assistName}</div></td>
        <td><span style="background:#EFF6FF;color:#1E40AF;border-radius:6px;padding:2px 8px;font-size:12px;font-weight:700;">${escHtml(t.busPlateNumber)}</span></td>
        <td><span style="background:${typeInfo.bg};color:${typeInfo.color};border-radius:6px;padding:2px 10px;font-size:12px;font-weight:700;">${typeInfo.label}</span></td>
        <td style="font-size:12px;color:var(--text2);">${dateStr}</td>
        <td style="font-weight:600;">${timeStr}</td>
        <td><div class="td-badge" style="background:${statusInfo.bg};">
          <span style="color:${statusInfo.color};">${statusInfo.label}</span>
        </div></td>
        <td><div class="tbl-actions">
          <button class="tbl-btn" title="عرض الطلاب" style="color:#7C3AED;" onclick="openTripStudents('${t.id}','${escHtml(t.busPlateNumber)}','${typeInfo.label}','${dateStr}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#7C3AED" stroke-width="2.5" stroke-linecap="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
          </button>
          ${canStart ? `
          <button class="tbl-btn" title="بدء الرحلة" style="color:#D97706;" onclick="startTrip('${t.id}', this)">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2.5" stroke-linecap="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>
          </button>` : ''}
          ${canComplete ? `
          <button class="tbl-btn" title="إتمام الرحلة" style="color:#16A34A;" onclick="completeTrip('${t.id}', this)">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#16A34A" stroke-width="2.5" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg>
          </button>` : ''}
          <button class="tbl-btn tbl-del" title="حذف" onclick="confirmDelete('رحلة','${escHtml(t.busPlateNumber)}','trip','${t.id}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
          </button>
        </div></td>
      </tr>`;
  }).join('');
}

// Open the bus-schedule modal. plateOrNull and busIdOrNull pre-select the bus.
function openBusScheduleModal(plateOrNull, busIdOrNull) {
  try {
    // Reset form to defaults immediately
    document.querySelectorAll('.sch-day').forEach(cb => { cb.checked = false; });
    // Default: Sun–Thu
    [1, 2, 4, 8, 16].forEach(v => {
      const cb = document.querySelector(`.sch-day[value="${v}"]`);
      if (cb) cb.checked = true;
    });
    const morningEl = document.getElementById('sch-morning-time');
    const returnEl  = document.getElementById('sch-return-time');
    const busSel    = document.getElementById('sch-bus');
    const titleEl   = document.querySelector('#modal-trip .modal-header-title');
    if (morningEl) morningEl.value = '07:15';
    if (returnEl)  returnEl.value  = '14:00';
    if (titleEl)   titleEl.textContent = plateOrNull ? `جدول رحلات — ${plateOrNull}` : 'جدول رحلات الباص';

    // Store bus id for use in saveBusSchedule
    _scheduleBusId = busIdOrNull || null;

    // If a bus is already known, hide the dropdown; otherwise show it for selection
    if (busIdOrNull && busSel) {
      busSel.closest('.form-group').closest('.form-row').style.display = 'none';
    } else if (busSel) {
      busSel.closest('.form-group').closest('.form-row').style.display = '';
      busSel.innerHTML = '<option value="">جاري التحميل...</option>';
    }

    // Open modal right away — data loads in background
    openModal('modal-trip');

    // Load buses async, then load the saved schedule if editing
    loadBusesForModal('sch-bus', busIdOrNull).then(() => {
      if (!busIdOrNull) return;
      return apiGet(`/trips/bus/${busIdOrNull}/schedule`).then(sched => {
        if (!sched) return;
        if (sched.morningTime && morningEl) morningEl.value = sched.morningTime;
        if (sched.returnTime  && returnEl)  returnEl.value  = sched.returnTime;
        if (sched.repeatDays) {
          document.querySelectorAll('.sch-day').forEach(cb => {
            cb.checked = (sched.repeatDays & parseInt(cb.value)) !== 0;
          });
        }
      });
    }).catch(err => console.error('[schedule modal]', err));

  } catch (e) {
    console.error('[openBusScheduleModal]', e);
    alert('حدث خطأ أثناء فتح النافذة: ' + e.message);
  }
}

async function saveBusSchedule() {
  const busId      = document.getElementById('sch-bus').value || _scheduleBusId;
  const morningTime = document.getElementById('sch-morning-time').value;
  const returnTime  = document.getElementById('sch-return-time').value;
  if (!busId)      { alert('الرجاء اختيار الباص'); return; }
  if (!morningTime){ alert('الرجاء تحديد وقت الذهاب'); return; }
  if (!returnTime) { alert('الرجاء تحديد وقت الإياب'); return; }

  let repeatDays = 0;
  document.querySelectorAll('.sch-day:checked').forEach(cb => { repeatDays |= parseInt(cb.value); });
  if (!repeatDays) { alert('الرجاء اختيار يوم واحد على الأقل'); return; }

  const res = await apiPost(`/trips/bus/${busId}/schedule`, { morningTime, returnTime, repeatDays });
  if (res?.ok) {
    closeModal('modal-trip');
    loadTrips(tripsPage);
    loadBuses(busesPage);   // refresh schedule indicators
    showToast('تم حفظ جدول الرحلات بنجاح ✓');
  } else {
    const errMsg = res?.data?.error || res?.data?.title || JSON.stringify(res?.data) || 'خطأ غير معروف';
    alert('فشل الحفظ: ' + errMsg);
  }
}

// kept for backward-compat in openEdit but no longer used for trips
async function saveTrip() { await saveBusSchedule(); }

async function triggerTripGeneration() {
  const btn = event?.currentTarget;
  if (btn) { btn.disabled = true; btn.textContent = 'جاري التشغيل...'; }
  const res = await apiPost('/trips/generate-today', {});
  if (btn) { btn.disabled = false; btn.innerHTML = '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>تشغيل الجدول الآن'; }
  if (res?.ok) {
    loadTrips(1);
    const msg = res.data?.message || 'تم إنشاء رحلات اليوم بنجاح ✓';
    showToast(msg);
  } else {
    const errMsg = res?.data?.error || res?.data?.message || res?.data?.title || 'فشل التشغيل. تأكد من وجود جدول محدد للباصات.';
    alert(errMsg);
  }
}

// ── Buses ──────────────────────────────────────────────────────────────────
async function loadBuses(page) {
  if (page < 1 || page > busesTotalPages) return;
  busesPage = page;

  // Fetch buses and all schedules in parallel
  const [data, schedulesRaw] = await Promise.all([
    apiGet(`/buses?pageNumber=${page}&pageSize=10`),
    apiGet('/trips/schedules')
  ]);

  const tbody = document.getElementById('buses-tbody');
  const info = document.getElementById('buses-pager-info');
  if (!data || !tbody) return;

  // Build a Set of busIds that have a saved schedule
  const scheduledBusIds = new Set((schedulesRaw || []).map(s => s.busId));

  busesTotalPages = data.totalPages || 1;
  if (info) info.textContent = `عرض ${data.items.length} من ${data.totalCount} باص`;
  updatePager('buses', page, busesTotalPages);
  if (!data.items.length) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:30px;color:var(--text3);">لا توجد باصات مسجلة</td></tr>';
    return;
  }
  const isRtl = window.T?.isRtl !== false;
  tbody.innerHTML = data.items.map(b => {
    const statusInfo   = getBusStatus(b.status);
    const driverName   = b.driverName   ? escHtml(b.driverName)   : '—';
    const assistName   = b.assistantDriverName ? escHtml(b.assistantDriverName) : '—';
    const studentCount = b.studentCount ?? 0;
    const hasSchedule  = scheduledBusIds.has(b.id);

    // Schedule button: green + checkmark if set, amber + warning if missing
    const schedBtnStyle = hasSchedule
      ? 'color:#16A34A;background:#F0FDF4;border:1px solid #BBF7D0;'
      : 'color:#B45309;background:#FFFBEB;border:1px solid #FDE68A;';
    const schedIcon = hasSchedule
      ? `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#16A34A" stroke-width="2.5" stroke-linecap="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/><polyline points="9 15 11 17 15 13"/></svg>`
      : `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#B45309" stroke-width="2.5" stroke-linecap="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/><line x1="12" y1="14" x2="12" y2="17"/><circle cx="12" cy="19.5" r="0.5" fill="#B45309"/></svg>`;
    const schedTitle = hasSchedule
      ? (isRtl ? 'جدول محدد — انقر للتعديل' : 'Schedule set — click to edit')
      : (isRtl ? 'لا يوجد جدول — انقر للإضافة' : 'No schedule — click to add');

    return `
      <tr>
        <td><div class="td-name">${escHtml(b.plateNumber)}</div></td>
        <td>${b.capacity}</td>
        <td><div class="td-badge" style="background:${statusInfo.bg};">
          <span style="color:${statusInfo.color};">${statusInfo.label}</span>
        </div></td>
        <td><div class="td-sub">${driverName}</div></td>
        <td><div class="td-sub">${assistName}</div></td>
        <td>
          <span style="background:#EFF6FF;color:#1E40AF;border-radius:6px;padding:2px 8px;font-size:12px;font-weight:700;">${studentCount}</span>
        </td>
        <td><div class="tbl-actions">
          <button class="tbl-btn" title="${schedTitle}" style="${schedBtnStyle}border-radius:6px;padding:3px 6px;" onclick="openBusScheduleModal('${escHtml(b.plateNumber)}','${b.id}')">
            ${schedIcon}
          </button>
          <button class="tbl-btn tbl-edit" title="${isRtl ? 'تعديل' : 'Edit'}" onclick="openEditBus('${b.id}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4z"/></svg>
          </button>
          <button class="tbl-btn tbl-del" title="${isRtl ? 'حذف' : 'Delete'}" onclick="confirmDelete('${isRtl ? 'باص' : 'Bus'}','${escHtml(b.plateNumber)}','bus','${b.id}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
          </button>
        </div></td>
      </tr>`;
  }).join('');
}

async function saveBus() {
  const num = document.getElementById('bf-num').value.trim();
  const cap = document.getElementById('bf-cap').value;
  if (!num || !cap) {
    alert(window.T?.isRtl !== false ? 'الرجاء تعبئة رقم الباص والطاقة الاستيعابية' : 'Please fill in Bus Number and Capacity');
    return;
  }

  const driverId          = document.getElementById('bf-driver').value    || null;
  const assistantDriverId = document.getElementById('bf-assistant').value || null;

  const body = {
    plateNumber:       num,
    capacity:          parseInt(cap),
    status:            document.getElementById('bf-status').value,
    driverId,
    assistantDriverId,
    studentIds:        [..._selectedStudentIds]
  };

  let res;
  if (editingId) {
    res = await apiPut(`/buses/${editingId}`, body);
  } else {
    res = await apiPost('/buses', body);
  }
  if (res?.ok) {
    closeModal('modal-bus');
    _busesCache = [];
    _allStudentsForBus = [];
    loadBuses(busesPage);
    showToast(window.T?.busSaved || 'تم حفظ الباص بنجاح ✓');
  } else { alert(window.T?.saveFailed || 'فشل الحفظ. تحقق من البيانات.'); }
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
  if (type === 'trip') { openBusScheduleModal(data?.busPlateNumber || null, data?.busId || null); }
  if (type === 'student') { fillStudentForm(data); openModal('modal-student'); }
  if (type === 'driver') { fillDriverForm(data); openModal('modal-driver'); }
  if (type === 'bus') { editingId = null; _selectedStudentIds = new Set(); fillBusForm(null); openModal('modal-bus'); }
}

async function openEditBus(id) {
  editingId = id;
  _selectedStudentIds = new Set();
  fillBusForm(null);      // open modal immediately with skeleton
  openModal('modal-bus');
  const data = await apiGet(`/buses/${id}`);
  if (data) fillBusForm(data);
}

// fillTripForm replaced by openBusScheduleModal

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

// Jordan city centre coordinates
const _jordanCities = {
  Amman:    [31.9539, 35.9106],
  Zarqa:    [32.0728, 36.0882],
  Irbid:    [32.5556, 35.8500],
  Aqaba:    [29.5321, 35.0063],
  Salt:     [32.0392, 35.7275],
  Madaba:   [31.7161, 35.7939],
  Karak:    [31.1769, 35.7047],
  Jerash:   [32.2742, 35.9008],
  Ajloun:   [32.3325, 35.7508],
  Mafraq:   [32.3419, 36.2061],
  Tafilah:  [30.8378, 35.6078],
  Maan:     [30.1928, 35.7342],
  Russeifa: [32.0167, 36.0833],
  Ramtha:   [32.5619, 36.0033],
  WadiMusa: [30.3217, 35.4799],
};

let _searchDebounce = null;

function initStudentMap(lat, lng) {
  if (_studentMap) { _studentMap.remove(); _studentMap = null; _studentMarker = null; }

  // Default view: use existing pin coords, else zoom to the school's city, else Amman
  let defaultLat = lat ?? 31.9539;
  let defaultLng = lng ?? 35.9106;
  let zoom = lat ? 15 : 12;

  if (!lat) {
    const schoolCity = window.T?.schoolCity;
    const cityCoords = schoolCity ? _jordanCities[schoolCity] : null;
    if (cityCoords) { defaultLat = cityCoords[0]; defaultLng = cityCoords[1]; zoom = 13; }
  }

  _studentMap = L.map('sf-map', { zoomControl: true }).setView([defaultLat, defaultLng], zoom);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap',
    maxZoom: 19
  }).addTo(_studentMap);

  if (lat && lng) _studentMarker = L.marker([lat, lng]).addTo(_studentMap);

  // Click → place marker + reverse geocode
  _studentMap.on('click', (e) => placeStudentPin(e.latlng.lat, e.latlng.lng));

  // Search box
  const searchEl = document.getElementById('sf-map-search');
  const resultsEl = document.getElementById('sf-map-search-results');
  if (searchEl) {
    searchEl.oninput = () => {
      clearTimeout(_searchDebounce);
      const q = searchEl.value.trim();
      if (!resultsEl) return;
      if (q.length < 3) { resultsEl.style.display = 'none'; return; }
      _searchDebounce = setTimeout(async () => {
        try {
          const lang = window.T?.isRtl ? 'ar' : 'en';
          const r = await fetch(
            `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(q)}&countrycodes=jo&limit=5&accept-language=${lang}`
          );
          const items = await r.json();
          if (!items.length) { resultsEl.style.display = 'none'; return; }
          resultsEl.innerHTML = items.map(it =>
            `<div style="padding:8px 12px;cursor:pointer;border-bottom:1px solid var(--border);"
                  onmousedown="selectSearchResult(${it.lat},${it.lon},'${escHtml(it.display_name.split(',')[0])}')"
                  onmouseover="this.style.background='var(--card2)'" onmouseout="this.style.background=''"
             >${escHtml(it.display_name)}</div>`
          ).join('');
          resultsEl.style.display = 'block';
        } catch { resultsEl.style.display = 'none'; }
      }, 400);
    };
    searchEl.onblur = () => setTimeout(() => { if (resultsEl) resultsEl.style.display = 'none'; }, 200);
  }
}

function selectSearchResult(lat, lng, label) {
  const resultsEl = document.getElementById('sf-map-search-results');
  const searchEl  = document.getElementById('sf-map-search');
  if (resultsEl) resultsEl.style.display = 'none';
  if (searchEl)  searchEl.value = label;
  if (_studentMap) _studentMap.flyTo([lat, lng], 16, { duration: 1 });
  placeStudentPin(lat, lng);
}

async function placeStudentPin(lat, lng) {
  document.getElementById('sf-lat').value    = lat;
  document.getElementById('sf-lng').value    = lng;
  document.getElementById('sf-area').value   = window.T?.stdMapLoading || 'جاري تحديد العنوان...';
  document.getElementById('sf-street').value = '';

  if (_studentMarker) _studentMap.removeLayer(_studentMarker);
  _studentMarker = L.marker([lat, lng]).addTo(_studentMap);

  try {
    const lang = window.T?.isRtl ? 'ar' : 'en';
    const res  = await fetch(
      `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=${lang}`
    );
    const data = await res.json();
    const addr = data.address || {};
    document.getElementById('sf-area').value   =
      addr.suburb || addr.neighbourhood || addr.city_district || addr.county ||
      (window.T?.stdMapNoResult || 'تعذّر تحديد العنوان');
    document.getElementById('sf-street').value =
      addr.road || addr.pedestrian || addr.residential || '';
  } catch {
    document.getElementById('sf-area').value = window.T?.stdMapNoResult || 'تعذّر تحديد العنوان';
  }
}

function locateStudentMap() {
  if (!_studentMap) return;
  const btn = document.getElementById('sf-map-locate');
  if (btn) btn.style.color = 'var(--y)';
  _studentMap.locate({ setView: true, maxZoom: 16 });
  _studentMap.once('locationfound', (e) => {
    if (btn) btn.style.color = '';
    placeStudentPin(e.latlng.lat, e.latlng.lng);
  });
  _studentMap.once('locationerror', () => { if (btn) btn.style.color = ''; });
}

function fillStudentForm(d) {
  document.getElementById('std-modal-title').textContent =
    d ? (window.T?.stdEditTitle || 'تعديل بيانات طالب')
      : (window.T?.stdAddTitle  || 'إضافة طالب جديد');

  document.getElementById('sf-name').value      = d?.fullName          || '';
  document.getElementById('sf-name-en').value   = d?.fullNameEn        || '';
  document.getElementById('sf-parent').value    = d?.parentName        || '';
  document.getElementById('sf-parent-en').value = d?.parentNameEn      || '';
  document.getElementById('sf-phone').value     = d?.parentPhone       || '';
  document.getElementById('sf-building').value  = d?.homeBuildingNumber || '';
  document.getElementById('sf-lat').value       = d?.latitude          ?? '';
  document.getElementById('sf-lng').value       = d?.longitude         ?? '';
  document.getElementById('sf-area').value      = d?.homeArea          || '';
  document.getElementById('sf-street').value    = d?.homeStreet        || '';

  // Localise grade option labels (values stay as "1"–"9")
  const gradeKeys = ['stdGrade1','stdGrade2','stdGrade3','stdGrade4','stdGrade5',
                     'stdGrade6','stdGrade7','stdGrade8','stdGrade9'];
  gradeKeys.forEach((key, i) => {
    const opt = document.getElementById(`sf-g${i + 1}`);
    if (opt) opt.textContent = window.T?.[key] || opt.textContent;
  });
  document.getElementById('sf-grade').value = d?.grade || '1';

  // Init map after the modal is visible (next tick so DOM is rendered)
  setTimeout(() => initStudentMap(d?.latitude ?? null, d?.longitude ?? null), 50);
}

// ── Bus student multi-select state ───────────────────────────────────────
let _allStudentsForBus = [];   // full list loaded once
let _selectedStudentIds = new Set();

function fillBusForm(d) {
  const isRtl = window.T?.isRtl !== false;
  document.getElementById('bus-modal-title').textContent =
    d ? (isRtl ? 'تعديل باص' : 'Edit Bus') : (isRtl ? 'إضافة باص جديد' : 'Add New Bus');
  document.getElementById('bf-num').value    = d?.plateNumber || '';
  document.getElementById('bf-cap').value    = d?.capacity    || '';
  document.getElementById('bf-status').value = d?.status      || 'Inactive';
  document.getElementById('bf-student-search').value = '';

  _selectedStudentIds = new Set((d?.studentIds || []).map(id => id.toString()));

  // Load drivers & assistants then pre-select
  loadDriversForBusModal(d?.driverId, d?.assistantDriverId);
  loadStudentsForBusModal();
}

async function loadDriversForBusModal(driverId, assistantDriverId) {
  if (!_driversCache.length) {
    const data = await apiGet('/drivers?pageNumber=1&pageSize=200');
    if (data?.items) _driversCache = data.items;
  }
  const drivers    = _driversCache.filter(d => d.driverType !== 'Assistant');
  const assistants = _driversCache.filter(d => d.driverType === 'Assistant');
  const isRtl = window.T?.isRtl !== false;

  const driverSel = document.getElementById('bf-driver');
  driverSel.innerHTML = `<option value="">${isRtl ? '— اختر سائقاً —' : '— Select Driver —'}</option>` +
    drivers.map(d => `<option value="${d.id}"${d.id === driverId ? ' selected' : ''}>${escHtml(isRtl ? d.fullName : (d.fullNameEn || d.fullName))}</option>`).join('');

  const assistSel = document.getElementById('bf-assistant');
  assistSel.innerHTML = `<option value="">${isRtl ? '— اختر مساعداً —' : '— Select Assistant —'}</option>` +
    assistants.map(d => `<option value="${d.id}"${d.id === assistantDriverId ? ' selected' : ''}>${escHtml(isRtl ? d.fullName : (d.fullNameEn || d.fullName))}</option>`).join('');
}

async function loadStudentsForBusModal() {
  if (!_allStudentsForBus.length) {
    const data = await apiGet('/students?pageNumber=1&pageSize=500');
    if (data?.items) _allStudentsForBus = data.items;
  }
  renderBusStudentsList(_allStudentsForBus);
}

function renderBusStudentsList(students) {
  const list = document.getElementById('bf-students-list');
  const isRtl = window.T?.isRtl !== false;
  if (!list) return;

  if (!students.length) {
    list.innerHTML = `<div style="padding:16px;text-align:center;color:var(--text3);font-size:12px;">${isRtl ? 'لا يوجد طلاب' : 'No students found'}</div>`;
    updateBusSelectedCount();
    return;
  }

  list.innerHTML = students.map(s => {
    const checked = _selectedStudentIds.has(s.id.toString());
    const name = (!isRtl && s.fullNameEn) ? s.fullNameEn : s.fullName;
    const area = s.homeArea ? ` — ${escHtml(s.homeArea)}` : '';
    return `
      <label style="display:flex;align-items:center;gap:10px;padding:8px 12px;cursor:pointer;border-bottom:1px solid var(--border);transition:background .1s;"
             onmouseover="this.style.background='var(--yl)'" onmouseout="this.style.background=''">
        <input type="checkbox" value="${s.id}" ${checked ? 'checked' : ''}
               onchange="toggleBusStudent(this)"
               style="width:15px;height:15px;accent-color:var(--yd);flex-shrink:0;cursor:pointer;"/>
        <div style="flex:1;min-width:0;">
          <div style="font-size:13px;font-weight:600;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${escHtml(name)}</div>
          <div style="font-size:11px;color:var(--text3);">${escHtml(gradeLabel(s.grade))}${area}</div>
        </div>
      </label>`;
  }).join('');

  updateBusSelectedCount();
}

function toggleBusStudent(checkbox) {
  if (checkbox.checked) _selectedStudentIds.add(checkbox.value);
  else _selectedStudentIds.delete(checkbox.value);
  updateBusSelectedCount();
}

function updateBusSelectedCount() {
  const el = document.getElementById('bf-selected-count');
  if (el) el.textContent = _selectedStudentIds.size;
}

function filterBusStudents(q) {
  if (!_allStudentsForBus.length) return;
  const term = q.trim().toLowerCase();
  const filtered = term.length < 1
    ? _allStudentsForBus
    : _allStudentsForBus.filter(s => {
        const name = (s.fullName || '').toLowerCase();
        const nameEn = (s.fullNameEn || '').toLowerCase();
        const area = (s.homeArea || '').toLowerCase();
        return name.includes(term) || nameEn.includes(term) || area.includes(term);
      });
  renderBusStudentsList(filtered);
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

// ── Grade helper ───────────────────────────────────────────────────────────
function gradeLabel(grade) {
  const key = 'stdGrade' + grade;
  return (window.T?.[key]) || grade;
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
    'Completed':  { dot: '#94A3B8', bg: '#F1F5F9', color: '#475569', label: 'مكتملة' },
    'Delayed':    { dot: '#EF4444', bg: '#FEF2F2', color: '#B91C1C', label: 'متأخرة' },
    'Scheduled':  { dot: '#3B82F6', bg: '#EFF6FF', color: '#1E40AF', label: 'قادمة' },
    'Cancelled':  { dot: '#EF4444', bg: '#FEF2F2', color: '#B91C1C', label: 'ملغاة' }
  };
  return map[status] || { dot: '#94A3B8', bg: '#F1F5F9', color: '#475569', label: status || 'غير محدد' };
}

const TRIP_STATUS_OPTIONS = [
  { value: 0, key: 'Scheduled',  label: 'قادمة',    color: '#1E40AF' },
  { value: 1, key: 'InProgress', label: 'جارية',    color: '#15803D' },
  { value: 2, key: 'Completed',  label: 'مكتملة',   color: '#475569' },
  { value: 3, key: 'Cancelled',  label: 'ملغاة',    color: '#B91C1C' },
  { value: 4, key: 'Delayed',    label: 'متأخرة',   color: '#B45309' }
];

function renderTripStatusSelect(tripId, currentStatus) {
  const info = getTripStatus(currentStatus);
  const opts = TRIP_STATUS_OPTIONS.map(o =>
    `<option value="${o.value}"${o.key === currentStatus ? ' selected' : ''}>${o.label}</option>`
  ).join('');
  return `<select class="trip-status-sel"
    style="background:${info.bg};color:${info.color};border:1px solid ${info.color}30;
           border-radius:6px;padding:3px 6px;font-size:12px;font-weight:700;cursor:pointer;outline:none;"
    onchange="changeTripStatus('${tripId}', this)">${opts}</select>`;
}

async function changeTripStatus(tripId, selectEl) {
  const newStatusInt = parseInt(selectEl.value);
  const res = await apiPatch(`/trips/${tripId}/status`, { status: newStatusInt, notes: null });
  if (res?.ok) {
    const info = getTripStatus(TRIP_STATUS_OPTIONS.find(o => o.value === newStatusInt)?.key || '');
    selectEl.style.background = info.bg;
    selectEl.style.color      = info.color;
    selectEl.style.border     = `1px solid ${info.color}30`;
    showToast('تم تحديث حالة الرحلة ✓');
  } else {
    alert('فشل تحديث الحالة');
    loadTrips(tripsPage);
  }
}

async function startTrip(tripId, btn) {
  btn.disabled = true;
  const res = await fetch('/api-proxy/trips/' + tripId + '/start', {
    method: 'POST',
    headers: { 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/json' }
  });
  if (res.ok) {
    showToast('تم بدء الرحلة ✓');
    loadTrips(tripsPage);
  } else {
    btn.disabled = false;
    alert('فشل تحديث الحالة');
  }
}

async function completeTrip(tripId, btn) {
  btn.disabled = true;
  const res = await fetch('/api-proxy/trips/' + tripId + '/complete', {
    method: 'POST',
    headers: { 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/json' }
  });
  if (res.ok) {
    showToast('تم إتمام الرحلة ✓');
    loadTrips(tripsPage);
  } else {
    btn.disabled = false;
    alert('فشل تحديث الحالة');
  }
}

// ── Trip Students Modal ────────────────────────────────────────────────────
async function openTripStudents(tripId, plate, typeLabel, dateStr) {
  const titleEl = document.getElementById('trip-students-title');
  const subEl   = document.getElementById('trip-students-sub');
  const bodyEl  = document.getElementById('trip-students-body');
  if (titleEl) titleEl.textContent = `طلاب الرحلة — ${plate}`;
  if (subEl)   subEl.textContent   = `${typeLabel}  •  ${dateStr}`;
  if (bodyEl)  bodyEl.innerHTML    = '<div style="padding:30px;text-align:center;color:var(--text3);">جاري التحميل...</div>';
  openModal('modal-trip-students');

  const students = await apiGet(`/trips/${tripId}/students`);
  if (!bodyEl) return;
  if (!students || !students.length) {
    bodyEl.innerHTML = '<div style="padding:30px;text-align:center;color:var(--text3);">لا يوجد طلاب مسجلون في هذه الرحلة</div>';
    return;
  }
  const boardingMap = {
    'Waiting': { bg: '#EFF6FF', color: '#1E40AF', label: 'في الانتظار' },
    'Boarded': { bg: '#F0FDF4', color: '#15803D', label: 'ركب' },
    'Absent':  { bg: '#FEF2F2', color: '#B91C1C', label: 'غائب' }
  };
  const gradeLabels = {
    'KG1':'KG1','KG2':'KG2','Grade1':'الأول','Grade2':'الثاني','Grade3':'الثالث',
    'Grade4':'الرابع','Grade5':'الخامس','Grade6':'السادس','Grade7':'السابع',
    'Grade8':'الثامن','Grade9':'التاسع','Grade10':'العاشر','Grade11':'الحادي عشر',
    'Grade12':'الثاني عشر'
  };
  bodyEl.innerHTML = `
    <table class="table" style="margin:0;">
      <thead>
        <tr>
          <th>الطالب</th>
          <th>الصف</th>
          <th>المنطقة</th>
          <th>حالة الركوب</th>
          <th>وقت الركوب</th>
          <th>وقت التنزيل</th>
        </tr>
      </thead>
      <tbody>
        ${students.map(s => {
          const bs      = boardingMap[s.boardingStatus] || { bg:'#F1F5F9', color:'#475569', label: s.boardingStatus };
          const grade   = gradeLabels[s.grade] || s.grade;
          const bTime   = s.boardingTime ? new Date(s.boardingTime).toLocaleTimeString('ar-SA', { hour:'2-digit', minute:'2-digit', hour12:false }) : '—';
          const dTime   = s.dropoffTime  ? new Date(s.dropoffTime).toLocaleTimeString('ar-SA',  { hour:'2-digit', minute:'2-digit', hour12:false }) : '—';
          const initials = getInitials(s.fullName);
          const colors   = getAvatarColor(s.studentId);
          return `
            <tr>
              <td><div style="display:flex;align-items:center;gap:8px;">
                <div class="table-av" style="background:${colors.bg};color:${colors.text};width:28px;height:28px;font-size:11px;">${initials}</div>
                <div class="td-name" style="font-size:13px;">${escHtml(s.fullName)}</div>
              </div></td>
              <td><div class="td-sub">${grade}</div></td>
              <td><div class="td-sub">${s.homeArea ? escHtml(s.homeArea) : '—'}</div></td>
              <td><span style="background:${bs.bg};color:${bs.color};border-radius:6px;padding:2px 8px;font-size:12px;font-weight:700;">${bs.label}</span></td>
              <td style="font-size:12px;color:var(--text2);">${bTime}</td>
              <td style="font-size:12px;color:var(--text2);">${dTime}</td>
            </tr>`;
        }).join('')}
      </tbody>
    </table>`;
}

function getBusStatus(status) {
  const isRtl = window.T?.isRtl !== false;
  const map = {
    'OnRoute':      { bg: '#F0FDF4', color: '#15803D', label: isRtl ? 'في الطريق 🟢' : 'On Route 🟢' },
    'Active':       { bg: '#F0FDF4', color: '#15803D', label: isRtl ? 'نشط 🟢'        : 'Active 🟢' },
    'Inactive':     { bg: '#F1F5F9', color: '#475569', label: isRtl ? 'غير نشط'        : 'Inactive' },
    'Idle':         { bg: '#F1F5F9', color: '#475569', label: isRtl ? 'متوقف'          : 'Idle' },
    'Maintenance':  { bg: '#FEF2F2', color: '#B91C1C', label: isRtl ? 'صيانة ⚠️'       : 'Maintenance ⚠️' },
    'OutOfService': { bg: '#FEF2F2', color: '#B91C1C', label: isRtl ? 'خارج الخدمة'    : 'Out of Service' },
  };
  return map[status] || { bg: '#F1F5F9', color: '#475569', label: status || (isRtl ? 'غير محدد' : 'Unknown') };
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
window.saveTrip           = saveTrip;
window.saveBusSchedule    = saveBusSchedule;
window.openBusScheduleModal   = openBusScheduleModal;
window.triggerTripGeneration  = triggerTripGeneration;
window.saveStudent     = saveStudent;
window.saveBus         = saveBus;
window.saveDriver      = saveDriver;
window.resolveAlert    = resolveAlert;
window.ignoreAlert     = ignoreAlert;
window.toggleSwitch    = toggleSwitch;
window.filterStudents  = filterStudents;
window.filterDrivers   = filterDrivers;
window.loadStudents       = loadStudents;
window.loadDrivers        = loadDrivers;
window.loadTrips            = loadTrips;
window.changeTripStatus     = changeTripStatus;
window.startTrip            = startTrip;
window.completeTrip         = completeTrip;
window.openTripStudents     = openTripStudents;
window.apiPatch             = apiPatch;
window.clearTripsFilter     = clearTripsFilter;
window.debouncedTripsFilter = debouncedTripsFilter;
window.loadBuses          = loadBuses;
window.loadAlerts         = loadAlerts;
window.openEditBus        = openEditBus;
window.toggleBusStudent   = toggleBusStudent;
window.filterBusStudents  = filterBusStudents;
