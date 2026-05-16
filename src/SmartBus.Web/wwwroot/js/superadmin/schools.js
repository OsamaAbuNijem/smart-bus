/**
 * SmartBus Super-Admin — Schools page.
 * Server returns a flat SchoolDto with the active subscription's activation
 * date + type embedded; we render six columns (name, city, admin email,
 * activation date, plan badge, actions).
 */
const schools = {
  page: 1,
  totalPages: 1,
  items: [],
  // Last-typed filter values; the name field is debounced before triggering
  // a fetch so we don't pound the API on every keystroke.
  filters: { name: '', city: '', plan: '', status: '' },
  _filterDebounce: null,

  // ── Public entry points ───────────────────────────────────────────────────
  async load(page) {
    if (!page || page < 1) page = 1;
    if (page > schools.totalPages && schools.totalPages > 0) return;
    schools.page = page;
    schools._showSkeleton();

    const f = schools.filters;
    const qs = new URLSearchParams({ pageNumber: String(page), pageSize: '10' });
    if (f.name)   qs.set('name',   f.name);
    if (f.city)   qs.set('city',   f.city);
    if (f.plan)   qs.set('plan',   f.plan);
    if (f.status) qs.set('status', f.status);

    const data = await SB.api.get('/schools?' + qs.toString());
    const tbody = document.getElementById('schools-tbody');
    if (!tbody) return;
    if (!data) {
      tbody.innerHTML = `<tr><td colspan="7" class="td-empty u-text-danger">${SB.escHtml(SB.t.saSchoolsLoadFailed || 'Failed to load data')}</td></tr>`;
      return;
    }

    schools.totalPages = data.totalPages || 1;
    schools.items      = data.items || [];

    SB.setText('schools-pager-info', SB.tFormat('saSchoolsCountInfo', schools.items.length, data.totalCount));
    SB.setText('schools-pager-num',  `${page} / ${schools.totalPages}`);
    SB.setText('schools-total',      data.totalCount || 0);
    SB.updatePager('schools', page, schools.totalPages);

    schools._renderTable(schools.items);
  },

  prev() { schools.load(schools.page - 1); },
  next() { schools.load(schools.page + 1); },

  // ── Filter bar handlers ───────────────────────────────────────────────────
  applyFilters() {
    schools.filters = {
      name:   (document.getElementById('flt-name')  ?.value || '').trim(),
      city:    document.getElementById('flt-city')  ?.value || '',
      plan:    document.getElementById('flt-plan')  ?.value || '',
      status:  document.getElementById('flt-status')?.value || '',
    };
    schools.load(1);
  },
  // Debounce the name field — every keystroke shouldn't hit the API.
  onFilterDebounced() {
    clearTimeout(schools._filterDebounce);
    schools._filterDebounce = setTimeout(schools.applyFilters, 300);
  },
  resetFilters() {
    ['flt-name','flt-city','flt-plan','flt-status'].forEach(id => {
      const el = document.getElementById(id);
      if (el) el.value = '';
    });
    schools.applyFilters();
  },

  // ── Modal: create / edit ──────────────────────────────────────────────────
  openCreate() {
    schools._clearForm();
    const modal = document.getElementById('modal-school');
    SB.setText('school-modal-title', modal?.dataset.titleCreate || 'Add new school');
    document.getElementById('sch-id').value = '';
    document.getElementById('sch-password-group').classList.remove('u-hidden');
    document.getElementById('sch-subscription-section').classList.remove('u-hidden');
    // 1-year Trial sub starting today
    const today = new Date();
    const inOneYear = new Date(today.getFullYear() + 1, today.getMonth(), today.getDate());
    const iso = d => d.toISOString().slice(0, 10);
    const setVal = (id, v) => { const el = document.getElementById(id); if (el) el.value = v; };
    setVal('sch-sub-type', '0');
    setVal('sch-sub-max-students', '500');
    setVal('sch-sub-price', '0');
    setVal('sch-sub-activation', iso(today));
    setVal('sch-sub-expiration', iso(inOneYear));
    // PaymentStatus is server-derived (and the dropdown is disabled);
    // a brand-new sub has zero payments → "Unpaid" (0). Server enforces
    // this regardless of what we send.
    setVal('sch-sub-paid', '0');
    // New sub has no payments yet → Remaining mirrors Price. Wire the
    // change handler once so the readonly Remaining field stays in sync
    // as the SuperAdmin tweaks Price.
    setVal('sch-sub-remaining', '0');
    const priceEl = document.getElementById('sch-sub-price');
    if (priceEl && !priceEl._mirroredRemaining) {
      priceEl.addEventListener('input', () => {
        const v = parseFloat(priceEl.value);
        document.getElementById('sch-sub-remaining').value = Number.isFinite(v) ? v : 0;
      });
      priceEl._mirroredRemaining = true;
    }
    SB.openModal('modal-school');
    // Map needs to size against the now-visible modal; defer one tick so
    // Leaflet measures the container after layout. No starting pin → user
    // searches or clicks to set one.
    setTimeout(() => schools._initMap(null, null), 50);
  },

  openEdit(id) {
    const s = schools.items.find(x => x.id === id);
    if (!s) return;
    schools._clearForm();
    const modal = document.getElementById('modal-school');
    SB.setText('school-modal-title', modal?.dataset.titleEdit || 'Edit school');
    document.getElementById('sch-id').value     = s.id || '';
    document.getElementById('sch-password-group').classList.add('u-hidden');
    document.getElementById('sch-subscription-section').classList.add('u-hidden');
    document.getElementById('sch-name').value         = s.name || '';
    schools._setSelect('sch-city', s.city);
    document.getElementById('sch-phone').value        = schools._stripCountryDial(s.phoneNumber);
    document.getElementById('sch-admin').value        = s.adminEmail || '';
    document.getElementById('sch-contact-name').value = s.contactName || '';
    // Seed the map with the school's current pin if it has one.
    document.getElementById('sch-lat').value = s.latitude  ?? '';
    document.getElementById('sch-lng').value = s.longitude ?? '';
    // Seed the logo preview with the existing URL (if any).
    if (s.logoUrl) schools._setLogoPreview(s.logoUrl);
    SB.openModal('modal-school');
    setTimeout(() => schools._initMap(s.latitude ?? null, s.longitude ?? null), 50);
  },

  async save() {
    let valid = true;
    const required = [
      { id: 'sch-name',  err: 'err-sch-name',  wrap: 'sch-name',      test: v => v.length > 0 },
      { id: 'sch-city',  err: 'err-sch-city',  wrap: 'sch-city',      test: v => v.length > 0 },
      { id: 'sch-phone', err: 'err-sch-phone', wrap: 'grp-sch-phone', test: v => /^7[789]\d{7}$/.test(v) },
      { id: 'sch-admin', err: 'err-sch-admin', wrap: 'grp-sch-admin', test: v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) },
    ];
    required.forEach(({ id, err, wrap, test }) => {
      const el     = document.getElementById(id);
      const wrapEl = document.getElementById(wrap);
      const errEl  = document.getElementById(err);
      const ok     = test((el?.value || '').trim());
      wrapEl?.classList.toggle('err',  !ok);
      errEl?.classList.toggle('show',  !ok);
      if (!ok) valid = false;
    });
    if (!valid) return;

    const id    = document.getElementById('sch-id').value;
    const latStr = (document.getElementById('sch-lat').value || '').trim();
    const lngStr = (document.getElementById('sch-lng').value || '').trim();
    const lat    = latStr ? Number(latStr) : null;
    const lng    = lngStr ? Number(lngStr) : null;
    const logoUrl = (document.getElementById('sch-logo-url').value || '').trim() || null;
    const contactName = (document.getElementById('sch-contact-name').value || '').trim();
    const body  = {
      name:         document.getElementById('sch-name').value.trim(),
      city:         document.getElementById('sch-city').value.trim(),
      phoneNumber:  '+962' + document.getElementById('sch-phone').value.trim(),
      adminEmail:   document.getElementById('sch-admin').value.trim(),
      contactName:  contactName || null,
      latitude:     Number.isFinite(lat) ? lat : null,
      longitude:    Number.isFinite(lng) ? lng : null,
      logoUrl:      logoUrl,
      adminPassword: document.getElementById('sch-password')?.value.trim() || 'Admin@123456'
    };
    if (!id) {
      // Initial subscription only on create.
      const numI = (id) => parseInt(document.getElementById(id).value, 10);
      const numF = (id) => parseFloat(document.getElementById(id).value);
      const actIso = document.getElementById('sch-sub-activation').value;
      const expIso = document.getElementById('sch-sub-expiration').value;
      body.subscriptionType            = Number.isFinite(numI('sch-sub-type'))  ? numI('sch-sub-type')  : 0;
      body.subscriptionMaxStudents     = Number.isFinite(numI('sch-sub-max-students')) ? numI('sch-sub-max-students') : 500;
      body.subscriptionPrice           = Number.isFinite(numF('sch-sub-price')) ? numF('sch-sub-price') : 0;
      body.subscriptionPaymentStatus   = parseInt(document.getElementById('sch-sub-paid').value, 10) || 0;
      body.subscriptionRemainingAmount = Number.isFinite(numF('sch-sub-remaining')) ? numF('sch-sub-remaining') : 0;
      body.subscriptionActivationDate  = actIso ? new Date(actIso + 'T00:00:00Z').toISOString() : new Date().toISOString();
      body.subscriptionExpirationDate  = expIso ? new Date(expIso + 'T23:59:59Z').toISOString() : new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString();
    }

    const btn = document.getElementById('btn-save-school');
    if (btn) btn.disabled = true;
    const res = id
      ? await SB.api.put('/schools/' + id, body)
      : await SB.api.post('/schools', body);
    if (btn) btn.disabled = false;

    if (res?.ok) {
      SB.closeModal('modal-school');
      SB.ShowMessage(id ? (SB.t.saSchoolsUpdated || 'Updated') : (SB.t.saSchoolsCreated || 'Created'));
      schools.load(schools.page);
    } else {
      SB.ShowMessage(res?.data?.error || SB.t.saSchoolsSaveFailed || 'Save failed.', 'error');
    }
  },

  // ── Delete ────────────────────────────────────────────────────────────────
  confirmDelete(name, id) {
    const msg = SB.tFormat('saSchoolsConfirmDelete', name) || `Delete "${name}"?`;
    if (!confirm(msg)) return;
    schools._delete(id);
  },
  async _delete(id) {
    const ok = await SB.api.delete('/schools/' + id);
    if (ok) {
      SB.ShowMessage(SB.t.saSchoolsDeleted || 'Deleted');
      schools.load(schools.page);
    } else {
      SB.ShowMessage(SB.t.saSchoolsDeleteFailed || 'Delete failed.', 'error');
    }
  },

  // ── Detail drawer ─────────────────────────────────────────────────────────
  _drawerSchool: null,
  openDrawer(id) {
    const s = schools.items.find(x => x.id === id);
    if (!s) return;
    schools._drawerSchool = s;
    const initials = s.name ? s.name.trim().split(' ').map(w => w[0]).slice(0, 2).join('') : '؟';
    const av = SB.getAvatarColor(s.id);
    const avEl = document.getElementById('drw-avatar');
    if (avEl) {
      if (s.logoUrl) {
        avEl.innerHTML = `<img src="${SB.escHtml(s.logoUrl)}" alt=""
                               onerror="schools._onDrawerLogoMissing('${SB.escHtml(initials)}', '${av.bg}', '${av.text}')"/>`;
        avEl.classList.add('has-logo');
        avEl.style.background = '';
        avEl.style.color = '';
      } else {
        avEl.classList.remove('has-logo');
        avEl.textContent = initials;
        avEl.style.background = `linear-gradient(135deg, ${av.bg}, var(--pu))`;
        avEl.style.color = av.text;
      }
    }
    SB.setText('drw-name',  s.name || '');
    SB.setText('drw-city',  s.city || '');
    SB.setText('drw-phone', s.phoneNumber || '—');
    SB.setText('drw-admin', s.adminEmail  || '—');
    // Contact-name row toggles entirely when the field is unset, so the
    // drawer's contact-info section doesn't show an empty "—" row.
    const contactRow = document.getElementById('drw-contact-name-row');
    if (contactRow) {
      if (s.contactName) {
        contactRow.classList.remove('u-hidden');
        SB.setText('drw-contact-name', s.contactName);
      } else {
        contactRow.classList.add('u-hidden');
      }
    }
    SB.setText('drw-date',  s.createdAt ? SB.tFormat('saSchoolsCreatedAt', SB.formatDate(s.createdAt)) : '');
    // Active subscription panel is loaded asynchronously — the SchoolDto
    // only has the badge type/date; we need the full sub row (max students,
    // price, paid, remaining, etc.) which lives under /schools/{id}/subscriptions.
    schools._activeSub = null;
    schools._loadActiveSub(s.id);
    // Location — show coords only when the school has been pinned on the map.
    const locSec = document.getElementById('drw-location-section');
    if (locSec) {
      if (Number.isFinite(s.latitude) && Number.isFinite(s.longitude)) {
        locSec.classList.remove('u-hidden');
        SB.setText('drw-coords', `${s.latitude.toFixed(5)}, ${s.longitude.toFixed(5)}`);
      } else {
        locSec.classList.add('u-hidden');
      }
    }
    document.getElementById('school-drawer')?.classList.add('open');
    document.getElementById('drawer-overlay')?.classList.add('open');
  },
  closeDrawer() {
    document.getElementById('school-drawer')?.classList.remove('open');
    document.getElementById('drawer-overlay')?.classList.remove('open');
    schools._drawerSchool = null;
    schools._activeSub    = null;
  },

  // ── Drawer active-subscription panel ──────────────────────────────────────
  _activeSub: null,
  async _loadActiveSub(schoolId) {
    const fieldsEl = document.getElementById('drw-sub-fields');
    const badgeEl  = document.getElementById('drw-plan-badge');
    const btnLbl   = document.getElementById('drw-sub-update-label');
    if (!fieldsEl) return;
    fieldsEl.innerHTML = `<div class="drawer-sub-empty">${SB.escHtml(SB.t.saLoading || 'Loading…')}</div>`;
    const subs = await SB.api.get('/schools/' + schoolId + '/subscriptions');
    if (!Array.isArray(subs)) {
      fieldsEl.innerHTML = `<div class="drawer-sub-empty u-text-danger">${SB.escHtml(SB.t.saSchoolsLoadFailed || 'Failed to load.')}</div>`;
      return;
    }
    // "Active" = the live subscription chosen by the same rule the
    // server uses for the SchoolDto badge: IsActive && now ∈ [act, exp].
    const now = new Date();
    const active = subs.find(s =>
      s.isActive
      && new Date(s.activationDate) <= now
      && new Date(s.expirationDate) >= now);
    schools._activeSub = active || null;

    if (badgeEl) badgeEl.outerHTML = `<span id="drw-plan-badge">${schools._subBadge(active?.subscriptionType)}</span>`;
    if (btnLbl)  btnLbl.textContent = active ? (SB.t.saDrawerSubUpdate || 'Update subscription')
                                             : (SB.t.saDrawerSubCreate || 'Add subscription');

    if (!active) {
      fieldsEl.innerHTML = `<div class="drawer-sub-empty">${SB.escHtml(SB.t.saDrawerSubNone || 'No active subscription.')}</div>`;
      return;
    }
    fieldsEl.innerHTML = schools._renderActiveSubFields(active);
  },

  _renderActiveSubFields(s) {
    const T   = SB.t;
    const fmt = d => d ? SB.formatDate(d) : '—';
    const money = v => Number.isFinite(Number(v)) ? Number(v).toFixed(2) : '—';
    const cell = (k, v) => `<div class="drawer-sub-field"><div class="k">${SB.escHtml(k)}</div><div class="v">${v}</div></div>`;
    // Reuse subscriptions._paidPill so the drawer + grid stay in lockstep
    // (3-state: Paid / Partial / Unpaid).
    const paidPill = (typeof subscriptions === 'object' && subscriptions._paidPill)
      ? subscriptions._paidPill(s.paymentStatus)
      : '';
    return [
      cell(T.saSubActivationDate || 'Activation', SB.escHtml(fmt(s.activationDate))),
      cell(T.saSubExpirationDate || 'Expiration', SB.escHtml(fmt(s.expirationDate))),
      cell(T.saSubMaxStudents    || 'Max students', SB.escHtml(s.maxStudents ?? '—')),
      cell(T.saSubMaxBuses       || 'Max buses',    SB.escHtml(s.maxBuses    ?? '—')),
      cell(T.saSubPrice          || 'Price',        SB.escHtml(money(s.price))),
      cell(T.saSubRemaining      || 'Remaining',    SB.escHtml(money(s.remainingAmount))),
      cell(T.saSubPaid           || 'Payment',      paidPill),
    ].join('');
  },

  updateSubscriptionFromDrawer() {
    const s = schools._drawerSchool;
    if (!s) return;
    if (typeof subscriptions !== 'object') return;
    // Reuse the shared subscription modal. On save, reload the drawer's
    // active-sub panel + the schools grid (badge / activation date column).
    subscriptions.openForSchool(s.id, schools._activeSub, async () => {
      await schools._loadActiveSub(s.id);
      schools.load(schools.page);
    });
  },
  editFromDrawer() {
    const s = schools._drawerSchool;
    schools.closeDrawer();
    if (s) schools.openEdit(s.id);
  },
  deleteFromDrawer() {
    const s = schools._drawerSchool;
    schools.closeDrawer();
    if (s) schools.confirmDelete(s.name, s.id);
  },

  // ── Rendering ─────────────────────────────────────────────────────────────
  _hasActiveFilters() {
    const f = schools.filters;
    return !!(f.name || f.city || f.plan || f.status);
  },
  _renderTable(items) {
    const tbody = document.getElementById('schools-tbody');
    if (!tbody) return;
    if (!items.length) {
      const filtering = schools._hasActiveFilters();
      const title = filtering ? (SB.t.saSchoolsNoResults || 'No results') : (SB.t.saSchoolsNoSchools || 'No schools yet');
      const sub   = filtering
        ? (SB.t.saSchoolsFilterEmpty || 'No schools match the current filters.')
        : (SB.t.saSchoolsEmptyHint   || 'Add the first school');
      tbody.innerHTML = `<tr><td colspan="7"><div class="empty-state">
        <div class="empty-icon">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2" stroke-linecap="round">
            ${filtering
              ? '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>'
              : '<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>'}
          </svg>
        </div>
        <div class="empty-title">${title}</div>
        <div class="empty-sub">${sub}</div>
        ${filtering
          ? `<button type="button" class="btn-secondary btn-mt-12" onclick="schools.resetFilters()">${SB.escHtml(SB.t.saSchoolsFilterReset || 'Reset filters')}</button>`
          : `<button type="button" class="add-btn add-btn-center" onclick="schools.openCreate()"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#111" stroke-width="3" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>${SB.escHtml(SB.t.saSchoolsAddBtn || 'Add school')}</button>`}
      </div></td></tr>`;
      return;
    }
    tbody.innerHTML = items.map(s => schools._renderRow(s)).join('');
  },

  _renderRow(s) {
    const initials = s.name ? s.name.trim().split(' ').map(w => w[0]).slice(0, 2).join('') : '؟';
    const av    = SB.getAvatarColor(s.id);
    const q     = schools.filters.name || '';
    const name  = SB.highlight(SB.escHtml(s.name),       q);
    const city  = SB.escHtml(s.city);
    const admin = SB.escHtml(s.adminEmail);
    const activation = s.lastSubscriptionActivationDate
      ? SB.formatDate(s.lastSubscriptionActivationDate)
      : '<span class="u-text-muted">—</span>';
    // Avatar swaps to a logo thumbnail when the school has one; falls back
    // to initials on the deterministic palette. The img.onerror handler
    // also catches the case where the URL is stored but the file is gone
    // (e.g. a stale row from a prior dev cleanup) — it swaps the wrapper
    // back to the initials look at runtime.
    const avatarHtml = s.logoUrl
      ? `<div class="td-avatar has-logo">
           <img src="${SB.escHtml(s.logoUrl)}" alt=""
                onerror="schools._onLogoMissing(this, '${SB.escHtml(initials)}', '${av.bg}', '${av.text}')"/>
         </div>`
      : `<div class="td-avatar" style="background:${av.bg};color:${av.text};">${initials}</div>`;
    // Row body (everything except the actions cell) opens the side drawer.
    // The actions cell stops propagation so the inner buttons stay clickable.
    const open = `onclick="schools.openDrawer('${s.id}')" class="td-row-open"`;
    return `<tr id="row-${s.id}">
      <td ${open}>
        <div class="td-cell-row">
          ${avatarHtml}
          <div><div class="td-name">${name}</div><div class="td-sub" dir="ltr">${admin}</div></div>
        </div>
      </td>
      <td ${open}>${city}</td>
      <td ${open} dir="ltr">${admin}</td>
      <td ${open}>${activation}</td>
      <td ${open}>${schools._subBadge(s.lastSubscriptionType)}</td>
      <td ${open}>${schools._statusPill(s)}</td>
      <td onclick="event.stopPropagation()">
        <div class="tbl-actions">
          <button type="button" class="tbl-btn tbl-edit" title="${SB.escHtml(SB.t.saEdit || 'Edit')}" onclick="schools.openEdit('${s.id}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4z"/></svg>
          </button>
          <button type="button" class="tbl-btn tbl-del" title="${SB.escHtml(SB.t.saDelete || 'Delete')}" onclick="schools.confirmDelete('${SB.escHtml(s.name)}','${s.id}')">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#DC2626" stroke-width="2.5" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M9 6V4h6v2"/></svg>
          </button>
        </div>
      </td>
    </tr>`;
  },

  _showSkeleton() {
    const tbody = document.getElementById('schools-tbody');
    if (!tbody) return;
    tbody.innerHTML = [1, 2, 3, 4].map(() => `<tr class="skel-row">
      <td><div class="skel skel-h-16 skel-w-150"></div></td>
      <td><div class="skel skel-w-80"></div></td>
      <td><div class="skel skel-w-160"></div></td>
      <td><div class="skel skel-w-90"></div></td>
      <td><div class="skel skel-w-80"></div></td>
      <td></td>
    </tr>`).join('');
  },

  // ── Helpers ───────────────────────────────────────────────────────────────
  _subBadge(type) {
    if (!type) return '<span class="u-text-muted">—</span>';
    const labels = {
      Trial:    SB.t.saSubTypeTrial    || 'Trial',
      Basic:    SB.t.saSubTypeBasic    || 'Basic',
      Standard: SB.t.saSubTypeStandard || 'Standard',
      Premium:  SB.t.saSubTypePremium  || 'Premium'
    };
    const variant = ['Trial', 'Basic', 'Standard', 'Premium'].includes(type) ? type.toLowerCase() : 'trial';
    const label   = labels[type] || type;
    return `<span class="sub-pill sub-pill-${variant}">${SB.escHtml(label)}</span>`;
  },

  // Compute the 2-state status pill (active/inactive) from the school's
  // last subscription. Active = IsActive AND today ∈ [activation, expiration];
  // everything else (disabled, expired, future, or no sub) is Inactive.
  _statusPill(s) {
    if (!s.lastSubscriptionType) return '<span class="u-text-muted">—</span>';
    const T   = SB.t;
    const now = new Date();
    const act = s.lastSubscriptionActivationDate ? new Date(s.lastSubscriptionActivationDate) : null;
    const exp = s.lastSubscriptionExpirationDate ? new Date(s.lastSubscriptionExpirationDate) : null;
    const isActive = !!s.lastSubscriptionIsActive
      && act && act <= now
      && exp && exp >= now;
    const variant = isActive ? 'live' : 'off';
    const label   = isActive
      ? (T.saStatusActive   || 'Active')
      : (T.saStatusInactive || 'Inactive');
    return `<span class="sub-pill sub-pill-${variant}">${SB.escHtml(label)}</span>`;
  },

  _stripCountryDial(raw) {
    if (!raw) return '';
    const s = String(raw).trim();
    if (s.startsWith('+962'))  return s.slice(4);
    if (s.startsWith('962'))   return s.slice(3);
    if (s.startsWith('00962')) return s.slice(5);
    if (s.startsWith('0'))     return s.slice(1);
    return s;
  },

  // Set <select> value, injecting the option if missing so non-canonical
  // values (e.g. a school's city not in the dropdown list) still round-trip.
  _setSelect(selectId, value) {
    const sel = document.getElementById(selectId);
    if (!sel) return;
    const v = (value ?? '').toString();
    if (!v) { sel.value = ''; return; }
    if (!Array.from(sel.options).some(o => o.value === v)) {
      const opt = document.createElement('option');
      opt.value = v; opt.textContent = v;
      sel.appendChild(opt);
    }
    sel.value = v;
  },

  _clearForm() {
    ['sch-name','sch-city','sch-phone','sch-admin','sch-contact-name','sch-lat','sch-lng','sch-logo-url'].forEach(id => {
      const el = document.getElementById(id);
      if (el) { el.value = ''; el.classList.remove('err'); }
    });
    ['err-sch-name','err-sch-city','err-sch-phone','err-sch-admin','err-sch-logo'].forEach(id => {
      document.getElementById(id)?.classList.remove('show');
    });
    ['grp-sch-phone','grp-sch-admin'].forEach(id => {
      document.getElementById(id)?.classList.remove('err');
    });
    const pw       = document.getElementById('sch-password');         if (pw)       pw.value       = '';
    const search   = document.getElementById('sch-map-search');       if (search)   search.value   = '';
    const results  = document.getElementById('sch-map-search-results'); if (results) { results.innerHTML = ''; results.classList.remove('is-open'); }
    const coordsEl = document.getElementById('sch-map-coords-label');
    if (coordsEl) coordsEl.textContent = SB.t.saSchoolMapNoPin || 'No location selected.';
    schools._setLogoPreview(null);
    const fileInput = document.getElementById('sch-logo-file');
    if (fileInput) fileInput.value = '';
  },

  // ── Logo upload ───────────────────────────────────────────────────────────
  pickLogo()  { document.getElementById('sch-logo-file')?.click(); },
  clearLogo() {
    document.getElementById('sch-logo-url').value = '';
    schools._setLogoPreview(null);
    const fileInput = document.getElementById('sch-logo-file');
    if (fileInput) fileInput.value = '';
  },
  async onLogoFile(ev) {
    const file = ev?.target?.files?.[0];
    if (!file) return;
    const errEl = document.getElementById('err-sch-logo');
    errEl?.classList.remove('show');
    const fd = new FormData();
    fd.append('file', file);
    // Web hosts /SuperAdmin/Uploads/SchoolLogo itself — no API roundtrip
    // needed. The returned /uploads/schools/<file> URL is served by the
    // Web project's UseStaticFiles middleware.
    try {
      const res = await fetch('/SuperAdmin/Uploads/SchoolLogo', {
        method:  'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        body:    fd
      });
      if (!res.ok) { errEl?.classList.add('show'); return; }
      const data = await res.json();
      if (!data?.url) { errEl?.classList.add('show'); return; }
      document.getElementById('sch-logo-url').value = data.url;
      schools._setLogoPreview(data.url);
    } catch { errEl?.classList.add('show'); }
  },

  // ── Reset school admin password ──────────────────────────────────────────
  /**
   * Opens the reset-admin-password modal targeting the drawer's current
   * school. Pre-fills the "target email" subtitle so the SuperAdmin can
   * see whose password they're about to overwrite.
   */
  openResetAdminPassword() {
    const s = schools._drawerSchool;
    if (!s) return;
    SB.setText('rap-target-email', s.adminEmail || '');
    ['rap-new', 'rap-confirm'].forEach(id => {
      const el = document.getElementById(id);
      if (el) el.value = '';
    });
    ['grp-rap-new', 'grp-rap-confirm'].forEach(id =>
      document.getElementById(id)?.classList.remove('err'));
    ['err-rap-new', 'err-rap-confirm'].forEach(id =>
      document.getElementById(id)?.classList.remove('show'));
    document.getElementById('rap-server-err')?.classList.add('u-hidden');
    SB.openModal('modal-reset-admin-password');
  },

  async resetAdminPassword() {
    const s = schools._drawerSchool;
    if (!s) return;
    const newPwd  = document.getElementById('rap-new')?.value     ?? '';
    const confirm = document.getElementById('rap-confirm')?.value ?? '';

    let valid = true;
    const setErr = (errId, wrapId, show) => {
      document.getElementById(errId)?.classList.toggle('show', show);
      document.getElementById(wrapId)?.classList.toggle('err',  show);
      if (show) valid = false;
    };
    setErr('err-rap-new',     'grp-rap-new',     newPwd.length < 8);
    setErr('err-rap-confirm', 'grp-rap-confirm', newPwd !== confirm);
    if (!valid) return;

    const btn = document.getElementById('btn-rap-save');
    if (btn) btn.disabled = true;
    const srv = document.getElementById('rap-server-err');
    try {
      const res = await SB.api.post('/schools/' + s.id + '/reset-admin-password',
        { newPassword: newPwd });
      if (res?.ok) {
        SB.closeModal('modal-reset-admin-password');
        SB.ShowMessage(SB.t.saResetPwdSuccess || 'Admin password reset ✓');
      } else {
        const msg = res?.data?.error || SB.t.saResetPwdFailed || 'Failed to reset password.';
        if (srv) { srv.textContent = msg; srv.classList.remove('u-hidden'); }
      }
    } finally {
      if (btn) btn.disabled = false;
    }
  },

  /**
   * Grid avatar img.onerror handler — swaps the wrapper from a broken
   * <img> back to the initials look so the row doesn't show a busted
   * placeholder. Triggered when the file the DB references no longer
   * exists on disk.
   */
  _onLogoMissing(img, initials, bg, text) {
    const wrap = img.closest('.td-avatar');
    if (!wrap) return;
    wrap.classList.remove('has-logo');
    wrap.setAttribute('style', `background:${bg};color:${text};`);
    wrap.textContent = initials;
  },
  /**
   * Drawer avatar variant of the same fallback — the drawer-avatar uses
   * a different gradient when rendering initials.
   */
  _onDrawerLogoMissing(initials, bg, text) {
    const avEl = document.getElementById('drw-avatar');
    if (!avEl) return;
    avEl.classList.remove('has-logo');
    avEl.style.background = `linear-gradient(135deg, ${bg}, var(--pu))`;
    avEl.style.color = text;
    avEl.textContent = initials;
  },

  _setLogoPreview(url) {
    const img        = document.getElementById('sch-logo-preview');
    const ph         = document.getElementById('sch-logo-placeholder');
    const tile       = document.getElementById('sch-logo-tile');
    const clearBtn   = document.getElementById('sch-logo-clear-btn');
    if (url) {
      if (img)      { img.src = url; img.classList.remove('u-hidden'); }
      ph?.classList.add('u-hidden');
      tile?.classList.add('is-set');
      clearBtn?.classList.remove('u-hidden');
    } else {
      if (img)      { img.removeAttribute('src'); img.classList.add('u-hidden'); }
      ph?.classList.remove('u-hidden');
      tile?.classList.remove('is-set');
      clearBtn?.classList.add('u-hidden');
    }
  },

  // ── Leaflet map picker ────────────────────────────────────────────────────
  _map: null,
  _marker: null,
  _searchDebounce: null,

  _initMap(lat, lng) {
    if (typeof L === 'undefined') return;  // leaflet not loaded
    const container = document.getElementById('sch-map');
    if (!container) return;
    // Wipe any prior instance: opening the modal twice would otherwise
    // throw "Map container is already initialized".
    if (schools._map) { try { schools._map.remove(); } catch {} schools._map = null; schools._marker = null; }
    if (container._leaflet_id) { try { delete container._leaflet_id; } catch {} }

    // Default center: Amman (matches Std_Map default in admin students.js)
    const defaultLat = Number.isFinite(lat) ? lat : 31.9539;
    const defaultLng = Number.isFinite(lng) ? lng : 35.9106;
    const zoom       = Number.isFinite(lat) ? 15 : 12;
    schools._map = L.map(container, { zoomControl: true }).setView([defaultLat, defaultLng], zoom);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                { attribution: '© OpenStreetMap', maxZoom: 19 }).addTo(schools._map);
    if (Number.isFinite(lat) && Number.isFinite(lng)) {
      schools._marker = L.marker([lat, lng]).addTo(schools._map);
      schools._setCoordsLabel(lat, lng);
    }
    schools._map.on('click', e => schools._placePin(e.latlng.lat, e.latlng.lng));

    // Nominatim search — same pattern admin students.js uses for parent address picker.
    const searchEl  = document.getElementById('sch-map-search');
    const resultsEl = document.getElementById('sch-map-search-results');
    if (searchEl && resultsEl) {
      searchEl.oninput = () => {
        clearTimeout(schools._searchDebounce);
        const q = searchEl.value.trim();
        if (q.length < 3) { resultsEl.classList.remove('is-open'); return; }
        schools._searchDebounce = setTimeout(async () => {
          try {
            const lang = SB.t.isRtl ? 'ar' : 'en';
            const r    = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(q)}&countrycodes=jo&limit=5&accept-language=${lang}`);
            const items = await r.json();
            if (!items.length) { resultsEl.classList.remove('is-open'); return; }
            resultsEl.innerHTML = items.map(it =>
              `<div class="map-search-result"
                    onmousedown="schools._selectSearch(${it.lat}, ${it.lon}, '${(it.display_name || '').split(',')[0].replace(/'/g,'&apos;').replace(/&quot;/g,'&quot;')}')">
                 ${SB.escHtml(it.display_name)}
               </div>`
            ).join('');
            resultsEl.classList.add('is-open');
          } catch { resultsEl.classList.remove('is-open'); }
        }, 400);
      };
      searchEl.onblur = () => setTimeout(() => resultsEl.classList.remove('is-open'), 200);
    }
  },

  _selectSearch(lat, lng, label) {
    const resultsEl = document.getElementById('sch-map-search-results');
    if (resultsEl) resultsEl.classList.remove('is-open');
    const searchEl = document.getElementById('sch-map-search');
    if (searchEl) searchEl.value = label;
    if (schools._map) schools._map.flyTo([lat, lng], 16, { duration: 1 });
    schools._placePin(lat, lng);
  },

  _placePin(lat, lng) {
    document.getElementById('sch-lat').value = lat;
    document.getElementById('sch-lng').value = lng;
    if (schools._marker) schools._map.removeLayer(schools._marker);
    schools._marker = L.marker([lat, lng]).addTo(schools._map);
    schools._setCoordsLabel(lat, lng);
  },

  _setCoordsLabel(lat, lng) {
    const el = document.getElementById('sch-map-coords-label');
    if (el) el.textContent = `${Number(lat).toFixed(5)}, ${Number(lng).toFixed(5)}`;
  }
};
