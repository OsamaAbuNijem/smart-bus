/**
 * SmartBus Admin — Drivers page.
 * Mutations (Save/Update/Delete) return { result, html, page } so one round-trip
 * handles the POST + list refresh.
 */

const drivers = {

  // GET /Drivers/List → HTML rows
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
    document.getElementById('drivers-total').textContent = totalCount;
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
  }
};

document.addEventListener('DOMContentLoaded', () => drivers.load());
