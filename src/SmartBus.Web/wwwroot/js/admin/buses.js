/**
 * SmartBus Admin — Buses page.
 * Same pattern as drivers/students: server renders everything.
 */

const buses = {
  _searchTimer: null,

  _qs() {
    const page   = document.getElementById('buses-page').value || 1;
    const plate  = document.getElementById('buses-plate').value || '';
    const person = document.getElementById('buses-person').value || '';
    const params = new URLSearchParams({ page });
    if (plate)  params.set('plateNumber', plate);
    if (person) params.set('personName',  person);
    return params.toString();
  },

  async load() {
    const res = await fetch(`/Buses/List?${this._qs()}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    if (res.status === 401) { location.href = '/Account/Login'; return; }
    this._renderList(await res.text());
  },

  _renderList(html) {
    document.getElementById('buses-tbody').innerHTML = html;
    this._updatePager();
  },

  _updatePager() {
    const meta = document.querySelector('#buses-tbody tr.u-hidden td[data-pager-info]');
    if (!meta) return;
    const page       = parseInt(document.getElementById('buses-page').value) || 1;
    const totalPages = parseInt(meta.dataset.totalPages) || 1;
    const totalCount = meta.dataset.totalCount || 0;
    document.getElementById('buses-pager-info').textContent = meta.dataset.pagerInfo;
    document.getElementById('buses-total').textContent = totalCount;
    document.getElementById('buses-prev').disabled = page <= 1;
    document.getElementById('buses-next').disabled = page >= totalPages;
  },

  goto(p) { document.getElementById('buses-page').value = p; this.load(); },
  prev()  { this.goto(parseInt(document.getElementById('buses-page').value) - 1); },
  next()  { this.goto(parseInt(document.getElementById('buses-page').value) + 1); },

  onPlateSearch(value) {
    clearTimeout(this._searchTimer);
    this._searchTimer = setTimeout(() => {
      document.getElementById('buses-plate').value = (value || '').trim();
      document.getElementById('buses-page').value  = 1;
      this.load();
    }, 300);
  },

  onPersonSearch(value) {
    clearTimeout(this._searchTimer);
    this._searchTimer = setTimeout(() => {
      document.getElementById('buses-person').value = (value || '').trim();
      document.getElementById('buses-page').value   = 1;
      this.load();
    }, 300);
  },

  async openForm(id) {
    const url = id ? `/Buses/Form?id=${id}` : '/Buses/Form';
    const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    document.getElementById('bus-form-container').innerHTML = await res.text();
    SB.openModal('modal-bus');
  },

  async submit(form) {
    const id   = form.dataset.id;
    const base = id ? `/Buses/Update?id=${id}&${this._qs()}` : `/Buses/Save?${this._qs()}`;
    const res  = await fetch(base, {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      body: new FormData(form)
    });
    if (res.ok) {
      const { result, html, page: newPage } = await res.json();
      SB.closeModal('modal-bus');
      if (newPage) document.getElementById('buses-page').value = newPage;
      if (html)    this._renderList(html);
      if (result)  SB.ShowMessage(result);
    } else if (res.status === 502) {
      const { result } = await res.json().catch(() => ({}));
      SB.ShowMessage(result || 'Upstream API error');
    } else {
      document.getElementById('bus-form-container').innerHTML = await res.text();
    }
  },

  // ── Schedule modal ──────────────────────────────────────────────────────
  async openSchedule(id) {
    const res = await fetch(`/Buses/Schedule?id=${id}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    document.getElementById('bus-schedule-container').innerHTML = await res.text();
    SB.openModal('modal-bus-schedule');
    this._wireScheduleStudentCheckboxes();
  },

  _wireScheduleStudentCheckboxes() {
    document.querySelectorAll('#bs-students-list input[type=checkbox]').forEach(cb => {
      cb.addEventListener('change', () => this._updateScheduleSelectedCount());
    });
  },

  _updateScheduleSelectedCount() {
    const count = document.querySelectorAll('#bs-students-list input[type=checkbox]:checked').length;
    const el = document.getElementById('bs-selected-count');
    if (el) el.textContent = count;
  },

  filterScheduleStudents(q) {
    const term = (q || '').trim().toLowerCase();
    document.querySelectorAll('#bs-students-list .bus-student-row').forEach(row => {
      const name = row.dataset.name || '';
      const area = row.dataset.area || '';
      row.style.display = !term || name.includes(term) || area.includes(term) ? '' : 'none';
    });
  },

  toggleScheduleDay(cb) {
    const mask = parseInt(cb.dataset.mask) || 0;
    const hidden = document.getElementById('bs-repeat-days');
    let current = parseInt(hidden.value) || 0;
    if (cb.checked) current |= mask;
    else            current &= ~mask;
    hidden.value = current;
    cb.closest('.schedule-day').classList.toggle('active', cb.checked);
  },

  async submitSchedule(form) {
    const id  = form.dataset.id;
    const morning = form.querySelector('[name="MorningTime"]')?.value || '';
    const ret     = form.querySelector('[name="ReturnTime"]')?.value  || '';
    if (morning && ret && ret <= morning) {
      SB.ShowMessage(window.SB?.t?.busScheduleReturnAfterMorning ||
                     'Return time must be after the morning time.');
      return;
    }
    const res = await fetch(`/Buses/SaveSchedule?id=${id}&${this._qs()}`, {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      body: new FormData(form)
    });
    if (res.ok) {
      const { result, html, page: newPage } = await res.json();
      SB.closeModal('modal-bus-schedule');
      if (newPage) document.getElementById('buses-page').value = newPage;
      if (html)    this._renderList(html);
      if (result)  SB.ShowMessage(result);
    } else if (res.status === 502) {
      const { result } = await res.json().catch(() => ({}));
      SB.ShowMessage(result || 'Upstream API error');
    } else {
      document.getElementById('bus-schedule-container').innerHTML = await res.text();
      this._wireScheduleStudentCheckboxes();
    }
  },

  askDelete(btn) {
    document.getElementById('del-item-name').textContent = btn.dataset.name;
    document.getElementById('del-item-type').textContent = btn.dataset.type;
    document.getElementById('del-confirm-btn').onclick   = () => this._confirmDelete(btn.dataset.id);
    SB.openModal('modal-delete');
  },

  async _confirmDelete(id) {
    const res = await fetch(`/Buses/Delete?id=${id}&${this._qs()}`, {
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

document.addEventListener('DOMContentLoaded', () => buses.load());
