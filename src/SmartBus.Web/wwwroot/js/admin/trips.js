/**
 * SmartBus Admin — Trips page.
 * Server-rendered rows and trip-students modal. Actions via MVC POSTs.
 */

const trips = {
  _searchDebounce: null,

  async load(page) {
    if (page !== undefined) document.getElementById('trips-page').value = page;
    const p      = document.getElementById('trips-page').value;
    const name   = document.getElementById('trip-filter-name').value.trim();
    const bus    = document.getElementById('trip-filter-bus').value.trim();
    const date   = document.getElementById('trip-filter-date').value;
    const status = document.getElementById('trip-filter-status').value;
    const qs = new URLSearchParams({ page: p });
    if (name)   qs.set('personName', name);
    if (bus)    qs.set('busPlateNumber', bus);
    if (date)   qs.set('date', date);
    if (status) qs.set('status', status);
    qs.set('_t', Date.now());
    const res = await fetch(`/Trips/List?${qs}`, {
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      cache: 'no-store'
    });
    if (res.status === 401) { location.href = '/Account/Login'; return; }
    this._renderList(await res.text());
  },

  _renderList(html) {
    document.getElementById('trips-tbody').innerHTML = html;
    const meta = document.querySelector('#trips-tbody tr.u-hidden td[data-pager-info]');
    if (!meta) return;
    const page       = parseInt(document.getElementById('trips-page').value) || 1;
    const totalPages = parseInt(meta.dataset.totalPages) || 1;
    const totalCount = meta.dataset.totalCount || 0;
    document.getElementById('trips-pager-info').textContent = meta.dataset.pagerInfo;
    const totalEl = document.getElementById('trips-total');
    if (totalEl) totalEl.textContent = totalCount;
    document.getElementById('trips-prev').disabled = page <= 1;
    document.getElementById('trips-next').disabled = page >= totalPages;
  },

  debouncedSearch() {
    clearTimeout(this._searchDebounce);
    this._searchDebounce = setTimeout(() => this.load(1), 350);
  },
  clearFilter() {
    ['trip-filter-name','trip-filter-bus','trip-filter-date','trip-filter-status'].forEach(id => document.getElementById(id).value = '');
    this.load(1);
  },

  prev() { this.load(parseInt(document.getElementById('trips-page').value) - 1); },
  next() { this.load(parseInt(document.getElementById('trips-page').value) + 1); },

  start(id) {
    SB.confirm({
      title:       SB.t.confirmStartTripTitle || 'بدء الرحلة',
      body:        SB.t.confirmStartTrip      || 'هل تريد بدء هذه الرحلة؟',
      confirmText: SB.t.startAction           || 'بدء',
      onConfirm:   () => this._action(`/Trips/Start?id=${id}`)
    });
  },
  complete(id) {
    SB.confirm({
      title:       SB.t.confirmCompleteTripTitle || 'إتمام الرحلة',
      body:        SB.t.confirmCompleteTrip      || 'هل تريد إتمام هذه الرحلة؟',
      confirmText: SB.t.completeAction           || 'إتمام',
      onConfirm:   () => this._action(`/Trips/Complete?id=${id}`)
    });
  },

  async _action(url) {
    const page = document.getElementById('trips-page').value;
    const res  = await fetch(`${url}${url.includes('?') ? '&' : '?'}page=${page}`, {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    });
    if (res.ok) {
      const { result } = await res.json().catch(() => ({}));
      if (result) SB.ShowMessage(result);
      await this.load();
    } else if (res.status === 502) {
      const { result } = await res.json().catch(() => ({}));
      SB.ShowMessage(result || 'Upstream API error');
    }
  },

  askDelete(btn) {
    document.getElementById('del-item-name').textContent = btn.dataset.name;
    document.getElementById('del-item-type').textContent = btn.dataset.type;
    document.getElementById('del-confirm-btn').onclick   = () => this._confirmDelete(btn.dataset.id);
    SB.openModal('modal-delete');
  },

  async _confirmDelete(id) {
    SB.closeModal('modal-delete');
    await this._action(`/Trips/Delete?id=${id}`);
  },

  async openStudents(id, plate, typeLabel, dateStr) {
    document.getElementById('trip-students-title').textContent = `${SB.t.tripStudentsTitle || 'طلاب الرحلة'} — ${plate}`;
    document.getElementById('trip-students-sub').textContent   = `${typeLabel}  •  ${dateStr}`;
    document.getElementById('trip-students-body').innerHTML    = '<div class="u-empty-state">جاري التحميل...</div>';
    SB.openModal('modal-trip-students');
    const res = await fetch(`/Trips/Students?id=${id}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    document.getElementById('trip-students-body').innerHTML = await res.text();
  }
};

document.addEventListener('DOMContentLoaded', () => trips.load(1));
