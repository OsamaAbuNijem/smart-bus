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
  search: '',
  _searchDebounce: null,

  // ── Public entry points ───────────────────────────────────────────────────
  async load(page) {
    if (!page || page < 1) page = 1;
    if (page > schools.totalPages && schools.totalPages > 0) return;
    schools.page = page;
    schools._showSkeleton();

    const data = await SB.api.get(`/schools?pageNumber=${page}&pageSize=10`);
    const tbody = document.getElementById('schools-tbody');
    if (!tbody) return;
    if (!data) {
      tbody.innerHTML = `<tr><td colspan="6" class="td-empty u-text-danger">${SB.escHtml(SB.t.saSchoolsLoadFailed || 'Failed to load data')}</td></tr>`;
      return;
    }

    schools.totalPages = data.totalPages || 1;
    schools.items      = data.items || [];

    SB.setText('schools-pager-info', SB.tFormat('saSchoolsCountInfo', schools.items.length, data.totalCount));
    SB.setText('schools-pager-num',  `${page} / ${schools.totalPages}`);
    SB.setText('schools-total',      data.totalCount || 0);
    SB.setText('schools-count-badge', data.totalCount || 0);
    SB.updatePager('schools', page, schools.totalPages);

    schools._renderTable(schools._applySearch());
  },

  prev() { schools.load(schools.page - 1); },
  next() { schools.load(schools.page + 1); },

  // Search input handler (debounced) — filters in-memory on the current page.
  onSearchInput(val) {
    schools.search = (val || '').trim();
    clearTimeout(schools._searchDebounce);
    schools._searchDebounce = setTimeout(() => {
      schools._renderTable(schools._applySearch());
    }, 200);
  },
  clearSearch() {
    schools.search = '';
    const input = document.getElementById('topbar-search-input');
    if (input) input.value = '';
    schools._renderTable(schools._applySearch());
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
    setVal('sch-sub-price', '0');
    setVal('sch-sub-activation', iso(today));
    setVal('sch-sub-expiration', iso(inOneYear));
    setVal('sch-sub-paid', 'false');
    setVal('sch-sub-remaining', '0');
    SB.openModal('modal-school');
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
    document.getElementById('sch-name').value   = s.name || '';
    schools._setSelect('sch-city', s.city);
    document.getElementById('sch-email').value  = s.contactEmail || '';
    document.getElementById('sch-phone').value  = schools._stripCountryDial(s.phoneNumber);
    document.getElementById('sch-admin').value  = s.adminEmail || '';
    document.getElementById('sch-notes').value  = s.notes || '';
    SB.openModal('modal-school');
  },

  async save() {
    let valid = true;
    const required = [
      { id: 'sch-name',  err: 'err-sch-name',  wrap: 'sch-name',      test: v => v.length > 0 },
      { id: 'sch-city',  err: 'err-sch-city',  wrap: 'sch-city',      test: v => v.length > 0 },
      { id: 'sch-email', err: 'err-sch-email', wrap: 'grp-sch-email', test: v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) },
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
    const body  = {
      name:         document.getElementById('sch-name').value.trim(),
      city:         document.getElementById('sch-city').value.trim(),
      contactEmail: document.getElementById('sch-email').value.trim(),
      phoneNumber:  '+962' + document.getElementById('sch-phone').value.trim(),
      adminEmail:   document.getElementById('sch-admin').value.trim(),
      notes:        document.getElementById('sch-notes').value.trim() || null,
      adminPassword: document.getElementById('sch-password')?.value.trim() || 'Admin@123456'
    };
    if (!id) {
      // Initial subscription only on create.
      const numI = (id) => parseInt(document.getElementById(id).value, 10);
      const numF = (id) => parseFloat(document.getElementById(id).value);
      const actIso = document.getElementById('sch-sub-activation').value;
      const expIso = document.getElementById('sch-sub-expiration').value;
      body.subscriptionType            = Number.isFinite(numI('sch-sub-type'))  ? numI('sch-sub-type')  : 0;
      body.subscriptionPrice           = Number.isFinite(numF('sch-sub-price')) ? numF('sch-sub-price') : 0;
      body.subscriptionIsPaid          = document.getElementById('sch-sub-paid').value === 'true';
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
      avEl.textContent = initials;
      avEl.style.background = `linear-gradient(135deg, ${av.bg}, var(--pu))`;
      avEl.style.color = av.text;
    }
    SB.setText('drw-name',  s.name || '');
    SB.setText('drw-city',  s.city || '');
    SB.setText('drw-email', s.contactEmail || '—');
    SB.setText('drw-phone', s.phoneNumber || '—');
    SB.setText('drw-admin', s.adminEmail  || '—');
    SB.setText('drw-date',  s.createdAt ? SB.tFormat('saSchoolsCreatedAt', SB.formatDate(s.createdAt)) : '');
    // Active subscription badge (or "—" when there's no live sub).
    const badge = document.getElementById('drw-plan-badge');
    if (badge) badge.outerHTML = `<span id="drw-plan-badge">${schools._subBadge(s.activeSubscriptionType)}</span>`;
    // Notes
    const notesSec = document.getElementById('drw-notes-section');
    if (notesSec) {
      if (s.notes) {
        notesSec.classList.remove('u-hidden');
        SB.setText('drw-notes', s.notes);
      } else {
        notesSec.classList.add('u-hidden');
      }
    }
    document.getElementById('school-drawer')?.classList.add('open');
    document.getElementById('drawer-overlay')?.classList.add('open');
  },
  closeDrawer() {
    document.getElementById('school-drawer')?.classList.remove('open');
    document.getElementById('drawer-overlay')?.classList.remove('open');
    schools._drawerSchool = null;
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
  _applySearch() {
    if (!schools.search) return schools.items.slice();
    const q = schools.search.toLowerCase();
    return schools.items.filter(s =>
      (s.name || '').toLowerCase().includes(q) ||
      (s.city || '').toLowerCase().includes(q) ||
      (s.contactEmail || '').toLowerCase().includes(q) ||
      (s.adminEmail || '').toLowerCase().includes(q));
  },

  _renderTable(items) {
    const tbody = document.getElementById('schools-tbody');
    if (!tbody) return;
    if (!items.length) {
      const isSearching = !!schools.search;
      const title = isSearching ? (SB.t.saSchoolsNoResults || 'No results') : (SB.t.saSchoolsNoSchools || 'No schools yet');
      const sub   = isSearching
        ? (SB.tFormat('saSchoolsNoSearchMatch', `<strong>${SB.escHtml(schools.search)}</strong>`) || `No match for "${SB.escHtml(schools.search)}"`)
        : (SB.t.saSchoolsEmptyHint || 'Add the first school');
      tbody.innerHTML = `<tr><td colspan="6"><div class="empty-state">
        <div class="empty-icon">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="2" stroke-linecap="round">
            ${isSearching
              ? '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>'
              : '<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>'}
          </svg>
        </div>
        <div class="empty-title">${title}</div>
        <div class="empty-sub">${sub}</div>
        ${isSearching
          ? `<button type="button" class="btn-secondary btn-mt-12" onclick="schools.clearSearch()">${SB.escHtml(SB.t.saSchoolsClearSearch || 'Clear search')}</button>`
          : `<button type="button" class="add-btn add-btn-center" onclick="schools.openCreate()"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#111" stroke-width="3" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>${SB.escHtml(SB.t.saSchoolsAddBtn || 'Add school')}</button>`}
      </div></td></tr>`;
      return;
    }
    tbody.innerHTML = items.map(s => schools._renderRow(s)).join('');
  },

  _renderRow(s) {
    const initials = s.name ? s.name.trim().split(' ').map(w => w[0]).slice(0, 2).join('') : '؟';
    const av    = SB.getAvatarColor(s.id);
    const name  = SB.highlight(SB.escHtml(s.name),         schools.search);
    const city  = SB.highlight(SB.escHtml(s.city),         schools.search);
    const email = SB.highlight(SB.escHtml(s.contactEmail), schools.search);
    const admin = SB.highlight(SB.escHtml(s.adminEmail),   schools.search);
    const activation = s.activeSubscriptionActivationDate
      ? SB.formatDate(s.activeSubscriptionActivationDate)
      : '<span class="u-text-muted">—</span>';
    // Row body (everything except the actions cell) opens the side drawer.
    // The actions cell stops propagation so the inner buttons stay clickable.
    const open = `onclick="schools.openDrawer('${s.id}')" class="td-row-open"`;
    return `<tr id="row-${s.id}">
      <td ${open}>
        <div class="td-cell-row">
          <div class="td-avatar" style="background:${av.bg};color:${av.text};">${initials}</div>
          <div><div class="td-name">${name}</div><div class="td-sub">${email}</div></div>
        </div>
      </td>
      <td ${open}>${city}</td>
      <td ${open} dir="ltr">${admin}</td>
      <td ${open}>${activation}</td>
      <td ${open}>${schools._subBadge(s.activeSubscriptionType)}</td>
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
    ['sch-name','sch-city','sch-email','sch-phone','sch-admin'].forEach(id => {
      const el = document.getElementById(id);
      if (el) { el.value = ''; el.classList.remove('err'); }
    });
    ['err-sch-name','err-sch-city','err-sch-email','err-sch-phone','err-sch-admin'].forEach(id => {
      document.getElementById(id)?.classList.remove('show');
    });
    ['grp-sch-email','grp-sch-phone','grp-sch-admin'].forEach(id => {
      document.getElementById(id)?.classList.remove('err');
    });
    const notes = document.getElementById('sch-notes');    if (notes) notes.value = '';
    const pw    = document.getElementById('sch-password'); if (pw)    pw.value    = '';
  }
};
