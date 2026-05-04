/**
 * SmartBus Admin — Dashboard page.
 * Renders Chart.js charts from /Dashboard/Stats plus two server-rendered widgets.
 */

const dashboard = {
  _charts: {},

  init() {
    const btn = document.getElementById('dash-refresh');
    if (btn) btn.addEventListener('click', () => this.load(btn));
    this.load();
  },

  async load(refreshBtn) {
    if (refreshBtn) refreshBtn.classList.add('spin');
    try {
      const [stats, tripsHtml, alertsHtml] = await Promise.all([
        this._fetchJson('/Dashboard/Stats'),
        this._fetchHtml('/Dashboard/TodayTrips'),
        this._fetchHtml('/Dashboard/RecentAlerts')
      ]);

      document.getElementById('today-trips-list').innerHTML = tripsHtml;
      document.getElementById('dashboard-alerts').innerHTML = alertsHtml;

      const tripsTotal  = document.getElementById('dashboard-trips-total')?.textContent  || '0';
      const tripsSub    = document.getElementById('today-trips-sub');
      if (tripsSub) tripsSub.textContent = `${tripsTotal} ${SB.t.dashTripsCount || 'رحلة'}`;

      if (stats) this._renderCharts(stats);
    } finally {
      if (refreshBtn) setTimeout(() => refreshBtn.classList.remove('spin'), 300);
    }
  },

  _renderCharts(stats) {
    const statusData = stats.todayByStatus || {};
    const typeData   = stats.todayByType   || {};
    const weekly     = stats.weekly        || [];

    const tToday = SB.t.dashTripsToday || 'رحلة لليوم';
    const tWeek  = SB.t.dashTripsWeek  || 'رحلة خلال 7 أيام';

    const totalToday = (statusData.Scheduled || 0) + (statusData.InProgress || 0) + (statusData.Completed || 0);
    const subStatus = document.getElementById('status-chart-sub');
    if (subStatus) subStatus.textContent = `${totalToday} ${tToday}`;

    const totalType = (typeData.Morning || 0) + (typeData.Return || 0);
    const subType = document.getElementById('type-chart-sub');
    if (subType) subType.textContent = `${totalType} ${tToday}`;

    const weeklyTotal = weekly.reduce((acc, w) => acc + (w.count || 0), 0);
    const subWeekly = document.getElementById('weekly-chart-sub');
    if (subWeekly) subWeekly.textContent = `${weeklyTotal} ${tWeek}`;

    const centerLabel = SB.t.dashTotal || 'إجمالي';

    this._drawDonut('chart-trip-status', {
      labels: [SB.t.dashStatusScheduled || 'قادمة', SB.t.dashStatusInProgress || 'جارية', SB.t.dashStatusCompleted || 'مكتملة'],
      values: [statusData.Scheduled || 0, statusData.InProgress || 0, statusData.Completed || 0],
      colors: ['#3B82F6', '#F59E0B', '#22C55E'],
      centerLabel,
      legendTarget: 'legend-status'
    });

    this._drawDonut('chart-trip-type', {
      labels: [SB.t.dashTypeMorning || 'ذهاب', SB.t.dashTypeReturn || 'إياب'],
      values: [typeData.Morning || 0, typeData.Return || 0],
      colors: ['#FFD700', '#3B82F6'],
      centerLabel,
      legendTarget: 'legend-type'
    });

    this._drawBar('chart-weekly', {
      labels: weekly.map(w => w.label),
      values: weekly.map(w => w.count || 0)
    });
  },

  _centerTextPlugin: {
    id: 'centerText',
    afterDraw(chart, args, opts) {
      const { ctx, chartArea } = chart;
      if (!chartArea) return;
      const total = (opts.total ?? 0);
      const label = opts.label || '';
      const cx = (chartArea.left + chartArea.right) / 2;
      const cy = (chartArea.top + chartArea.bottom) / 2;
      ctx.save();
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillStyle = '#111111';
      ctx.font = "800 26px Cairo, sans-serif";
      ctx.fillText(String(total), cx, cy - 6);
      ctx.fillStyle = '#94A3B8';
      ctx.font = "600 11px Cairo, sans-serif";
      ctx.fillText(label, cx, cy + 16);
      ctx.restore();
    }
  },

  _renderLegend(targetId, labels, values, colors) {
    const el = document.getElementById(targetId);
    if (!el) return;
    el.innerHTML = labels.map((lbl, i) => `
      <span class="legend-pill">
        <span class="legend-pill-dot" style="background:${colors[i]}"></span>
        <span>${lbl}</span>
        <span class="legend-pill-count">${values[i]}</span>
      </span>
    `).join('');
  },

  _drawDonut(canvasId, { labels, values, colors, centerLabel, legendTarget }) {
    const el = document.getElementById(canvasId);
    if (!el || typeof Chart === 'undefined') return;
    if (this._charts[canvasId]) this._charts[canvasId].destroy();

    const total = values.reduce((a, b) => a + b, 0);
    if (legendTarget) this._renderLegend(legendTarget, labels, values, colors);

    this._charts[canvasId] = new Chart(el, {
      type: 'doughnut',
      data: {
        labels,
        datasets: [{
          data: values,
          backgroundColor: colors,
          borderColor: '#FFFFFF',
          borderWidth: 3,
          hoverOffset: 8,
          spacing: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '72%',
        animation: { animateRotate: true, animateScale: false, duration: 700, easing: 'easeOutQuart' },
        plugins: {
          legend: { display: false },
          tooltip: {
            rtl: true,
            backgroundColor: 'rgba(17,17,17,.92)',
            padding: 10,
            cornerRadius: 8,
            bodyFont: { family: 'Cairo', size: 12 },
            titleFont: { family: 'Cairo', size: 12, weight: '700' },
            displayColors: false,
            callbacks: {
              label: ctx => {
                const v = ctx.parsed;
                const pct = total > 0 ? Math.round((v / total) * 100) : 0;
                return ` ${ctx.label}: ${v} (${pct}%)`;
              }
            }
          },
          centerText: { total, label: centerLabel || '' }
        }
      },
      plugins: [this._centerTextPlugin]
    });
  },

  _drawBar(canvasId, { labels, values }) {
    const el = document.getElementById(canvasId);
    if (!el || typeof Chart === 'undefined') return;
    if (this._charts[canvasId]) this._charts[canvasId].destroy();

    const ctx = el.getContext('2d');
    const gradient = ctx.createLinearGradient(0, 0, 0, el.height || 280);
    gradient.addColorStop(0, '#3B82F6');
    gradient.addColorStop(1, '#93C5FD');

    this._charts[canvasId] = new Chart(el, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          label: SB.t.dashChartLabelTrips || 'رحلات',
          data: values,
          backgroundColor: gradient,
          hoverBackgroundColor: '#1E40AF',
          borderRadius: 10,
          borderSkipped: false,
          maxBarThickness: 40
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: { duration: 650, easing: 'easeOutQuart' },
        plugins: {
          legend: { display: false },
          tooltip: {
            rtl: true,
            backgroundColor: 'rgba(17,17,17,.92)',
            padding: 10,
            cornerRadius: 8,
            bodyFont: { family: 'Cairo', size: 12 },
            titleFont: { family: 'Cairo', size: 12, weight: '700' },
            displayColors: false,
            callbacks: { label: ctx => ` ${ctx.parsed.y} ${SB.t.dashTripsCount || 'رحلة'}` }
          }
        },
        scales: {
          x: {
            grid: { display: false, drawBorder: false },
            ticks: { font: { family: 'Cairo', size: 11 }, color: '#64748B' }
          },
          y: {
            beginAtZero: true,
            border: { display: false },
            ticks: { font: { family: 'Cairo', size: 11 }, color: '#94A3B8', precision: 0, padding: 6 },
            grid: { color: 'rgba(148,163,184,.12)', drawBorder: false, tickLength: 0 }
          }
        }
      }
    });
  },

  async _fetchJson(url) {
    try {
      const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' }, cache: 'no-store' });
      if (res.status === 401) { location.href = '/Account/Login'; return null; }
      return res.ok ? await res.json() : null;
    } catch { return null; }
  },

  async _fetchHtml(url) {
    const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' }, cache: 'no-store' });
    if (res.status === 401) { location.href = '/Account/Login'; return ''; }
    return res.text();
  }
};

document.addEventListener('DOMContentLoaded', () => dashboard.init());
