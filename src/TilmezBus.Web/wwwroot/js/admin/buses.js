/**
 * TilmezBus Admin — Buses page.
 *
 * Grid is fully server-rendered. The only "add" path is the bulk-add modal
 * (server picks BUS-#### serials). The grid supports inline rename of the
 * bus number, inline status toggle, QR print, and delete. There is no
 * single-bus form and no trip-schedule entry-point here.
 */
const buses = {
  _searchTimer: null,

  _qs() {
    const page   = document.getElementById('buses-page').value || 1;
    const plate  = document.getElementById('buses-plate').value || '';
    const params = new URLSearchParams({ page });
    if (plate)  params.set('plateFilter', plate);
    return params.toString();
  },

  async load() {
    const page  = document.getElementById('buses-page').value || 1;
    const plate = document.getElementById('buses-plate').value || '';
    const params = new URLSearchParams({ page });
    if (plate)  params.set('plateNumber', plate);
    const res = await fetch(`/Buses/List?${params}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    if (res.status === 401) { location.href = '/Account/Login'; return; }
    this._renderList(await res.text());
    this._renderInlineQrs();
  },

  _renderList(html) {
    document.getElementById('buses-tbody').innerHTML = html;
    this._updatePager();
    this._renderInlineQrs();
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

  // ── Bulk-add modal ──────────────────────────────────────────────────────
  openBatchForm() {
    const input = document.getElementById('bus-batch-count');
    if (input) input.value = '1';
    SB.openModal('modal-bus-batch');
    setTimeout(() => input && input.focus(), 50);
  },

  async submitBatch() {
    const count = parseInt(document.getElementById('bus-batch-count')?.value, 10);
    if (!Number.isFinite(count) || count < 1) {
      SB.ShowMessage(window.SB?.t?.busBatchInvalid || 'Enter a valid count.');
      return;
    }
    const btn = document.getElementById('bus-batch-save');
    if (btn) btn.disabled = true;
    try {
      const fd = new FormData();
      fd.append('count', String(count));
      const res = await fetch(`/Buses/CreateBatch?${this._qs()}`, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        body: fd
      });
      if (res.ok) {
        const { result, html, page: newPage } = await res.json();
        SB.closeModal('modal-bus-batch');
        if (newPage) document.getElementById('buses-page').value = newPage;
        if (html)    this._renderList(html);
        if (result)  SB.ShowMessage(result);
      } else {
        const { result } = await res.json().catch(() => ({}));
        SB.ShowMessage(result || 'Failed to create buses.');
      }
    } finally {
      if (btn) btn.disabled = false;
    }
  },

  // ── Inline rename ───────────────────────────────────────────────────────
  // The grid renders the bus number inside an <input> already; we just
  // commit on blur / Enter. Cancels on Escape.
  async commitNumber(input) {
    const id       = input.dataset.id;
    const original = input.dataset.original || '';
    const value    = (input.value || '').trim();
    if (!id || value === original) { input.value = original; return; }
    if (!value) { input.value = original; return; }
    await this._patch(id, { plateNumber: value });
  },

  onNumberKey(e) {
    if (e.key === 'Enter')  { e.preventDefault(); e.target.blur(); }
    if (e.key === 'Escape') { e.target.value = e.target.dataset.original || ''; e.target.blur(); }
  },

  // ── Inline status toggle ────────────────────────────────────────────────
  async toggleStatus(btn) {
    const id   = btn.dataset.id;
    const next = btn.dataset.status === 'Active' ? 'Inactive' : 'Active';
    await this._patch(id, { status: next });
  },

  async _patch(id, body) {
    const fd = new FormData();
    Object.entries(body).forEach(([k, v]) => fd.append(k, v));
    const res = await fetch(`/Buses/UpdateField?id=${id}&${this._qs()}`, {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
      body: fd
    });
    if (res.ok) {
      const { result, html } = await res.json();
      if (html)   this._renderList(html);
      if (result) SB.ShowMessage(result);
    } else {
      const { result } = await res.json().catch(() => ({}));
      SB.ShowMessage(result || 'Update failed.');
      this.load();
    }
  },

  // ── Inline QR thumbnails ────────────────────────────────────────────────
  // The grid renders <img src="/Buses/Qr?token=..."> directly — no client-
  // side generation. Kept as a no-op stub so the existing call sites
  // (load(), _renderList()) don't need conditional checks.
  _renderInlineQrs() { /* server-rendered PNGs, nothing to do here */ },

  // ── QR modal ────────────────────────────────────────────────────────────
  openQr(btn) {
    const token = btn?.dataset?.qr;
    const plate = btn?.dataset?.plate || '';
    if (!token) { SB.ShowMessage('QR token missing'); return; }

    const plateEl = document.getElementById('bus-qr-plate');
    if (plateEl) plateEl.textContent = plate;
    const tokenEl = document.getElementById('bus-qr-token');
    if (tokenEl) tokenEl.textContent = token;

    // High-res poster from the same server endpoint (size=10 ≈ 290px).
    const qrUrl = `/Buses/Qr?token=${encodeURIComponent(token)}&size=10`;
    const canvas = document.getElementById('bus-qr-canvas');
    if (canvas) canvas.innerHTML = `<img src="${qrUrl}" alt="QR" width="240" height="240"/>`;

    const printBtn = document.getElementById('bus-qr-print');
    if (printBtn) printBtn.onclick = () => this._printQr(plate, token, qrUrl);

    SB.openModal('modal-bus-qr');
  },

  _printQr(plate, token, qrUrl) {
    const w = window.open('', '_blank', 'width=480,height=640');
    if (!w) return;
    w.document.write(`
      <!DOCTYPE html><html dir="${document.documentElement.dir || 'rtl'}"><head><meta charset="UTF-8">
      <title>QR — ${plate}</title>
      <style>
        body { font-family:'Cairo',sans-serif; text-align:center; padding:40px; }
        h1 { font-size:22px; margin-bottom:8px; }
        .plate { font-size:32px; font-weight:800; margin:12px 0 24px; letter-spacing:1px; }
        img { width:280px; height:280px; }
      </style></head><body>
      <h1>Tilmez Bus</h1>
      <div class="plate">${plate}</div>
      <img src="${qrUrl}" alt="QR" onload="setTimeout(()=>window.print(),250)"/>
      </body></html>`);
    w.document.close();
  },

  // ── Delete ──────────────────────────────────────────────────────────────
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
// If the QRCode CDN script finishes after the first list paint, paint the
// QR thumbnails as soon as it's ready (avoids empty cells on a slow CDN).
window.addEventListener('load', () => buses._renderInlineQrs());
