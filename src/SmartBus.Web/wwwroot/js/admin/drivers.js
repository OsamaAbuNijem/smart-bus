/**
 * SmartBus Admin — Drivers page.
 * Mutations return { result, html, page }. Export / Import / Template mirror
 * the Students page.
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

  goto(page) {
    document.getElementById('drivers-page').value = page;
    this.load();
  },
  prev() { this.goto(parseInt(document.getElementById('drivers-page').value) - 1); },
  next() { this.goto(parseInt(document.getElementById('drivers-page').value) + 1); },

  async openForm(id) {
    const url = id ? `/Drivers/Form?id=${id}` : '/Drivers/Form';
    const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    document.getElementById('driver-form-container').innerHTML = await res.text();
    SB.openModal('modal-driver');
  },

  async submit(form) {
    const id     = form.dataset.id;
    const page   = document.getElementById('drivers-page').value;
    const filter = document.getElementById('drivers-filter').value;
    const url    = id
      ? `/Drivers/Update?id=${id}&page=${page}${filter ? '&driverType=' + filter : ''}`
      : '/Drivers/Save';
    const res    = await fetch(url, {
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

  // ── Export / Template ────────────────────────────────────────────────────
  exportFile() {
    const filter = document.getElementById('drivers-filter').value;
    location.href = '/Drivers/Export' + (filter ? '?driverType=' + filter : '');
  },
  downloadTemplate() { location.href = '/Drivers/Template'; },

  // ── Import ───────────────────────────────────────────────────────────────
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
