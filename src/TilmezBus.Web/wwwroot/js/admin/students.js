/**
 * TilmezBus Admin — Students page.
 * Server renders rows/form. Filters: name (search) + grade (dropdown).
 */

const students = {
  _filterTimer: null,

  // Read current filter state from hidden inputs (single source of truth).
  // Grade + home-area filters have been removed from the UI; the API still
  // accepts those query params but we no longer send them from this page.
  _state() {
    return {
      page: document.getElementById('students-page').value,
      name: document.getElementById('students-filter-name').value
    };
  },

  _qs({ page, name }) {
    const qs = new URLSearchParams({ page });
    if (name) qs.set('name', name);
    return qs.toString();
  },

  async load() {
    const s   = this._state();
    const res = await fetch(`/Students/List?${this._qs(s)}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    if (res.status === 401) { location.href = '/Account/Login'; return; }
    this._renderList(await res.text());
  },

  _renderList(html) {
    document.getElementById('students-tbody').innerHTML = html;
    this._updatePager();
  },

  _updatePager() {
    const meta = document.querySelector('#students-tbody tr.u-hidden td[data-pager-info]');
    if (!meta) return;
    const page       = parseInt(document.getElementById('students-page').value) || 1;
    const totalPages = parseInt(meta.dataset.totalPages) || 1;
    const totalCount = meta.dataset.totalCount || 0;
    document.getElementById('students-pager-info').textContent = meta.dataset.pagerInfo;
    const totalEl = document.getElementById('students-total');
    if (totalEl) totalEl.textContent = totalCount;
    document.getElementById('students-prev').disabled = page <= 1;
    document.getElementById('students-next').disabled = page >= totalPages;
  },

  // Pagination
  goto(p) { document.getElementById('students-page').value = p; this.load(); },
  prev()  { this.goto(parseInt(document.getElementById('students-page').value) - 1); },
  next()  { this.goto(parseInt(document.getElementById('students-page').value) + 1); },

  // Filters — only the name search remains in the UI.
  applyFilters() {
    document.getElementById('students-filter-name').value = document.getElementById('students-name-input').value.trim();
    document.getElementById('students-page').value        = 1;
    this.load();
  },

  debouncedFilter() {
    clearTimeout(this._filterTimer);
    this._filterTimer = setTimeout(() => this.applyFilters(), 350);
  },

  // Export — include current filters so the exported file matches what the user sees
  exportFile() {
    const s  = this._state();
    const qs = new URLSearchParams();
    if (s.name) qs.set('name', s.name);
    location.href = '/Students/Export' + (qs.toString() ? '?' + qs : '');
  },

  // Empty template with the required columns + one example row
  downloadTemplate() {
    location.href = '/Students/Template';
  },

  async openForm(id) {
    const url = id ? `/Students/Form?id=${id}` : '/Students/Form';
    const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    document.getElementById('student-form-container').innerHTML = await res.text();
    SB.openModal('modal-student');
  },

  async submit(form) {
    const s     = this._state();
    const id    = form.dataset.id;
    const extra = `&page=${s.page}`
                + (s.name ? '&name=' + encodeURIComponent(s.name) : '');
    const url   = id ? `/Students/Update?id=${id}${extra}` : '/Students/Save';
    const res   = await fetch(url, {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      body: new FormData(form)
    });
    if (res.ok) {
      const { result, html, page: newPage } = await res.json();
      SB.closeModal('modal-student');
      if (newPage) document.getElementById('students-page').value = newPage;
      if (html)    this._renderList(html);
      if (result)  SB.ShowMessage(result);
    } else if (res.status === 502) {
      const { result } = await res.json().catch(() => ({}));
      SB.ShowMessage(result || 'Upstream API error');
    } else {
      document.getElementById('student-form-container').innerHTML = await res.text();
    }
  },

  askDelete(btn) {
    document.getElementById('del-item-name').textContent = btn.dataset.name;
    document.getElementById('del-item-type').textContent = btn.dataset.type;
    document.getElementById('del-confirm-btn').onclick   = () => this._confirmDelete(btn.dataset.id);
    SB.openModal('modal-delete');
  },

  async _confirmDelete(id) {
    const s   = this._state();
    const qs  = this._qs(s);
    const res = await fetch(`/Students/Delete?id=${id}&${qs}`, {
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

  // ── Push notification ─────────────────────────────────────────────────────
  openPush(btn) {
    document.getElementById('students-push-id').value = btn.dataset.id;
    document.getElementById('students-push-sub').textContent =
      (window.PushT?.modalSub || 'Recipient: {0}').replace('{0}', btn.dataset.name);
    document.getElementById('students-push-title-input').value = '';
    document.getElementById('students-push-body-input').value  = '';
    SB.openModal('modal-students-push');
  },

  async submitPush() {
    const id    = document.getElementById('students-push-id').value;
    const title = document.getElementById('students-push-title-input').value.trim();
    const body  = document.getElementById('students-push-body-input').value.trim();
    if (!title || !body) {
      SB.ShowMessage(window.PushT?.missing || 'Title and body required');
      return;
    }
    const sendBtn = document.getElementById('btn-send-push');
    sendBtn.disabled = true;
    try {
      const res = await fetch(`/Students/SendPush?id=${id}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: JSON.stringify({ title, body }),
      });
      if (res.ok) {
        const { delivered } = await res.json();
        SB.closeModal('modal-students-push');
        const tmpl = delivered > 0
          ? (window.PushT?.sent || 'Delivered to {0} device(s)')
          : (window.PushT?.sentNone || 'No devices');
        SB.ShowMessage(tmpl.replace('{0}', delivered));
      } else {
        let msg = window.PushT?.failed || 'Failed';
        try { const j = await res.json(); if (j?.error) msg = j.error; } catch {}
        SB.ShowMessage(msg);
      }
    } finally {
      sendBtn.disabled = false;
    }
  },

  // ── Import ────────────────────────────────────────────────────────────────
  openImport() {
    document.getElementById('students-import-file').value = '';
    SB.openModal('modal-students-import');
  },

  async submitImport() {
    const input = document.getElementById('students-import-file');
    const file  = input.files?.[0];
    if (!file) { SB.ShowMessage(SB.t.stdImportNoFile || 'Choose a file'); return; }
    const fd = new FormData();
    fd.append('file', file);
    const res = await fetch('/Students/Import', {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      body: fd
    });
    if (res.ok) {
      const { result, html } = await res.json();
      SB.closeModal('modal-students-import');
      if (html)   this._renderList(html);
      if (result) SB.ShowMessage(result);
    } else {
      const { result } = await res.json().catch(() => ({}));
      SB.ShowMessage(result || 'Import failed');
    }
  },

  // ── Leaflet map picker ────────────────────────────────────────────────────
  _map: null,
  _marker: null,
  _searchDebounce: null,

  _initMap(lat, lng) {
    if (this._map) { try { this._map.remove(); } catch {} this._map = null; this._marker = null; }
    const container = document.getElementById('sf-map');
    if (!container) return;
    if (container._leaflet_id) { try { delete container._leaflet_id; } catch {} }

    const defaultLat = lat ?? 31.9539;
    const defaultLng = lng ?? 35.9106;
    const zoom       = lat ? 15 : 12;
    this._map = L.map(container, { zoomControl: true }).setView([defaultLat, defaultLng], zoom);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                { attribution: '© OpenStreetMap', maxZoom: 19 }).addTo(this._map);
    if (lat && lng) this._marker = L.marker([lat, lng]).addTo(this._map);
    this._map.on('click', e => this._placePin(e.latlng.lat, e.latlng.lng));

    const searchEl  = document.getElementById('sf-map-search');
    const resultsEl = document.getElementById('sf-map-search-results');
    if (searchEl) {
      searchEl.oninput = () => {
        clearTimeout(this._searchDebounce);
        const q = searchEl.value.trim();
        if (!resultsEl) return;
        if (q.length < 3) { resultsEl.style.display = 'none'; return; }
        this._searchDebounce = setTimeout(async () => {
          try {
            const lang = SB.t.isRtl ? 'ar' : 'en';
            const r    = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(q)}&countrycodes=jo&limit=5&accept-language=${lang}`);
            const items = await r.json();
            if (!items.length) { resultsEl.style.display = 'none'; return; }
            resultsEl.innerHTML = items.map(it =>
              `<div class="map-search-result"
                    onmousedown="students._selectSearch(${it.lat}, ${it.lon}, '${(it.display_name || '').split(',')[0].replace(/'/g,'&apos;').replace(/"/g,'&quot;')}')">
                 ${SB.escHtml(it.display_name)}
               </div>`
            ).join('');
            resultsEl.style.display = 'block';
          } catch { resultsEl.style.display = 'none'; }
        }, 400);
      };
      searchEl.onblur = () => setTimeout(() => { if (resultsEl) resultsEl.style.display = 'none'; }, 200);
    }
  },

  _selectSearch(lat, lng, label) {
    document.getElementById('sf-map-search-results').style.display = 'none';
    document.getElementById('sf-map-search').value = label;
    if (this._map) this._map.flyTo([lat, lng], 16, { duration: 1 });
    this._placePin(lat, lng);
  },

  async _placePin(lat, lng) {
    document.getElementById('sf-lat').value = lat;
    document.getElementById('sf-lng').value = lng;
    document.getElementById('sf-area').value   = SB.t.stdMapLoading || '...';
    document.getElementById('sf-street').value = '';
    if (this._marker) this._map.removeLayer(this._marker);
    this._marker = L.marker([lat, lng]).addTo(this._map);
    try {
      const lang = SB.t.isRtl ? 'ar' : 'en';
      const r    = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=${lang}`);
      const data = await r.json();
      const addr = data.address || {};
      document.getElementById('sf-area').value   = addr.suburb || addr.neighbourhood || addr.city_district || addr.county || (SB.t.stdMapNoResult || '—');
      document.getElementById('sf-street').value = addr.road || addr.pedestrian || addr.residential || '';
    } catch { document.getElementById('sf-area').value = SB.t.stdMapNoResult || '—'; }
  },

  locateMap() {
    if (!this._map) return;
    this._map.locate({ setView: true, maxZoom: 16 });
    this._map.once('locationfound', e => this._placePin(e.latlng.lat, e.latlng.lng));
  }
};

// Reset filter inputs on every page entry (including back/forward cache restores
// and browser autofill), then refresh the list. Sidebar click = fresh navigation
// = this runs = empty name/grade filters.
function _studentsReset() {
  const nameInput  = document.getElementById('students-name-input');
  const pageHidden = document.getElementById('students-page');
  const nameHidden = document.getElementById('students-filter-name');
  if (nameInput) {
    nameInput.value = '';
    // Re-arm readonly — keeps the Chrome autofill trick working after modal opens
    // or any DOM mutation that causes Chrome to rescan forms.
    nameInput.setAttribute('readonly', '');
  }
  if (pageHidden) pageHidden.value = '1';
  if (nameHidden) nameHidden.value = '';
}

document.addEventListener('DOMContentLoaded', () => { _studentsReset(); students.load(); });
window.addEventListener('pageshow', e => { if (e.persisted) { _studentsReset(); students.load(); } });
