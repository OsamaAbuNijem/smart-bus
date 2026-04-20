/**
 * SmartBus Admin — Dashboard page.
 * Fetches three server-rendered widget partials in parallel.
 */

const dashboard = {
  async load() {
    const [map, tripsHtml, alertsHtml] = await Promise.all([
      this._fetch('/Dashboard/Map'),
      this._fetch('/Dashboard/TodayTrips'),
      this._fetch('/Dashboard/RecentAlerts')
    ]);
    document.getElementById('dashboard-map').innerHTML      = map;
    document.getElementById('today-trips-list').innerHTML   = tripsHtml;
    document.getElementById('dashboard-alerts').innerHTML   = alertsHtml;

    // Small metadata the partials embed in hidden spans
    const mapCount    = document.getElementById('dashboard-map-count')?.textContent    || '0';
    const tripsTotal  = document.getElementById('dashboard-trips-total')?.textContent  || '0';
    const alertsTotal = document.getElementById('dashboard-alerts-total')?.textContent || '0';
    const activeSub   = document.getElementById('active-buses-sub');
    const tripsSub    = document.getElementById('today-trips-sub');
    if (activeSub) activeSub.textContent = `${mapCount} باص في الأسطول`;
    if (tripsSub)  tripsSub.textContent  = `${tripsTotal} رحلة`;
    const tripsBadge  = document.getElementById('trips-badge');
    const alertsBadge = document.getElementById('alerts-badge');
    if (tripsBadge)  tripsBadge.textContent  = tripsTotal;
    if (alertsBadge) alertsBadge.textContent = alertsTotal;
  },

  async _fetch(url) {
    const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
    if (res.status === 401) { location.href = '/Account/Login'; return ''; }
    return res.text();
  }
};

document.addEventListener('DOMContentLoaded', () => dashboard.load());
