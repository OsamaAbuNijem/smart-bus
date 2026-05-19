/**
 * TilmezBus Super-Admin — Dashboard (overview) page.
 *
 * Stat cards are server-rendered via the SuperAdminDashboardController
 * action (mirrors the admin DashboardController pattern). The only thing
 * still loaded client-side is the "recent schools" preview table — the
 * existing /schools endpoint already supports pagination and the row
 * rendering reuses the same helpers as the Schools page.
 */
const dashboard = {
  async loadRecentSchools() {
    const data = await SB.api.get('/schools?pageNumber=1&pageSize=5');
    const tbody = document.getElementById('overview-schools-tbody');
    if (!tbody) return;
    const items = data?.items || [];
    if (!items.length) {
      tbody.innerHTML = `<tr><td colspan="5"><div class="empty-state empty-state-sm">
        <div class="empty-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2" stroke-linecap="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg></div>
        <div class="empty-title">${SB.escHtml(SB.t.saDashEmptyTitle || 'No schools yet')}</div>
        <div class="empty-sub">${SB.escHtml(SB.t.saDashEmptyHint  || 'Add the first school to the platform')}</div>
      </div></td></tr>`;
      return;
    }
    tbody.innerHTML = items.slice(0, 5).map(dashboard._renderRow).join('');
  },

  _renderRow(s) {
    const typeLabel = {
      Trial:    SB.t.saSubTypeTrial,
      Basic:    SB.t.saSubTypeBasic,
      Standard: SB.t.saSubTypeStandard,
      Premium:  SB.t.saSubTypePremium
    }[s.lastSubscriptionType] || s.lastSubscriptionType;
    const subType = s.lastSubscriptionType
      ? `<span class="sub-pill sub-pill-live">${SB.escHtml(typeLabel)}</span>`
      : `<span class="u-text-muted">—</span>`;
    // 2-state status pill mirrors the schools grid (active / inactive).
    const now = new Date();
    const act = s.lastSubscriptionActivationDate ? new Date(s.lastSubscriptionActivationDate) : null;
    const exp = s.lastSubscriptionExpirationDate ? new Date(s.lastSubscriptionExpirationDate) : null;
    const isActive = !!s.lastSubscriptionIsActive && act && act <= now && exp && exp >= now;
    const statusPill = s.lastSubscriptionType
      ? (isActive
          ? `<span class="sub-pill sub-pill-live">${SB.escHtml(SB.t.saStatusActive   || 'Active')}</span>`
          : `<span class="sub-pill sub-pill-off">${SB.escHtml(SB.t.saStatusInactive || 'Inactive')}</span>`)
      : `<span class="u-text-muted">—</span>`;
    return `<tr>
      <td><div class="td-name">${SB.escHtml(s.name)}</div><div class="td-sub" dir="ltr">${SB.escHtml(s.adminEmail)}</div></td>
      <td>${SB.escHtml(s.city)}</td>
      <td>${subType}</td>
      <td>${SB.formatDate(s.lastSubscriptionActivationDate)}</td>
      <td>${statusPill}</td>
    </tr>`;
  }
};
