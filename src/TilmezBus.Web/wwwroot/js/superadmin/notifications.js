/**
 * TilmezBus Super-Admin — Notifications page.
 * Composer + history for platform-wide push broadcasts. Talks to
 *   POST /api-proxy/superadmin/notifications
 *   GET  /api-proxy/superadmin/notifications
 */
const notifications = {
  _strings: null,

  async init() {
    notifications._strings = notifications._readStrings();
    const targetEl = document.getElementById('notif-target');
    if (targetEl) targetEl.addEventListener('change', notifications._onTargetChange);
    document.getElementById('notif-send-btn')?.addEventListener('click', notifications.send);
    await Promise.all([
      notifications._loadSchools(),
      notifications.loadHistory(),
    ]);
    notifications._onTargetChange();
  },

  // ── Target / schools selector ────────────────────────────────────────────
  /** Reveal the schools multi-select only when the audience needs it. */
  _onTargetChange() {
    const target  = parseInt(document.getElementById('notif-target')?.value, 10) || 0;
    const row     = document.getElementById('notif-schools-row');
    const needs   = target === 1 || target === 2;  // SchoolUsers / SchoolAdmins
    if (row) row.classList.toggle('u-hidden', !needs);
  },

  async _loadSchools() {
    const data = await SB.api.get('/schools?pageNumber=1&pageSize=200');
    const sel  = document.getElementById('notif-schools');
    if (!sel) return;
    const items = (data?.items || []).slice().sort((a, b) => (a.name || '').localeCompare(b.name || ''));
    sel.innerHTML = items.map(s => `<option value="${SB.escHtml(s.id)}">${SB.escHtml(s.name)}</option>`).join('');
  },

  _selectedSchoolIds() {
    const sel = document.getElementById('notif-schools');
    if (!sel) return [];
    return Array.from(sel.selectedOptions).map(o => o.value);
  },

  // ── Send broadcast ───────────────────────────────────────────────────────
  async send() {
    const title   = (document.getElementById('notif-title').value || '').trim();
    const message = (document.getElementById('notif-message').value || '').trim();
    const target  = parseInt(document.getElementById('notif-target').value, 10) || 0;
    const ids     = notifications._selectedSchoolIds();

    const errBox  = document.getElementById('notif-error');
    const titleErr   = document.getElementById('err-notif-title');
    const messageErr = document.getElementById('err-notif-message');
    titleErr?.classList.toggle('show',   !title);
    messageErr?.classList.toggle('show', !message);
    if (!title || !message) return;
    errBox?.classList.add('u-hidden');

    // Audiences that target specific schools must have at least one picked.
    if ((target === 1 || target === 2) && ids.length === 0 && target === 1) {
      errBox.textContent = notifications._strings.pickSchools;
      errBox.classList.remove('u-hidden');
      return;
    }

    const btn = document.getElementById('notif-send-btn');
    const resultEl = document.getElementById('notif-result');
    if (btn) btn.disabled = true;
    if (resultEl) resultEl.textContent = '…';
    try {
      const res = await SB.api.post('/superadmin/notifications', {
        title, message, target, schoolIds: ids
      });
      if (!res?.ok) {
        if (errBox) {
          errBox.textContent = res?.data?.error || ('HTTP ' + res?.status);
          errBox.classList.remove('u-hidden');
        }
        if (resultEl) resultEl.textContent = '';
        return;
      }
      const d = res.data || {};
      // "Sent to N users · M devices" — format string comes from the resx
      // strings bag so the SuperAdmin sees Arabic/English numerals correctly.
      if (resultEl) resultEl.textContent = (notifications._strings.sentFormat || 'Sent to {0} users · {1} devices')
        .replace('{0}', d.recipients ?? 0)
        .replace('{1}', d.delivered  ?? 0);
      // Reset composer + refresh history.
      document.getElementById('notif-title').value   = '';
      document.getElementById('notif-message').value = '';
      await notifications.loadHistory();
    } finally {
      if (btn) btn.disabled = false;
    }
  },

  // ── History list ─────────────────────────────────────────────────────────
  async loadHistory() {
    const tbody = document.getElementById('notif-history-tbody');
    if (!tbody) return;
    const rows = await SB.api.get('/superadmin/notifications');
    if (!Array.isArray(rows)) {
      tbody.innerHTML = `<tr><td colspan="5" class="td-empty u-text-danger">${SB.escHtml(notifications._strings.loadFailed)}</td></tr>`;
      return;
    }
    if (rows.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" class="td-empty">${SB.escHtml(notifications._strings.empty)}</td></tr>`;
      return;
    }
    tbody.innerHTML = rows.map(r => `
      <tr>
        <td>${SB.escHtml(SB.formatDate(r.createdAt))}</td>
        <td>
          <div class="td-name">${SB.escHtml(r.title)}</div>
          <div class="td-sub">${SB.escHtml(r.message)}</div>
        </td>
        <td>${SB.escHtml(notifications._targetLabel(r.target))}</td>
        <td>${SB.escHtml(r.recipients ?? 0)}</td>
        <td>${SB.escHtml(r.delivered  ?? 0)}</td>
      </tr>`).join('');
  },

  // ── Helpers ──────────────────────────────────────────────────────────────
  _targetLabel(t) {
    const map = {
      0: notifications._strings.targetAll,
      1: notifications._strings.targetSchoolUsers,
      2: notifications._strings.targetAdmins,
      AllUsers:     notifications._strings.targetAll,
      SchoolUsers:  notifications._strings.targetSchoolUsers,
      SchoolAdmins: notifications._strings.targetAdmins,
    };
    return map[t] ?? String(t);
  },

  _readStrings() {
    const d = document.getElementById('notif-strings')?.dataset || {};
    return {
      targetAll:         d.targetAll         || 'All users',
      targetSchoolUsers: d.targetSchoolUsers || "Selected schools' users",
      targetAdmins:      d.targetAdmins      || 'School admins',
      empty:             d.empty             || 'No broadcasts sent yet.',
      sentFormat:        d.sentFormat        || 'Sent to {0} users · {1} devices',
      loadFailed:        d.loadFailed        || 'Failed to load broadcasts.',
      pickSchools:       d.pickSchools       || 'Pick at least one school.',
    };
  }
};
