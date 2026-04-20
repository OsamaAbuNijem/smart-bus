/**
 * SmartBus Admin — Reports page.
 * Fetches two server-rendered widget partials in parallel.
 */

const reports = {
  async load() {
    const [tripsHtml, busesHtml] = await Promise.all([
      this._fetch('/Reports/TripsPerf'),
      this._fetch('/Reports/BusesPerf')
    ]);
    document.getElementById('report-trips-perf').innerHTML = tripsHtml;
    document.getElementById('report-buses-perf').innerHTML = busesHtml;
  },

  async _fetch(url) {
    const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    if (res.status === 401) { location.href = '/Account/Login'; return ''; }
    return res.text();
  }
};

document.addEventListener('DOMContentLoaded', () => reports.load());
