/**
 * TilmezBus Super-Admin — shared utilities + global init.
 * Namespace: window.SB (extends the one /js/superadmin/api.js opens).
 *
 * Exposes:
 *   SB.escHtml, SB.setText, SB.formatDate
 *   SB.openModal, SB.closeModal, SB.ShowMessage
 *   SB.updatePager, SB.animateCounter
 *   SB.getAvatarColor, SB.highlight
 * Also wires DOMContentLoaded for the topbar date chip and modal
 * overlay click-to-close.
 */
(function () {
  'use strict';
  const SB = (window.SB = window.SB || {});

  // ── Translations loader ────────────────────────────────────────────────────
  // Mirrors admin/utils.js. /api/translations/superadmin returns a dict of
  // every JS-side string the SA modules need, in the active culture. The
  // payload is also re-exposed as window.T for legacy callers.
  SB.t = {};
  SB.tFormat = function (key, ...args) {
    let s = SB.t[key] || '';
    args.forEach((arg, i) => { s = s.replace(new RegExp('\\{' + i + '\\}', 'g'), arg); });
    return s;
  };
  async function loadTranslations() {
    try {
      const res = await fetch('/api/translations/superadmin', { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
      if (res.ok) SB.t = await res.json();
    } catch { /* fall back to bare keys */ }
    window.T = SB.t;
  }

  // ── Text + escape ──────────────────────────────────────────────────────────
  SB.escHtml = function (str) {
    if (str == null) return '';
    return String(str)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  };
  SB.setText = function (id, val) {
    const el = document.getElementById(id);
    if (el) el.textContent = val;
  };

  // ── Modals ─────────────────────────────────────────────────────────────────
  SB.openModal  = function (id) { document.getElementById(id)?.classList.add('open'); };
  SB.closeModal = function (id) { document.getElementById(id)?.classList.remove('open'); };
  // Legacy aliases: a lot of inline onclick="closeModal('modal-school')" still
  // lives in the shared layout. Keep them working without rewriting every
  // attribute.
  window.openModal  = SB.openModal;
  window.closeModal = SB.closeModal;

  // ── Toast ──────────────────────────────────────────────────────────────────
  // Also exposed as `ShowMessage(...)` for parity with the old API.
  SB.ShowMessage = function (msg, type = 'success') {
    const variant = type === 'error' ? 'error' : type === 'info' ? 'info' : 'success';
    const t = document.createElement('div');
    t.className   = `sa-toast ${variant}`;
    t.textContent = msg;
    document.body.appendChild(t);
    setTimeout(() => t.remove(), 2800);
  };
  window.ShowMessage = SB.ShowMessage;

  // ── Pager ──────────────────────────────────────────────────────────────────
  SB.updatePager = function (prefix, page, totalPages) {
    const prev = document.getElementById(`${prefix}-prev`);
    const next = document.getElementById(`${prefix}-next`);
    if (prev) prev.disabled = page <= 1;
    if (next) next.disabled = page >= totalPages;
  };

  // ── Format ─────────────────────────────────────────────────────────────────
  SB.formatDate = function (dt) {
    if (!dt) return '—';
    try {
      const d = new Date(dt);
      if (isNaN(d.getTime())) return '—';
      const y  = d.getUTCFullYear();
      const m  = String(d.getUTCMonth() + 1).padStart(2, '0');
      const dd = String(d.getUTCDate()).padStart(2, '0');
      return `${y}-${m}-${dd}`;
    } catch { return '—'; }
  };

  // ── Counter animation ──────────────────────────────────────────────────────
  SB.animateCounter = function (id, target) {
    const el = document.getElementById(id);
    if (!el) return;
    const start  = 0;
    const dur    = 600;
    const t0     = performance.now();
    function step(now) {
      const p = Math.min(1, (now - t0) / dur);
      el.textContent = Math.round(start + (target - start) * p);
      if (p < 1) requestAnimationFrame(step);
    }
    requestAnimationFrame(step);
  };

  // ── Avatar palette (deterministic by id) ───────────────────────────────────
  const palette = [
    { bg: '#EEF2FF', text: '#3730A3' },
    { bg: '#F0FDF4', text: '#15803D' },
    { bg: '#FFF7ED', text: '#C2410C' },
    { bg: '#FEF2F2', text: '#B91C1C' },
    { bg: '#F5F3FF', text: '#7C3AED' },
    { bg: '#FFFDE7', text: '#B8960C' }
  ];
  SB.getAvatarColor = function (id) {
    if (!id) return palette[0];
    let sum = 0;
    for (let i = 0; i < id.length; i++) sum += id.charCodeAt(i);
    return palette[sum % palette.length];
  };

  // ── Search highlight ───────────────────────────────────────────────────────
  SB.highlight = function (text, query) {
    if (!query) return text;
    const safe = String(query).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const re   = new RegExp(`(${safe})`, 'gi');
    return String(text).replace(re, '<mark>$1</mark>');
  };

  // ── Date chip (top-right) ──────────────────────────────────────────────────
  function setDateChip() {
    const el = document.getElementById('sa-date-chip');
    if (!el) return;
    const locale = (document.documentElement.lang || 'ar').startsWith('ar') ? 'ar-EG' : 'en-US';
    try {
      el.textContent = new Date().toLocaleDateString(locale, {
        weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
      });
    } catch {
      el.textContent = new Date().toDateString();
    }
  }

  // ── Global init — runs on every super-admin page ───────────────────────────
  // Translations load is async; expose a promise so page modules can wait
  // before rendering if they need localized strings up-front.
  SB.translationsReady = loadTranslations();
  document.addEventListener('DOMContentLoaded', () => {
    setDateChip();
    document.querySelectorAll('.modal-overlay').forEach(o => {
      o.addEventListener('click', e => { if (e.target === o) o.classList.remove('open'); });
    });
  });
})();
