/**
 * SmartBus Admin — Buses page.
 * Same pattern as drivers/students: server renders everything.
 * The driver/assistant/student lists are pre-loaded inside the Form partial.
 */

const buses = {

  async load() {
    const page = document.getElementById('buses-page').value;
    const res  = await fetch(`/Buses/List?page=${page}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
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

  async openForm(id) {
    const url = id ? `/Buses/Form?id=${id}` : '/Buses/Form';
    const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    document.getElementById('bus-form-container').innerHTML = await res.text();
    SB.openModal('modal-bus');
    this._wireStudentCheckboxes();
  },

  _wireStudentCheckboxes() {
    document.querySelectorAll('#bf-students-list input[type=checkbox]').forEach(cb => {
      cb.addEventListener('change', () => this._updateSelectedCount());
    });
  },

  _updateSelectedCount() {
    const count = document.querySelectorAll('#bf-students-list input[type=checkbox]:checked').length;
    const el = document.getElementById('bf-selected-count');
    if (el) el.textContent = count;
  },

  // Client-side filter — the list is pre-rendered, we just toggle visibility
  filterStudents(q) {
    const term = (q || '').trim().toLowerCase();
    document.querySelectorAll('#bf-students-list .bus-student-row').forEach(row => {
      const name = row.dataset.name || '';
      const area = row.dataset.area || '';
      row.style.display = !term || name.includes(term) || area.includes(term) ? '' : 'none';
    });
  },

  async submit(form) {
    const id   = form.dataset.id;
    const page = document.getElementById('buses-page').value;
    const url  = id ? `/Buses/Update?id=${id}&page=${page}` : '/Buses/Save';
    const res  = await fetch(url, {
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
      this._wireStudentCheckboxes();
    }
  },

  askDelete(btn) {
    document.getElementById('del-item-name').textContent = btn.dataset.name;
    document.getElementById('del-item-type').textContent = btn.dataset.type;
    document.getElementById('del-confirm-btn').onclick   = () => this._confirmDelete(btn.dataset.id);
    SB.openModal('modal-delete');
  },

  async _confirmDelete(id) {
    const page = document.getElementById('buses-page').value;
    const res  = await fetch(`/Buses/Delete?id=${id}&page=${page}`, {
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
