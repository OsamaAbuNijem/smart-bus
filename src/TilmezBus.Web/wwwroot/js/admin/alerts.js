/**
 * TilmezBus Admin — Alerts page.
 * Server-rendered list, one-shot actions (Resolve/Ignore).
 */

const alerts = {

  async load() {
    const page = document.getElementById('alerts-page').value;
    const res  = await fetch(`/Alerts/List?page=${page}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    if (res.status === 401) { location.href = '/Account/Login'; return; }
    this._renderList(await res.text());
  },

  _renderList(html) {
    document.getElementById('alerts-list').innerHTML = html;
    const meta = document.querySelector('#alerts-list div.u-hidden[data-header]');
    if (!meta) return;
    document.getElementById('alerts-header-sub').textContent = meta.dataset.header;
    const page       = parseInt(document.getElementById('alerts-page').value) || 1;
    const totalPages = parseInt(meta.dataset.totalPages) || 1;
    document.getElementById('alerts-prev').disabled = page <= 1;
    document.getElementById('alerts-next').disabled = page >= totalPages;
  },

  goto(p) { document.getElementById('alerts-page').value = p; this.load(); },
  prev()  { this.goto(parseInt(document.getElementById('alerts-page').value) - 1); },
  next()  { this.goto(parseInt(document.getElementById('alerts-page').value) + 1); },

  async resolve(id) { await this._action(`/Alerts/Resolve?id=${id}`); },
  async ignore(id)  { await this._action(`/Alerts/Ignore?id=${id}`); },

  async _action(url) {
    const page = document.getElementById('alerts-page').value;
    const res  = await fetch(`${url}&page=${page}`, {
      method: 'POST',
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    });
    if (res.ok) {
      const { result, html } = await res.json();
      if (html)   this._renderList(html);
      if (result) SB.ShowMessage(result);
    }
  }
};

document.addEventListener('DOMContentLoaded', () => alerts.load());
