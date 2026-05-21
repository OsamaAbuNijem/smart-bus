using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Features.Dashboard.Queries.GetAdminDashboardStats;
using TilmezBus.Application.Features.Dashboard.Queries.GetLiveDashboardStats;
using TilmezBus.Web.Models;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.Admin;

public class DashboardController : AdminControllerBase
{
    public DashboardController(IApiClient apiClient) : base(apiClient) { }

    public async Task<IActionResult> Index()
    {
        // Single aggregate roundtrip for the headline KPIs + today buckets.
        // The "Latest Alerts" section at the bottom is hydrated separately
        // by the dashboard JS via /Dashboard/RecentAlerts.
        var stats = await ApiClient.GetAdminDashboardStatsAsync();

        var vm = await PopulateAsync(new DashboardPageViewModel
        {
            TotalStudents   = stats?.TotalStudents   ?? 0,
            TotalBuses      = stats?.TotalBuses      ?? 0,
            TotalDrivers    = stats?.TotalDrivers    ?? 0,
            TotalAssistants = stats?.TotalAssistants ?? 0,
            TotalTrips      = stats?.TotalTrips      ?? 0,
            Today   = ToBreakdown(stats?.Today),
            Morning = ToBreakdown(stats?.Morning),
            Return  = ToBreakdown(stats?.Return),
        }, "dashboard", "لوحة المراقبة");
        return View(vm);
    }

    private static DashboardTripsBreakdown ToBreakdown(TripsBreakdownDto? src) =>
        src is null
            ? new DashboardTripsBreakdown()
            : new DashboardTripsBreakdown { Trips = src.Trips, Students = src.Students, Absent = src.Absent };

    /// <summary>
    /// JSON snapshot of the headline KPIs + today buckets. The hero
    /// "Refresh" button uses this to update the top stat cards and the
    /// Today section without a full page reload (the auto-poller only
    /// covers Alerts + Live, so without this the KPIs stay stale).
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Stats()
    {
        var stats = await ApiClient.GetAdminDashboardStatsAsync();
        return Json(new
        {
            totals = new
            {
                students   = stats?.TotalStudents   ?? 0,
                buses      = stats?.TotalBuses      ?? 0,
                drivers    = stats?.TotalDrivers    ?? 0,
                assistants = stats?.TotalAssistants ?? 0,
                trips      = stats?.TotalTrips      ?? 0,
            },
            today   = ToBucket(stats?.Today),
            morning = ToBucket(stats?.Morning),
            @return = ToBucket(stats?.Return),
        });

        static object ToBucket(TripsBreakdownDto? b) => b is null
            ? new { trips = 0, students = 0, absent = 0 }
            : new { trips = b.Trips, students = b.Students, absent = b.Absent };
    }

    /// <summary>
    /// JSON feed for the dashboard "Live" section. The page polls this
    /// every 15s while visible; per-trip countdowns tick locally in JS
    /// from each entry's ExpectedEndUtc.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Live()
    {
        var dto = await ApiClient.GetLiveDashboardStatsAsync();
        return Json(dto ?? new LiveDashboardStatsDto(
            Overall:      new LiveBreakdownDto(0, 0),
            Morning:      new LiveBreakdownDto(0, 0),
            Return:       new LiveBreakdownDto(0, 0),
            ServerNowUtc: DateTime.UtcNow,
            Trips:        Array.Empty<LiveTripDto>()));
    }

}
