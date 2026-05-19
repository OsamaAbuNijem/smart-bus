/**
 * TilmezBus Admin — shared API client.
 * Namespace: window.SB.api
 * @typedef {{ok: boolean, status: number, data: any}} ApiResult
 */
(function () {
  'use strict';
  const SB = (window.SB = window.SB || {});

  /** Single place to handle 401 → redirect to login. */
  function handle401(res) {
    if (res.status === 401) {
      const returnUrl = encodeURIComponent(location.pathname + location.search);
      location.href = '/Account/Login?returnUrl=' + returnUrl;
      return true;
    }
    return false;
  }

  /** @param {string} path @returns {Promise<any|null>} */
  async function get(path) {
    try {
      const res = await fetch('/api-proxy' + path, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
      if (handle401(res)) return null;
      if (!res.ok) return null;
      return await res.json();
    } catch { return null; }
  }

  /** @param {string} method @param {string} path @param {any} body @returns {Promise<ApiResult>} */
  async function send(method, path, body) {
    try {
      const res = await fetch('/api-proxy' + path, {
        method,
        headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
        body: body != null ? JSON.stringify(body) : undefined
      });
      if (handle401(res)) return { ok: false, status: 401, data: null };
      const data = await res.json().catch(() => null);
      return { ok: res.ok, status: res.status, data };
    } catch { return { ok: false, status: 0, data: null }; }
  }

  /** @param {string} path @returns {Promise<boolean>} */
  async function del(path) {
    try {
      const res = await fetch('/api-proxy' + path, {
        method: 'DELETE', headers: { 'X-Requested-With': 'XMLHttpRequest' }
      });
      if (handle401(res)) return false;
      return res.ok;
    } catch { return false; }
  }

  SB.api = {
    get,
    post:  (path, body) => send('POST',  path, body),
    put:   (path, body) => send('PUT',   path, body),
    patch: (path, body) => send('PATCH', path, body),
    delete: del
  };
})();
