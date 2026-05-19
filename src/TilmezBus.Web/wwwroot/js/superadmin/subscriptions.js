/**
 * TilmezBus Super-Admin — Subscriptions page (per-school manage).
 *
 * Picks a school, lists every Subscription row newest-activation first.
 * Status pill is computed client-side from IsActive + date range.
 * Create + Edit go through POST /schools/{id}/subscriptions and
 * PUT /subscriptions/{id}; the server enforces one-active-per-school.
 */
const subscriptions = {
  schoolId: null,
  items: [],
  _typeNames: ['Trial', 'Basic', 'Standard', 'Premium'],
  _strings: null,
  // Optional callback invoked after a successful save — used by the Schools
  // drawer to refresh the active-subscription panel without a full reload.
  _onSaved: null,
  // Per-modal flag so the cross-page handlers only attach once even if
  // multiple SA pages call initModal() during their bootstrap.
  _modalReady: false,

  /**
   * Modal-only wiring. Safe to call on any super-admin page (the modal
   * markup lives in the shared layout). Idempotent.
   */
  initModal() {
    if (subscriptions._modalReady) return;
    subscriptions._strings = subscriptions._readStrings();
    if (!document.getElementById('modal-subscription')) return;
    document.getElementById('sub-save-btn')  ?.addEventListener('click', subscriptions.save);
    document.getElementById('sub-close-btn') ?.addEventListener('click', subscriptions._close);
    document.getElementById('sub-cancel-btn')?.addEventListener('click', subscriptions._close);
    document.getElementById('sub-pay-add-btn')?.addEventListener('click', subscriptions.addPayment);
    // Mirror Price → Remaining live so the SuperAdmin sees the projected
    // balance immediately when editing Price (server confirms on save).
    document.getElementById('sub-price')?.addEventListener('input', subscriptions._refreshRemainingFromPayments);
    subscriptions._modalReady = true;
  },

  _close() { SB.closeModal('modal-subscription'); subscriptions._onSaved = null; },

  /**
   * Subscriptions page (per-school list) bootstrap. Adds the school-select
   * + grid wiring on top of the shared modal init.
   */
  async init() {
    subscriptions.initModal();
    const sel = document.getElementById('sub-school-select');
    if (!sel) return;
    sel.addEventListener('change', () => subscriptions.loadFor(sel.value));
    document.getElementById('sub-add-btn')?.addEventListener('click', subscriptions.openCreate);
    document.getElementById('sub-tbody')?.addEventListener('click', e => {
      const btn = e.target.closest('button[data-sub-id]');
      if (!btn) return;
      const row = subscriptions.items.find(s => s.id === btn.dataset.subId);
      if (row) subscriptions._openEdit(row);
    });
    await subscriptions._loadSchools();
  },

  /**
   * Open the edit modal for a specific school + subscription. Called from
   * the Schools drawer's "Update subscription" button. `onSaved` is invoked
   * after a successful save so the caller can refresh its own view.
   */
  openForSchool(schoolId, sub, onSaved) {
    if (!schoolId) return;
    subscriptions.initModal();
    subscriptions.schoolId = schoolId;
    subscriptions._onSaved = typeof onSaved === 'function' ? onSaved : null;
    if (sub) {
      subscriptions._openEdit(sub);
    } else {
      // No active sub yet — open the create flow targeting this school.
      const modal = document.getElementById('modal-subscription');
      SB.setText('sub-modal-title', modal?.dataset.titleCreate || 'New subscription');
      document.getElementById('sub-id').value = '';
      document.getElementById('sub-target-school').value = schoolId;
      const today = new Date();
      const inOneYear = new Date(today.getFullYear() + 1, today.getMonth(), today.getDate());
      const iso = d => d.toISOString().slice(0, 10);
      const setVal = (id, v) => { const el = document.getElementById(id); if (el) el.value = v; };
      setVal('sub-activation',   iso(today));
      setVal('sub-expiration',   iso(inOneYear));
      setVal('sub-type',         '0');
      setVal('sub-active',       'true');
      setVal('sub-max-students', '500');
      setVal('sub-max-buses',    '20');
      setVal('sub-price',        '0');
      setVal('sub-paid',         'false');
      setVal('sub-remaining',    '0');
      subscriptions._hideError();
      SB.openModal('modal-subscription');
    }
  },

  async _loadSchools() {
    const sel = document.getElementById('sub-school-select');
    const data = await SB.api.get('/schools?pageNumber=1&pageSize=200');
    const list = (data?.items || []).slice().sort((a, b) => (a.name || '').localeCompare(b.name || ''));
    const placeholderText = sel.querySelector('option[value=""]')?.textContent || '—';
    sel.innerHTML = `<option value="">${SB.escHtml(placeholderText)}</option>` +
      list.map(s => `<option value="${SB.escHtml(s.id)}">${SB.escHtml(s.name)}</option>`).join('');
  },

  async loadFor(schoolId) {
    subscriptions.schoolId = schoolId || null;
    const tbody  = document.getElementById('sub-tbody');
    const addBtn = document.getElementById('sub-add-btn');
    if (!tbody || !addBtn) return;
    if (!subscriptions.schoolId) {
      addBtn.disabled = true;
      subscriptions._empty(tbody, subscriptions._strings.pickSchool);
      return;
    }
    addBtn.disabled = false;
    subscriptions._empty(tbody, '…');
    const res = await SB.api.get(`/schools/${subscriptions.schoolId}/subscriptions`);
    if (!Array.isArray(res)) {
      subscriptions._empty(tbody, subscriptions._strings.failed, true);
      return;
    }
    subscriptions.items = res;
    if (res.length === 0) {
      subscriptions._empty(tbody, subscriptions._strings.noSubs);
      return;
    }
    tbody.innerHTML = res.map(subscriptions._renderRow).join('');
  },

  openCreate() {
    if (!subscriptions.schoolId) return;
    const modal = document.getElementById('modal-subscription');
    SB.setText('sub-modal-title', modal?.dataset.titleCreate || 'New subscription');
    document.getElementById('sub-id').value = '';
    document.getElementById('sub-target-school').value = subscriptions.schoolId;
    // Payments section is meaningless before the sub exists — hide it.
    document.getElementById('sub-payments-section')?.classList.add('u-hidden');
    const today = new Date();
    const inOneYear = new Date(today.getFullYear() + 1, today.getMonth(), today.getDate());
    const iso = d => d.toISOString().slice(0, 10);
    const setVal = (id, v) => { const el = document.getElementById(id); if (el) el.value = v; };
    setVal('sub-activation',   iso(today));
    setVal('sub-expiration',   iso(inOneYear));
    setVal('sub-type',         '0');
    setVal('sub-active',       'true');
    setVal('sub-max-students', '500');
    setVal('sub-max-buses',    '20');
    setVal('sub-price',        '0');
    setVal('sub-paid',         'false');
    setVal('sub-remaining',    '0');
    subscriptions._hideError();
    SB.openModal('modal-subscription');
  },

  _openEdit(s) {
    const modal = document.getElementById('modal-subscription');
    SB.setText('sub-modal-title', modal?.dataset.titleEdit || 'Edit subscription');
    document.getElementById('sub-id').value = s.id;
    document.getElementById('sub-target-school').value = s.schoolId;
    // Reveal + load the payments panel for this sub.
    document.getElementById('sub-payments-section')?.classList.remove('u-hidden');
    subscriptions._resetPaymentForm();
    subscriptions._loadPayments(s.id);
    document.getElementById('sub-activation').value   = (s.activationDate || '').slice(0, 10);
    document.getElementById('sub-expiration').value   = (s.expirationDate || '').slice(0, 10);
    document.getElementById('sub-type').value         = String(subscriptions._typeToNum(s.subscriptionType));
    document.getElementById('sub-active').value       = String(!!s.isActive);
    document.getElementById('sub-max-students').value = s.maxStudents ?? 0;
    document.getElementById('sub-max-buses').value    = s.maxBuses    ?? 0;
    document.getElementById('sub-price').value        = s.price       ?? 0;
    // PaymentStatus arrives from the API as a JSON string ("Unpaid"|"Partial"|"Paid")
    // because the project's JsonStringEnumConverter is global. _paymentToNum
    // maps both the string form and any legacy int payloads.
    document.getElementById('sub-paid').value         = String(subscriptions._paymentToNum(s.paymentStatus));
    document.getElementById('sub-remaining').value    = s.remainingAmount ?? 0;
    subscriptions._hideError();
    SB.openModal('modal-subscription');
  },

  async save() {
    const id       = document.getElementById('sub-id').value;
    const schoolId = document.getElementById('sub-target-school').value;
    const actIso   = document.getElementById('sub-activation').value;
    const expIso   = document.getElementById('sub-expiration').value;
    if (!schoolId || !actIso || !expIso) {
      subscriptions._showError(subscriptions._strings.requiredErr);
      return;
    }
    const body = {
      subscriptionType: parseInt(document.getElementById('sub-type').value, 10) || 0,
      maxStudents:      parseInt(document.getElementById('sub-max-students').value, 10) || 0,
      maxBuses:         parseInt(document.getElementById('sub-max-buses').value, 10) || 0,
      activationDate:   new Date(actIso + 'T00:00:00Z').toISOString(),
      expirationDate:   new Date(expIso + 'T23:59:59Z').toISOString(),
      isActive:         document.getElementById('sub-active').value === 'true',
      price:            parseFloat(document.getElementById('sub-price').value) || 0,
      paymentStatus:    parseInt(document.getElementById('sub-paid').value, 10) || 0,
      remainingAmount:  parseFloat(document.getElementById('sub-remaining').value) || 0,
    };
    const saveBtn = document.getElementById('sub-save-btn');
    if (saveBtn) saveBtn.disabled = true;
    try {
      const res = id
        ? await SB.api.put('/subscriptions/' + id, body)
        : await SB.api.post('/schools/' + schoolId + '/subscriptions', body);
      if (!res?.ok) {
        subscriptions._showError(res?.data?.error || ('HTTP ' + res?.status));
        return;
      }
      SB.closeModal('modal-subscription');
      // Page-grid refresh (Subscriptions page only) AND a callback for any
      // drawer/caller that wired one up.
      if (document.getElementById('sub-tbody')) await subscriptions.loadFor(schoolId);
      if (subscriptions._onSaved) {
        try { await subscriptions._onSaved(); } finally { subscriptions._onSaved = null; }
      }
    } finally {
      if (saveBtn) saveBtn.disabled = false;
    }
  },

  // ── Helpers ───────────────────────────────────────────────────────────────
  _empty(tbody, msg, danger) {
    const cls = danger ? 'td-empty u-text-danger' : 'td-empty';
    tbody.innerHTML = `<tr><td colspan="10" class="${cls}">${SB.escHtml(msg)}</td></tr>`;
  },

  _renderRow(s) {
    const t = subscriptions._strings;
    const type = subscriptions._typeLabel(s.subscriptionType);
    const act  = SB.formatDate(s.activationDate);
    const exp  = SB.formatDate(s.expirationDate);
    const paidPill = subscriptions._paidPill(s.paymentStatus);
    return `
      <tr>
        <td class="u-weight-700">${SB.escHtml(type)}</td>
        <td>${SB.escHtml(act)}</td>
        <td>${SB.escHtml(exp)}</td>
        <td>${subscriptions._statusPill(s)}</td>
        <td class="u-text-center">${SB.escHtml(s.maxStudents)}</td>
        <td class="u-text-center">${SB.escHtml(s.maxBuses)}</td>
        <td>${SB.escHtml(subscriptions._money(s.price))}</td>
        <td>${paidPill}</td>
        <td>${SB.escHtml(subscriptions._money(s.remainingAmount))}</td>
        <td class="u-text-end">
          <button type="button" class="btn-secondary btn-sm" data-sub-id="${SB.escHtml(s.id)}">${SB.escHtml(t.edit)}</button>
        </td>
      </tr>`;
  },

  _statusPill(s) {
    const t = subscriptions._strings;
    const now = new Date();
    const act = new Date(s.activationDate);
    const exp = new Date(s.expirationDate);
    let label, variant;
    if (!s.isActive)    { label = t.statusOff;     variant = 'off';     }
    else if (exp < now) { label = t.statusExpired; variant = 'expired'; }
    else if (act > now) { label = t.statusFuture;  variant = 'future';  }
    else                { label = t.statusLive;    variant = 'live';    }
    return `<span class="sub-pill sub-pill-${variant}">${SB.escHtml(label)}</span>`;
  },

  _money(v) {
    const n = Number(v);
    return Number.isFinite(n) ? n.toFixed(2) : '—';
  },

  _typeToNum(v) {
    if (typeof v === 'number') return v;
    const i = subscriptions._typeNames.indexOf(String(v));
    return i >= 0 ? i : 0;
  },
  _typeLabel(v) {
    return subscriptions._strings.types[subscriptions._typeToNum(v)] ?? String(v);
  },

  _paymentNames: ['Unpaid', 'Partial', 'Paid'],
  _paymentToNum(v) {
    if (typeof v === 'number') return v;
    if (typeof v === 'boolean') return v ? 2 : 0;  // legacy data
    const i = subscriptions._paymentNames.indexOf(String(v));
    return i >= 0 ? i : 0;
  },
  // 3-state pill renderer used by the subs grid AND the schools-drawer panel.
  _paidPill(v) {
    const t = subscriptions._strings;
    const n = subscriptions._paymentToNum(v);
    if (n === 2) return `<span class="sub-pill-paid yes">${SB.escHtml(t.paidYes)}</span>`;
    if (n === 1) return `<span class="sub-pill-paid partial">${SB.escHtml(t.paidPartial)}</span>`;
    return            `<span class="sub-pill-paid no">${SB.escHtml(t.paidNo)}</span>`;
  },

  _showError(msg) {
    const box = document.getElementById('sub-error');
    if (!box) return;
    box.textContent = msg;
    box.classList.remove('u-hidden');
  },
  _hideError() {
    const box = document.getElementById('sub-error');
    if (box) box.classList.add('u-hidden');
  },

  _readStrings() {
    const d = document.getElementById('sub-strings')?.dataset || {};
    return {
      pickSchool:    d.pickSchool    || 'Pick a school.',
      noSubs:        d.noSubs        || 'No subscriptions yet.',
      failed:        d.failed        || 'Failed to load subscriptions.',
      requiredErr:   d.requiredErr   || 'School and dates are required.',
      paidYes:       d.paidYes       || 'Paid',
      paidPartial:   d.paidPartial   || 'Partial',
      paidNo:        d.paidNo        || 'Unpaid',
      edit:          d.edit          || 'Edit',
      statusLive:    d.statusLive    || 'Active',
      statusExpired: d.statusExpired || 'Expired',
      statusFuture:  d.statusFuture  || 'Future',
      statusOff:     d.statusOff     || 'Disabled',
      types: [d.type0 || 'Trial', d.type1 || 'Basic', d.type2 || 'Standard', d.type3 || 'Premium'],
      payMethods: [
        d.payMethodCash     || 'Cash',
        d.payMethodTransfer || 'Transfer',
        d.payMethodCheque   || 'Cheque',
      ],
      payEmpty:      d.payEmpty      || 'No payments recorded yet.',
      payLoadFailed: d.payLoadFailed || 'Failed to load payments.',
      payFullyPaid:        d.payFullyPaid        || 'Subscription is fully paid — no further payments accepted.',
      payExceedsRemaining: d.payExceedsRemaining || 'Payment exceeds the remaining amount ({0}).',
    };
  },

  // ── Subscription payments ────────────────────────────────────────────────
  /**
   * Defaults the date input to today and clears the rest of the inline form.
   */
  _resetPaymentForm() {
    const today = new Date().toISOString().slice(0, 10);
    const setVal = (id, v) => { const el = document.getElementById(id); if (el) el.value = v; };
    setVal('sub-pay-date',   today);
    setVal('sub-pay-amount', '');
    setVal('sub-pay-method', '0');
    document.getElementById('sub-pay-error')?.classList.add('u-hidden');
  },

  async _loadPayments(subId) {
    const tbody = document.getElementById('sub-pay-tbody');
    if (!tbody) return;
    tbody.innerHTML = `<tr><td colspan="3" class="td-empty">${SB.escHtml(SB.t.saLoading || 'Loading…')}</td></tr>`;
    const rows = await SB.api.get('/subscriptions/' + subId + '/payments');
    subscriptions._renderPayments(rows);
    // Re-derive Remaining + PaymentStatus from the now-rendered rows so
    // the readonly fields match the server's view.
    subscriptions._refreshRemainingFromPayments();
  },

  _renderPayments(rows) {
    const t = subscriptions._strings;
    const tbody = document.getElementById('sub-pay-tbody');
    if (!tbody) return;
    if (!Array.isArray(rows)) {
      tbody.innerHTML = `<tr><td colspan="3" class="td-empty u-text-danger">${SB.escHtml(t.payLoadFailed)}</td></tr>`;
      return;
    }
    if (rows.length === 0) {
      tbody.innerHTML = `<tr><td colspan="3" class="td-empty">${SB.escHtml(t.payEmpty)}</td></tr>`;
      return;
    }
    const money = v => Number.isFinite(Number(v)) ? Number(v).toFixed(2) : '—';
    const methodToNum = m => {
      if (typeof m === 'number') return m;
      const s = String(m);
      if (s === 'Transfer') return 1;
      if (s === 'Cheque')   return 2;
      return 0;  // Cash / unknown
    };
    const methodLabel = m => t.payMethods[methodToNum(m)] ?? String(m);
    tbody.innerHTML = rows.map(p => `
      <tr>
        <td>${SB.escHtml(SB.formatDate(p.paymentDate))}</td>
        <td>${SB.escHtml(money(p.amount))}</td>
        <td>${SB.escHtml(methodLabel(p.method))}</td>
      </tr>`).join('');
  },

  async addPayment() {
    const subId  = document.getElementById('sub-id').value;
    if (!subId) return;
    const dateIso = document.getElementById('sub-pay-date').value;
    const amount  = parseFloat(document.getElementById('sub-pay-amount').value);
    const method  = parseInt(document.getElementById('sub-pay-method').value, 10) || 0;
    const errEl   = document.getElementById('sub-pay-error');
    const showErr = msg => { if (errEl) { errEl.textContent = msg; errEl.classList.remove('u-hidden'); } };

    if (!dateIso || !Number.isFinite(amount) || amount <= 0) {
      showErr(subscriptions._strings.requiredErr);
      return;
    }
    // Mirror the server-side guard so the SuperAdmin gets immediate feedback.
    const remaining = subscriptions._currentRemaining();
    if (remaining <= 0) {
      showErr(subscriptions._strings.payFullyPaid);
      return;
    }
    if (amount > remaining) {
      const tmpl = subscriptions._strings.payExceedsRemaining;
      showErr(tmpl.replace('{0}', remaining.toFixed(2)));
      return;
    }
    errEl?.classList.add('u-hidden');

    const btn = document.getElementById('sub-pay-add-btn');
    if (btn) btn.disabled = true;
    try {
      const res = await SB.api.post('/subscriptions/' + subId + '/payments', {
        paymentDate: new Date(dateIso + 'T00:00:00Z').toISOString(),
        amount,
        method
      });
      if (!res?.ok) {
        if (errEl) {
          errEl.textContent = res?.data?.error || ('HTTP ' + res?.status);
          errEl.classList.remove('u-hidden');
        }
        return;
      }
      subscriptions._resetPaymentForm();
      await subscriptions._loadPayments(subId);
      // The server just recomputed RemainingAmount = Price − Σ payments.
      // Mirror that on the (readonly) Remaining input so the SuperAdmin
      // sees the new balance without closing+reopening the modal.
      subscriptions._refreshRemainingFromPayments();
    } finally {
      if (btn) btn.disabled = false;
    }
  },

  /**
   * Recomputes the sub modal's Remaining input AND the disabled Paid
   * select from the loaded payments + the Price input. Also toggles the
   * add-payment row off when the sub is fully paid. Mirrors the server
   * rule so the form preview matches what'll be persisted.
   */
  _refreshRemainingFromPayments() {
    const priceEl  = document.getElementById('sub-price');
    const remainEl = document.getElementById('sub-remaining');
    const paidEl   = document.getElementById('sub-paid');
    if (!priceEl || !remainEl) return;
    const price = parseFloat(priceEl.value) || 0;
    const paid  = subscriptions._sumPaidFromRows();
    const remaining = price - paid;
    remainEl.value = remaining.toFixed(2);
    if (paidEl) paidEl.value = String(subscriptions._deriveStatus(price, paid));
    subscriptions._togglePaymentForm(remaining);
  },

  /** Σ amounts from the payments table — empty-state row ignored. */
  _sumPaidFromRows() {
    let paid = 0;
    document.querySelectorAll('#sub-pay-tbody tr').forEach(tr => {
      // 2nd <td> = amount; the empty-state row only has 1 cell (colspan=3)
      // so it naturally produces NaN and is ignored.
      const n = parseFloat(tr.children?.[1]?.textContent);
      if (Number.isFinite(n)) paid += n;
    });
    return paid;
  },

  _currentRemaining() {
    const price = parseFloat(document.getElementById('sub-price')?.value) || 0;
    return price - subscriptions._sumPaidFromRows();
  },

  /**
   * Hide the inline add-payment row and stick a "fully paid" notice in
   * the error banner when remaining ≤ 0. Re-enables itself the moment
   * Price is bumped back up (input event re-runs the refresh).
   */
  _togglePaymentForm(remaining) {
    const addBtn = document.getElementById('sub-pay-add-btn');
    const amount = document.getElementById('sub-pay-amount');
    const date   = document.getElementById('sub-pay-date');
    const method = document.getElementById('sub-pay-method');
    const errEl  = document.getElementById('sub-pay-error');
    const fullyPaid = remaining <= 0;
    [addBtn, amount, date, method].forEach(el => { if (el) el.disabled = fullyPaid; });
    if (errEl) {
      if (fullyPaid) {
        errEl.textContent = subscriptions._strings.payFullyPaid;
        errEl.classList.remove('u-hidden');
      } else if (errEl.textContent === subscriptions._strings.payFullyPaid) {
        // Only clear the banner if it was carrying our own "fully paid"
        // message — leave validation errors alone.
        errEl.classList.add('u-hidden');
        errEl.textContent = '';
      }
    }
  },

  /**
   * 3-state PaymentStatus derived from price + total paid. Mirrors the
   * server's <c>DerivePaymentStatus</c> exactly so the disabled select
   * preview can't drift from what gets persisted.
   *   * 0 (Unpaid)  — nothing collected
   *   * 1 (Partial) — some collected but less than the price
   *   * 2 (Paid)    — collected meets or exceeds the price
   */
  _deriveStatus(price, paid) {
    if (paid <= 0)                 return 0;
    if (price > 0 && paid >= price) return 2;
    return 1;
  }
};
