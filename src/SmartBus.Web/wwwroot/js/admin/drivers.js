/**
 * SmartBus Admin — Drivers + Assistants page.
 *
 * Grid: every field is inline-editable. Name + phone commit on blur/Enter;
 * type + status are clickable pills that flip on click. The only action
 * column button is delete. New drivers come in through the slim form
 * modal (name / phone / type). Status defaults to Active server-side.
 *
 * Phone is shown as a 9-digit local part next to a "+962" chip; the
 * server still stores "0XXXXXXXXX" so we prepend "0" on every submit.
 */
const drivers = {

  async load() {
    const page   = document.getElementById('drivers-page').value;
    const filter = document.getElementById('drivers-filter').value;
    const url    = `/Drivers/List?page=${page}` + (filter ? `&driverType=${filter}` : '');
    const res    = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    if (res.status === 401) { location.href = '/Account/Login'; return; }
    this._renderList(await res.text());
  },

  _renderList(html) {
    document.getElementById('drivers-tbody').innerHTML = html;
    this._updatePager();
  },

  _updatePager() {
    const meta = document.querySelector('#drivers-tbody tr.u-hidden td[data-pager-info]');
    if (!meta) return;
    const page       = parseInt(document.getElementById('drivers-page').value) || 1;
    const totalPages = parseInt(meta.dataset.totalPages) || 1;
    const totalCount = meta.dataset.totalCount || 0;
    document.getElementById('drivers-pager-info').textContent = meta.dataset.pagerInfo;
    const totalEl = document.getElementById('drivers-total');
    if (totalEl) totalEl.textContent = totalCount;
    document.getElementById('drivers-prev').disabled = page <= 1;
    document.getElementById('drivers-next').disabled = page >= totalPages;
  },

  filter(type, btn) {
    document.querySelectorAll('.filter-bar .filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById('drivers-filter').value = type;
    document.getElementById('drivers-page').value   = 1;
    this.load();
  },

  goto(page) { document.getElementById('drivers-page').value = page; this.load(); },
  prev() { this.goto(parseInt(document.getElementById('drivers-page').value) - 1); },
  next() { this.goto(parseInt(document.getElementById('drivers-page').value) + 1); },

  // ── Add form (single-row create) ────────────────────────────────────────
  async openForm() {
    const res = await fetch('/Drivers/Form', { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    document.getElementById('driver-form-container').innerHTML = await res.text();
    SB.openModal('modal-driver');
  },

  async submit(form) {
    // Phone input carries the 9-digit local part next to the "+962" chip.
    // No normalisation: the server validates the raw 9 digits (and also
    // accepts the legacy "0…" / canonical "+962…" shapes for round-trips).
    const res = await fetch('/Drivers/Save', {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      body: new FormData(form)
    });
    if (res.ok) {
      const { result, html, page: newPage } = await res.json();
      SB.closeModal('modal-driver');
      if (newPage) document.getElementById('drivers-page').value = newPage;
      if (html)    this._renderList(html);
      if (result)  SB.ShowMessage(result);
    } else if (res.status === 502) {
      const { result } = await res.json().catch(() => ({}));
      SB.ShowMessage(result || 'Upstream API error');
    } else {
      document.getElementById('driver-form-container').innerHTML = await res.text();
    }
  },

  // ── Inline grid edits ───────────────────────────────────────────────────
  commit(input) {
    const id       = input.dataset.id;
    const field    = input.dataset.field;
    const original = input.dataset.original || '';
    let   value    = (input.value || '').trim();
    if (!id || !field || value === original) { input.value = original; return; }
    if (!value) { input.value = original; return; }
    // Phone is the raw 9-digit local part (the "+962" chip is purely visual).
    const payload = { [field]: value };
    this._patch(id, payload, () => { input.dataset.original = value; });
  },

  onKey(e) {
    if (e.key === 'Enter')  { e.preventDefault(); e.target.blur(); }
    if (e.key === 'Escape') { e.target.value = e.target.dataset.original || ''; e.target.blur(); }
  },

  toggleStatus(btn) {
    const id      = btn.dataset.id;
    const current = btn.dataset.current === 'true';
    this._patch(id, { isActive: !current });
  },

  toggleType(btn) {
    const id   = btn.dataset.id;
    const next = btn.dataset.current === 'Assistant' ? 'Driver' : 'Assistant';
    this._patch(id, { driverType: next });
  },

  async _patch(id, body, onSuccess) {
    const page   = document.getElementById('drivers-page').value;
    const filter = document.getElementById('drivers-filter').value;
    const fd = new FormData();
    Object.entries(body).forEach(([k, v]) => fd.append(k, v));
    const url = `/Drivers/UpdateField?id=${id}&page=${page}${filter ? '&typeFilter=' + filter : ''}`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      body: fd
    });
    if (res.ok) {
      const { result, html } = await res.json();
      if (html)   this._renderList(html);
      if (result) SB.ShowMessage(result);
      onSuccess?.();
    } else {
      const { result } = await res.json().catch(() => ({}));
      SB.ShowMessage(result || 'Update failed');
      this.load(); // refresh to revert visual state on conflict
    }
  },

  // ── Delete ──────────────────────────────────────────────────────────────
  askDelete(btn) {
    document.getElementById('del-item-name').textContent = btn.dataset.name;
    document.getElementById('del-item-type').textContent = btn.dataset.type;
    document.getElementById('del-confirm-btn').onclick   = () => this._confirmDelete(btn.dataset.id);
    SB.openModal('modal-delete');
  },

  async _confirmDelete(id) {
    const page   = document.getElementById('drivers-page').value;
    const filter = document.getElementById('drivers-filter').value;
    const url    = `/Drivers/Delete?id=${id}&page=${page}${filter ? '&driverType=' + filter : ''}`;
    const res    = await fetch(url, {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    });
    SB.closeModal('modal-delete');
    if (res.ok) {
      const { result, html } = await res.json();
      if (html)   this._renderList(html);
      if (result) SB.ShowMessage(result);
    }
  },

  // ── Export / Template / Import ──────────────────────────────────────────
  exportFile() {
    const filter = document.getElementById('drivers-filter').value;
    location.href = '/Drivers/Export' + (filter ? '?driverType=' + filter : '');
  },
  downloadTemplate() { location.href = '/Drivers/Template'; },

  openImport() {
    document.getElementById('drivers-import-file').value = '';
    SB.openModal('modal-drivers-import');
  },

  async submitImport() {
    const input = document.getElementById('drivers-import-file');
    const file  = input.files?.[0];
    if (!file) { SB.ShowMessage('Choose a file'); return; }
    const fd = new FormData();
    fd.append('file', file);
    const res = await fetch('/Drivers/Import', {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      body: fd
    });
    if (res.ok) {
      const { result, html } = await res.json();
      SB.closeModal('modal-drivers-import');
      if (html)   this._renderList(html);
      if (result) SB.ShowMessage(result);
    } else {
      const { result } = await res.json().catch(() => ({}));
      SB.ShowMessage(result || 'Import failed');
    }
  }
};

document.addEventListener('DOMContentLoaded', () => drivers.load());
