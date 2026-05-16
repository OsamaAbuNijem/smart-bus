/**
 * SmartBus Super-Admin — Dashboard (overview) page.
 * Loads the 4 stat cards + the 5-row "recent schools" preview.
 *
 * Trimmed: the SchoolDto no longer carries Plan / MaxBuses / IsActive — those
 * counters now show the subscription type of each school's active sub.
 */
const dashboard = {
  async load() {
    const data = await SB.api.get('/schools?pageNumber=1&pageSize=100');
    if (!data) return;
    const items = data.items || [];
    const total = data.totalCount || 0;
    const live  = items.filter(s => !!s.activeSubscriptionType).length;
    const premium = items.filter(s => s.activeSubscriptionType === 'Premium').length;

    SB.animateCounter('stat-total-schools', total);
    SB.animateCounter('stat-premium',       premium);
    SB.animateCounter('stat-buses',         0);    // bus inventory belongs on a future per-school dashboard
    SB.animateCounter('stat-admins',        live);
    SB.setText('stat-active-schools', `${live} ${SB.t.saDashActiveSuffix || 'active'}`);
    SB.setText('schools-count-badge', total);

    const tbody = document.getElementById('overview-schools-tbody');
    if (!tbody) return;
    if (!items.length) {
      tbody.innerHTML = `<tr><td colspan="6"><div class="empty-state empty-state-sm">
        <div class="empty-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2" stroke-linecap="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg></div>
        <div class="empty-title">${SB.escHtml(SB.t.saDashEmptyTitle || 'No schools yet')}</div>
        <div class="empty-sub">${SB.escHtml(SB.t.saDashEmptyHint  || 'Add the first school to the platform')}</div>
      </div></td></tr>`;
      return;
    }
    tbody.innerHTML = items.slice(0, 5).map(s => dashboard._renderRow(s)).join('');
  },

  _renderRow(s) {
    const typeLabel = {
      Trial:    SB.t.saSubTypeTrial,
      Basic:    SB.t.saSubTypeBasic,
      Standard: SB.t.saSubTypeStandard,
      Premium:  SB.t.saSubTypePremium
    }[s.activeSubscriptionType] || s.activeSubscriptionType;
    const subType = s.activeSubscriptionType
      ? `<span class="sub-pill sub-pill-live">${SB.escHtml(typeLabel)}</span>`
      : `<span class="u-text-muted">—</span>`;
    return `<tr>
      <td><div class="td-name">${SB.escHtml(s.name)}</div><div class="td-sub">${SB.escHtml(s.contactEmail)}</div></td>
      <td>${SB.escHtml(s.city)}</td>
      <td dir="ltr">${SB.escHtml(s.adminEmail)}</td>
      <td>${SB.formatDate(s.activeSubscriptionActivationDate)}</td>
      <td>${subType}</td>
      <td>${SB.formatDate(s.createdAt)}</td>
    </tr>`;
  }
};
