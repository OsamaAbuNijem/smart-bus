/**
 * SmartBus Admin — shared utilities and event delegation.
 * Namespace: window.SB
 */
(function () {
  'use strict';
  const SB = (window.SB = window.SB || {});

  // ── Translations loader ────────────────────────────────────────────────────
  SB.t = {};
  async function loadTranslations() {
    try {
      const res = await fetch('/api/translations/admin', { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
      if (res.ok) SB.t = await res.json();
    } catch { /* fall back to key names */ }
    Object.assign(SB.t, SB.ctx || {});
    window.T = SB.t; // back-compat
  }

  // ── Date chip ──────────────────────────────────────────────────────────────
  function setDateChip() {
    const chip = document.getElementById('date-chip');
    if (!chip) return;
    const days = ['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
    const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    const d = new Date();
    chip.textContent = `${days[d.getDay()]}، ${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`;
  }

  // ── Modal helpers ──────────────────────────────────────────────────────────
  function openModal(id)  { document.getElementById(id)?.classList.add('open'); }
  function closeModal(id) { document.getElementById(id)?.classList.remove('open'); }

  // ── Toast ──────────────────────────────────────────────────────────────────
  function ShowMessage(msg) {
    const t = document.createElement('div');
    t.className = 'toast';
    t.textContent = msg;
    document.body.appendChild(t);
    setTimeout(() => t.remove(), 3000);
  }

  // ── Pager ──────────────────────────────────────────────────────────────────
  function updatePager(prefix, page, totalPages) {
    const prev = document.getElementById(`${prefix}-prev`);
    const next = document.getElementById(`${prefix}-next`);
    if (prev) prev.disabled = page <= 1;
    if (next) next.disabled = page >= totalPages;
  }

  // ── Format helpers ─────────────────────────────────────────────────────────
  function formatDate(dt) {
    if (!dt) return '—';
    try { return new Date(dt).toLocaleDateString('ar-EG', { year:'numeric', month:'short', day:'numeric' }); }
    catch { return dt; }
  }
  function formatDateTime(dt) {
    if (!dt) return '—';
    try { return new Date(dt).toLocaleString('ar-EG', { month:'short', day:'numeric', hour:'2-digit', minute:'2-digit' }); }
    catch { return dt; }
  }
  function formatRelativeTime(dt) {
    if (!dt) return '';
    try {
      const diff = (Date.now() - new Date(dt).getTime()) / 1000;
      if (diff < 60)    return 'منذ لحظات';
      if (diff < 3600)  return `منذ ${Math.floor(diff / 60)} دقيقة`;
      if (diff < 86400) return `منذ ${Math.floor(diff / 3600)} ساعة`;
      return formatDate(dt);
    } catch { return dt; }
  }
  function escHtml(str) {
    if (!str) return '';
    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }
  function gradeLabel(grade) { return SB.t['stdGrade' + grade] || grade; }
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

  // ── Status helpers ─────────────────────────────────────────────────────────
  function getTripStatus(status) {
    const map = {
      'InProgress': { dot:'#22C55E', bg:'#F0FDF4', color:'#15803D', label:'جارية' },
      'Completed':  { dot:'#94A3B8', bg:'#F1F5F9', color:'#475569', label:'مكتملة' },
      'Delayed':    { dot:'#EF4444', bg:'#FEF2F2', color:'#B91C1C', label:'متأخرة' },
      'Scheduled':  { dot:'#3B82F6', bg:'#EFF6FF', color:'#1E40AF', label:'قادمة' },
      'Cancelled':  { dot:'#EF4444', bg:'#FEF2F2', color:'#B91C1C', label:'ملغاة' }
    };
    return map[status] || { dot:'#94A3B8', bg:'#F1F5F9', color:'#475569', label: status || 'غير محدد' };
  }
  function getBusStatus(status) {
    const isRtl = SB.t.isRtl !== false;
    const map = {
      'OnRoute':      { bg:'#F0FDF4', color:'#15803D', label: isRtl ? 'في الطريق 🟢' : 'On Route 🟢' },
      'Active':       { bg:'#F0FDF4', color:'#15803D', label: isRtl ? 'نشط 🟢' : 'Active 🟢' },
      'Inactive':     { bg:'#F1F5F9', color:'#475569', label: isRtl ? 'غير نشط' : 'Inactive' },
      'Idle':         { bg:'#F1F5F9', color:'#475569', label: isRtl ? 'متوقف' : 'Idle' },
      'Maintenance':  { bg:'#FEF2F2', color:'#B91C1C', label: isRtl ? 'صيانة ⚠️' : 'Maintenance ⚠️' },
      'OutOfService': { bg:'#FEF2F2', color:'#B91C1C', label: isRtl ? 'خارج الخدمة' : 'Out of Service' },
    };
    return map[status] || { bg:'#F1F5F9', color:'#475569', label: status || (isRtl ? 'غير محدد' : 'Unknown') };
  }
  function getAlertSeverity(sev) {
    const map = {
      0: { bg:'#EFF6FF', icon:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>' },
      1: { bg:'#FFF7ED', icon:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#F97316" stroke-width="2.5" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/></svg>' },
      2: { bg:'#FEF2F2', icon:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#EF4444" stroke-width="2.5" stroke-linecap="round"><polygon points="7.86 2 16.14 2 22 7.86 22 16.14 16.14 22 7.86 22 2 16.14 2 7.86 7.86 2"/><line x1="12" y1="8" x2="12" y2="12"/></svg>' },
      3: { bg:'#FEF2F2', icon:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polygon points="7.86 2 16.14 2 22 7.86 22 16.14 16.14 22 7.86 22 2 16.14 2 7.86 7.86 2"/><line x1="12" y1="8" x2="12" y2="12"/></svg>' }
    };
    return map[sev] || map[0];
  }

  function renderAlertItem(a, full) {
    const sev  = getAlertSeverity(a.severity);
    const time = formatRelativeTime(a.createdAt);
    const actions = full && a.status === 0 ? `
      <div class="alert-actions">
        <button class="alert-btn danger" data-action="alert-resolve" data-id="${a.id}">حل التنبيه</button>
        <button class="alert-btn secondary" data-action="alert-ignore" data-id="${a.id}">تجاهل</button>
      </div>` : '';
    return `
      <div class="alert-item ${a.status !== 0 ? 'resolved' : ''}">
        <div class="alert-icon" style="background:${sev.bg};">${sev.icon}</div>
        <div class="u-flex-1">
          <div class="alert-title">${escHtml(a.title)}</div>
          <div class="alert-body">${escHtml(a.message)}</div>
          <div class="alert-time">${time}</div>
          ${actions}
        </div>
      </div>`;
  }

  // ── Delete confirmation ────────────────────────────────────────────────────
  function confirmDelete(type, name, entity, id, onDeleted) {
    document.getElementById('del-item-name').textContent = name;
    document.getElementById('del-item-type').textContent = type;
    const btn = document.getElementById('del-confirm-btn');
    btn.onclick = async () => {
      let ok = false;
      if (entity === 'student') ok = await SB.api.delete(`/students/${id}`);
      if (entity === 'bus')     ok = await SB.api.delete(`/buses/${id}`);
      if (entity === 'driver')  ok = await SB.api.delete(`/drivers/${id}`);
      if (entity === 'trip')    ok = await SB.api.delete(`/trips/${id}`);
      closeModal('modal-delete');
      if (ok) {
        ShowMessage(SB.t.deletedSuccess || 'تم الحذف بنجاح');
        if (typeof onDeleted === 'function') onDeleted(entity);
      } else {
        alert('فشل الحذف. حاول مرة أخرى.');
      }
    };
    openModal('modal-delete');
  }

  // ── Change password ────────────────────────────────────────────────────────
  function openChangePassword() {
    ['cp-current','cp-new','cp-confirm'].forEach(id => {
      const el = document.getElementById(id);
      if (el) { el.value = ''; el.style.borderColor = ''; }
    });
    ['err-cp-current','err-cp-new','err-cp-confirm'].forEach(id => {
      const el = document.getElementById(id);
      if (el) el.style.display = 'none';
    });
    const srv = document.getElementById('cp-server-err');
    if (srv) srv.style.display = 'none';
    openModal('modal-change-password');
  }

  async function changePassword() {
    const current = document.getElementById('cp-current')?.value ?? '';
    const newPwd  = document.getElementById('cp-new')?.value ?? '';
    const confirm = document.getElementById('cp-confirm')?.value ?? '';
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
    if (btn) { btn.disabled = true; btn.textContent = SB.t.saving || 'جاري الحفظ...'; }
    const res = await SB.api.post('/auth/change-password', { currentPassword: current, newPassword: newPwd });
    if (btn) { btn.disabled = false; btn.textContent = 'حفظ كلمة المرور'; }
    if (res?.ok) {
      closeModal('modal-change-password');
      ShowMessage(SB.t.passwordChanged || 'تم تغيير كلمة المرور بنجاح ✓');
    } else {
      const srv = document.getElementById('cp-server-err');
      if (srv) { srv.textContent = res?.data?.message || 'فشل تغيير كلمة المرور'; srv.style.display = 'block'; }
    }
  }

  function toggleSwitch(el) {
    el.classList.toggle('on');
    el.classList.toggle('off');
  }

  // ── Event delegation ───────────────────────────────────────────────────────
  const handlers = {};
  function on(action, handler) { handlers[action] = handler; }

  document.addEventListener('click', e => {
    const el = e.target.closest('[data-action]');
    if (!el) return;
    const action = el.getAttribute('data-action');
    const handler = handlers[action];
    if (handler) handler(el, e);
  });

  // Built-in handlers
  on('modal-close',          el => closeModal(el.getAttribute('data-target')));
  on('modal-open',           el => openModal(el.getAttribute('data-target')));
  on('toggle-switch',        el => toggleSwitch(el));
  on('open-change-password', () => openChangePassword());
  on('save-password',        () => changePassword());
  on('pager-prev',           el => {
    const prefix = el.getAttribute('data-prefix');
    const page = SB.pages?.[prefix];
    if (page && typeof page.load === 'function') page.load((page.currentPage?.() ?? 1) - 1);
  });
  on('pager-next',           el => {
    const prefix = el.getAttribute('data-prefix');
    const page = SB.pages?.[prefix];
    if (page && typeof page.load === 'function') page.load((page.currentPage?.() ?? 1) + 1);
  });

  document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.modal-overlay').forEach(o => {
      o.addEventListener('click', e => { if (e.target === o) o.classList.remove('open'); });
    });
  });

  document.addEventListener('DOMContentLoaded', async () => {
    await loadTranslations();
    setDateChip();
    document.dispatchEvent(new CustomEvent('sb:ready'));
  });

  // ── Simple AJAX helper (for MVC controller actions) ───────────────────────
  // Usage: SB.ajax('/Drivers/Save', { body, method='POST' })
  // Always sends X-Requested-With; JSON in, JSON (or null) out.
  // Returns { ok, status, data }.
  async function ajax(url, { method = 'GET', body } = {}) {
    try {
      const opts = {
        method,
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      };
      if (body !== undefined) {
        opts.headers['Content-Type'] = 'application/json';
        opts.body = JSON.stringify(body);
      }
      const res = await fetch(url, opts);
      if (res.status === 401) {
        location.href = '/Account/Login?returnUrl=' + encodeURIComponent(location.pathname + location.search);
        return { ok: false, status: 401, data: null };
      }
      const ct   = res.headers.get('content-type') || '';
      const data = ct.includes('application/json') ? await res.json().catch(() => null) : null;
      return { ok: res.ok, status: res.status, data };
    } catch { return { ok: false, status: 0, data: null }; }
  }

  // Expose
  SB.pages = SB.pages || {};
  SB.ajax = ajax;
  SB.openModal = openModal;
  SB.closeModal = closeModal;
  SB.ShowMessage = ShowMessage;
  SB.updatePager = updatePager;
  SB.formatDate = formatDate;
  SB.formatDateTime = formatDateTime;
  SB.formatRelativeTime = formatRelativeTime;
  SB.escHtml = escHtml;
  SB.gradeLabel = gradeLabel;
  SB.getInitials = getInitials;
  SB.getAvatarColor = getAvatarColor;
  SB.getTripStatus = getTripStatus;
  SB.getBusStatus = getBusStatus;
  SB.getAlertSeverity = getAlertSeverity;
  SB.renderAlertItem = renderAlertItem;
  SB.confirmDelete = confirmDelete;
  SB.on = on;
})();
