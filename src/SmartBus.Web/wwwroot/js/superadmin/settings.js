/**
 * SmartBus Super-Admin — Settings page.
 * Only the change-password modal needs JS today; everything else is static.
 */
const settings = {
  openChangePassword() {
    ['cp-current', 'cp-new', 'cp-confirm'].forEach(id => {
      const el = document.getElementById(id);
      if (el) { el.value = ''; el.classList.remove('err'); }
    });
    ['err-cp-current', 'err-cp-new', 'err-cp-confirm'].forEach(id => {
      document.getElementById(id)?.classList.remove('show');
    });
    const srv = document.getElementById('cp-server-err');
    if (srv) srv.classList.add('u-hidden');
    SB.openModal('modal-change-password');
  },

  async savePassword() {
    const current = document.getElementById('cp-current')?.value ?? '';
    const newPwd  = document.getElementById('cp-new')?.value     ?? '';
    const confirm = document.getElementById('cp-confirm')?.value ?? '';

    let valid = true;
    const setErr = (errId, inputId, show) => {
      document.getElementById(errId)?.classList.toggle('show', show);
      document.getElementById(inputId)?.classList.toggle('err', show);
      if (show) valid = false;
    };
    setErr('err-cp-current', 'cp-current', !current);
    setErr('err-cp-new',     'cp-new',     newPwd.length < 8);
    setErr('err-cp-confirm', 'cp-confirm', newPwd !== confirm);
    if (!valid) return;

    const btn = document.getElementById('btn-save-password');
    if (btn) btn.disabled = true;
    const res = await SB.api.post('/auth/change-password', {
      currentPassword: current, newPassword: newPwd
    });
    if (btn) btn.disabled = false;

    const srv = document.getElementById('cp-server-err');
    if (res?.ok) {
      if (srv) srv.classList.add('u-hidden');
      SB.closeModal('modal-change-password');
      SB.ShowMessage(SB.t.saChangePwdSuccess || 'Password updated ✓');
    } else {
      const msg = res?.data?.error || SB.t.saChangePwdFailed || 'Failed to change password.';
      if (srv) { srv.textContent = msg; srv.classList.remove('u-hidden'); }
    }
  }
};
