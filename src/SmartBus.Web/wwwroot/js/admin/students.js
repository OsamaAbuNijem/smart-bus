/**
 * SmartBus Admin — Students page.
 * Same pattern as drivers.js: server renders everything, JS is pure AJAX glue.
 * The Leaflet map picker is wired up after the form partial is injected.
 */

const students = {

  async load() {
    const page = document.getElementById('students-page').value;
    const res  = await fetch(`/Students/List?page=${page}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
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
    document.getElementById('students-total').textContent = totalCount;
    document.getElementById('students-prev').disabled = page <= 1;
    document.getElementById('students-next').disabled = page >= totalPages;
  },

  goto(p) { document.getElementById('students-page').value = p; this.load(); },
  prev()  { this.goto(parseInt(document.getElementById('students-page').value) - 1); },
  next()  { this.goto(parseInt(document.getElementById('students-page').value) + 1); },

  async openForm(id) {
    const url = id ? `/Students/Form?id=${id}` : '/Students/Form';
    const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    document.getElementById('student-form-container').innerHTML = await res.text();
    SB.openModal('modal-student');
    // Init map after the modal animation has settled + container has final size.
    const lat = parseFloat(document.getElementById('sf-lat').value) || null;
    const lng = parseFloat(document.getElementById('sf-lng').value) || null;
    setTimeout(() => {
      this._initMap(lat, lng);
      // Leaflet measures container on init; force a re-measure once visible.
      setTimeout(() => this._map?.invalidateSize(), 150);
    }, 50);
  },

  async submit(form) {
    const id   = form.dataset.id;
    const page = document.getElementById('students-page').value;
    const url  = id ? `/Students/Update?id=${id}&page=${page}` : '/Students/Save';
    const res  = await fetch(url, {
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
    const page = document.getElementById('students-page').value;
    const res  = await fetch(`/Students/Delete?id=${id}&page=${page}`, {
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

  // ── Leaflet map picker ───────────────────────────────────────────────────
  _map: null,
  _marker: null,
  _searchDebounce: null,

  _initMap(lat, lng) {
    // Clean up previous instance, if any.
    if (this._map) { try { this._map.remove(); } catch {} this._map = null; this._marker = null; }
    const container = document.getElementById('sf-map');
    if (!container) return;
    // Leaflet stamps _leaflet_id on the div and refuses to re-init. Since the
    // modal body is replaced via innerHTML, the div itself is fresh — but be defensive.
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
            // Use onmousedown (fires before onblur, so dropdown doesn't close first)
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

document.addEventListener('DOMContentLoaded', () => students.load());
