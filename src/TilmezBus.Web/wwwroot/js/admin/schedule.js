/**
 * TilmezBus Admin — Bus schedule modal (shared between Trips & Buses pages).
 * Namespace: window.SB.schedule
 */
(function () {
  'use strict';
  const SB = (window.SB = window.SB || {});

  let scheduleBusId = null;
  let busesCache = [];

  async function open(plateOrNull, busIdOrNull) {
    document.querySelectorAll('.sch-day').forEach(cb => { cb.checked = false; });
    [1,2,4,8,16].forEach(v => {
      const cb = document.querySelector(`.sch-day[value="${v}"]`);
      if (cb) cb.checked = true;
    });
    const morningEl = document.getElementById('sch-morning-time');
    const returnEl  = document.getElementById('sch-return-time');
    const busSel    = document.getElementById('sch-bus');
    const titleEl   = document.querySelector('#modal-trip .modal-header-title');
    if (morningEl) morningEl.value = '07:15';
    if (returnEl)  returnEl.value  = '14:00';
    if (titleEl)   titleEl.textContent = plateOrNull ? `جدول رحلات — ${plateOrNull}` : 'جدول رحلات الباص';
    scheduleBusId = busIdOrNull || null;
    if (busIdOrNull && busSel) busSel.closest('.form-row').style.display = 'none';
    else if (busSel) {
      busSel.closest('.form-row').style.display = '';
      busSel.innerHTML = '<option value="">جاري التحميل...</option>';
    }
    SB.openModal('modal-trip');
    await loadBusOptions(busIdOrNull);
    if (!busIdOrNull) return;
    const sched = await SB.api.get(`/trips/bus/${busIdOrNull}/schedule`);
    if (!sched) return;
    if (sched.morningTime && morningEl) morningEl.value = sched.morningTime;
    if (sched.returnTime  && returnEl)  returnEl.value  = sched.returnTime;
    if (sched.repeatDays) document.querySelectorAll('.sch-day').forEach(cb => { cb.checked = (sched.repeatDays & parseInt(cb.value)) !== 0; });
  }

  async function loadBusOptions(selectedId) {
    const sel = document.getElementById('sch-bus');
    if (!sel) return;
    if (!busesCache.length) {
      const data = await SB.api.get('/buses?pageNumber=1&pageSize=100');
      if (data?.items) busesCache = data.items;
    }
    sel.innerHTML = '<option value="">— اختر باصاً —</option>' +
      busesCache.map(b => `<option value="${b.id}"${b.id === selectedId ? ' selected' : ''}>${SB.escHtml(b.plateNumber)}</option>`).join('');
  }

  async function save(onSaved) {
    const busId       = document.getElementById('sch-bus').value || scheduleBusId;
    const morningTime = document.getElementById('sch-morning-time').value;
    const returnTime  = document.getElementById('sch-return-time').value;
    if (!busId)       { alert('الرجاء اختيار الباص'); return; }
    if (!morningTime) { alert('الرجاء تحديد وقت الذهاب'); return; }
    if (!returnTime)  { alert('الرجاء تحديد وقت الإياب'); return; }
    let repeatDays = 0;
    document.querySelectorAll('.sch-day:checked').forEach(cb => { repeatDays |= parseInt(cb.value); });
    if (!repeatDays) { alert('الرجاء اختيار يوم واحد على الأقل'); return; }
    const res = await SB.api.post(`/trips/bus/${busId}/schedule`, { morningTime, returnTime, repeatDays });
    if (res?.ok) {
      SB.closeModal('modal-trip');
      SB.ShowMessage('تم حفظ جدول الرحلات بنجاح ✓');
      if (typeof onSaved === 'function') onSaved();
    } else {
      alert('فشل الحفظ: ' + (res?.data?.error || res?.data?.title || 'خطأ غير معروف'));
    }
  }

  SB.schedule = { open, save };
  SB.on('schedule-open', el => open(el.getAttribute('data-plate'), el.getAttribute('data-bus-id')));
  SB.on('schedule-save', () => {
    // Each page registers its own save handler that chains refresh — fall back to plain save.
    save(() => {
      if (SB.pages.trips?.load)  SB.pages.trips.load(1);
      if (SB.pages.buses?.load)  SB.pages.buses.load(1);
    });
  });
})();
