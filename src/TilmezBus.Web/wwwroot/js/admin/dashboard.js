/**
 * TilmezBus Admin — Dashboard page.
 * Hero refresh + Latest Alerts strip + live in-progress trips poller.
 */

const dashboard = {
  _livePollTimer: null,
  _liveTickTimer: null,
  // Difference between client clock and server clock, in ms. Re-measured on
  // each /Live response so the countdown stays accurate even if the user's
  // laptop clock drifts.
  _liveServerSkewMs: 0,
  _liveI18n: {},

  init() {
    const btn = document.getElementById('dash-refresh');
    if (btn) btn.addEventListener('click', () => this.refresh(btn));
    // One-time hydration on page load: alerts strip + live section. The
    // KPI numbers + Today buckets are already server-rendered, so we don't
    // re-fetch them here.
    this._loadAlerts();
    this._initLive();
  },

  // Refresh button: pulls a fresh snapshot of the headline KPIs and the
  // Today buckets only. The Live section already auto-polls every 15s and
  // is intentionally left alone here so its own ticker stays smooth.
  async refresh(refreshBtn) {
    if (refreshBtn) refreshBtn.classList.add('spin');
    // Guarantee at least one full rotation of the icon so a fast network
    // doesn't make the button feel like "nothing happened".
    const minSpinMs = 800;
    const startedAt = Date.now();
    try {
      const stats = await this._fetchJson('/Dashboard/Stats');
      if (stats) this._applyStats(stats, /*flash=*/true);
    } finally {
      if (refreshBtn) {
        const remaining = Math.max(0, minSpinMs - (Date.now() - startedAt));
        setTimeout(() => refreshBtn.classList.remove('spin'), remaining);
      }
    }
  },

  async _loadAlerts() {
    const html = await this._fetchHtml('/Dashboard/RecentAlerts');
    const el = document.getElementById('dashboard-alerts');
    if (el && typeof html === 'string') el.innerHTML = html;
  },

  _applyStats(stats, flash) {
    const set = (id, v) => {
      const el = document.getElementById(id);
      if (!el) return;
      el.textContent = String(v ?? 0);
      // When the user explicitly clicked Refresh, flash every cell so the
      // action is unmistakable — even if the underlying number didn't
      // actually change.
      if (flash) this._flash(el);
    };
    const t = stats.totals || {};
    set('stat-students',   t.students);
    set('stat-buses',      t.buses);
    set('stat-drivers',    t.drivers);
    set('stat-assistants', t.assistants);
    set('stat-trips',      t.trips);

    ['today', 'morning', 'return'].forEach(k => {
      const b = stats[k] || {};
      set(`today-${k}-trips`,    b.trips);
      set(`today-${k}-students`, b.students);
      set(`today-${k}-absent`,   b.absent);
    });
  },

  _flash(el) {
    // Re-trigger the animation by removing the class then re-adding it on
    // the next frame, otherwise back-to-back refreshes show the flash only
    // once.
    el.classList.remove('stat-flash');
    void el.offsetWidth;
    el.classList.add('stat-flash');
  },

  // ── Live section (polling + countdown) ──────────────────────────────────
  _initLive() {
    const i = document.getElementById('live-i18n');
    if (i) this._liveI18n = { ...i.dataset };

    this._loadLive();
    this._startLivePoll();
    this._liveTickTimer = setInterval(() => this._tickLive(), 1000);

    // Pause polling when the tab is hidden — no point hammering the server
    // when the user isn't looking. Resume + refresh on visibility.
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        this._stopLivePoll();
      } else {
        this._loadLive();
        this._startLivePoll();
      }
    });
  },

  _startLivePoll() {
    this._stopLivePoll();
    this._livePollTimer = setInterval(() => this._loadLive(), 15000);
  },

  _stopLivePoll() {
    if (this._livePollTimer) { clearInterval(this._livePollTimer); this._livePollTimer = null; }
  },

  async _loadLive() {
    const data = await this._fetchJson('/Dashboard/Live');
    if (!data) return;
    // Skew = clientNow - serverNow. Subtract when computing remaining ms.
    if (data.serverNowUtc) {
      this._liveServerSkewMs = Date.now() - new Date(data.serverNowUtc).getTime();
    }
    this._renderLive(data);
  },

  _renderLive(data) {
    const set = (id, v) => { const el = document.getElementById(id); if (el) el.textContent = String(v ?? 0); };
    set('live-overall-trips',    data?.overall?.trips);
    set('live-overall-students', data?.overall?.students);
    set('live-morning-trips',    data?.morning?.trips);
    set('live-morning-students', data?.morning?.students);
    set('live-return-trips',     data?.return?.trips);
    set('live-return-students',  data?.return?.students);

    const list = document.getElementById('live-trips-list');
    if (!list) return;
    const trips = Array.isArray(data?.trips) ? data.trips : [];
    if (trips.length === 0) {
      list.innerHTML = `<div class="u-empty-state">${this._liveI18n.none || 'No trips currently in progress'}</div>`;
      return;
    }
    list.innerHTML = trips.map(t => this._renderLiveTripRow(t)).join('');
  },

  _renderLiveTripRow(t) {
    const typeLabel = t.tripType === 'Morning'
      ? (this._liveI18n.morning || 'Morning')
      : (this._liveI18n.return  || 'Return');
    const typeClass = t.tripType === 'Morning' ? 'morning' : 'return';
    const expectedMs = new Date(t.expectedEndUtc).getTime();
    const departedMs = new Date(t.actualDepartureUtc).getTime();
    const driver = t.driverName ? `<span class="live-trip-meta-item">${this._escape(t.driverName)}</span>` : '';
    const assistant = t.assistantName ? `<span class="live-trip-meta-item">${this._escape(t.assistantName)}</span>` : '';
    return `
      <div class="live-trip" data-expected-ms="${expectedMs}" data-departed-ms="${departedMs}">
        <div class="live-trip-main">
          <div class="live-trip-head">
            <span class="live-trip-plate">${this._escape(t.busPlateNumber || '')}</span>
            <span class="trip-type-pill ${typeClass}">${typeLabel}</span>
          </div>
          <div class="live-trip-meta">
            ${driver}${assistant}
            <span class="live-trip-meta-item">${t.boarded}/${t.roster} ${this._liveI18n.onboard || 'onboard'}</span>
          </div>
        </div>
        <div class="live-trip-times">
          <div class="live-trip-countdown" data-countdown>
            <span class="live-trip-countdown-label">${this._liveI18n.endsin || 'Ends in'}</span>
            <span class="live-trip-countdown-val">--:--</span>
          </div>
          <div class="live-trip-departed">${this._liveI18n.departed || 'Departed'} ${this._fmtTime(t.actualDepartureUtc)}</div>
        </div>
      </div>`;
  },

  _tickLive() {
    const now = Date.now() - this._liveServerSkewMs;
    document.querySelectorAll('#live-trips-list .live-trip').forEach(row => {
      const expected = parseInt(row.dataset.expectedMs, 10);
      if (!expected) return;
      const diff = expected - now;
      const cd = row.querySelector('[data-countdown]');
      if (!cd) return;
      const lbl = cd.querySelector('.live-trip-countdown-label');
      const val = cd.querySelector('.live-trip-countdown-val');
      if (diff <= 0) {
        cd.classList.add('overdue');
        if (lbl) lbl.textContent = this._liveI18n.overdue || 'Overdue';
        if (val) val.textContent = this._fmtMs(-diff);
      } else {
        cd.classList.remove('overdue');
        if (lbl) lbl.textContent = this._liveI18n.endsin || 'Ends in';
        if (val) val.textContent = this._fmtMs(diff);
      }
    });
  },

  _fmtMs(ms) {
    const total = Math.max(0, Math.floor(ms / 1000));
    const h = Math.floor(total / 3600);
    const m = Math.floor((total % 3600) / 60);
    const s = total % 60;
    const pad = n => n.toString().padStart(2, '0');
    return h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${pad(m)}:${pad(s)}`;
  },

  _fmtTime(iso) {
    try {
      const d = new Date(iso);
      return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    } catch { return ''; }
  },

  _escape(s) {
    return String(s).replace(/[&<>"']/g, c => ({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' })[c]);
  },

  async _fetchJson(url) {
    try {
      const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' }, cache: 'no-store' });
      if (res.status === 401) { location.href = '/Account/Login'; return null; }
      return res.ok ? await res.json() : null;
    } catch { return null; }
  },

  async _fetchHtml(url) {
    const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' }, cache: 'no-store' });
    if (res.status === 401) { location.href = '/Account/Login'; return ''; }
    return res.text();
  }
};

document.addEventListener('DOMContentLoaded', () => dashboard.init());
