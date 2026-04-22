using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Models;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

public class DashboardController : AdminControllerBase
{
    public DashboardController(IApiClient apiClient) : base(apiClient) { }

    public async Task<IActionResult> Index()
    {
        var busesTask    = ApiClient.GetBusesAsync(1, 1);
        var tripsTask    = ApiClient.GetTripsAsync(1, 1);
        var studentsTask = ApiClient.GetStudentsAsync(1, 1);
        var alertsTask   = ApiClient.GetAlertsAsync(1, 1, status: 0);
        await Task.WhenAll(busesTask, tripsTask, studentsTask, alertsTask);

        var vm = await PopulateAsync(new DashboardPageViewModel
        {
            TotalBuses    = busesTask.Result?.TotalCount ?? 0,
            TotalTrips    = tripsTask.Result?.TotalCount ?? 0,
            TotalStudents = studentsTask.Result?.TotalCount ?? 0,
            PendingAlerts = alertsTask.Result?.TotalCount ?? 0,
        }, "dashboard", "لوحة المراقبة");
        return View(vm);
    }

    [HttpGet]
    public async Task<IActionResult> TodayTrips()
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow.Date);
        return PartialView("_TodayTrips", await ApiClient.GetTripsAsync(1, 8, date: today));
    }

    [HttpGet]
    public async Task<IActionResult> RecentAlerts()
        => PartialView("_RecentAlerts", await ApiClient.GetAlertsAsync(1, 5, 0));

    /// <summary>
    /// Aggregated JSON feed for the dashboard charts:
    ///   • today's trips split by status (Scheduled / InProgress / Completed)
    ///   • today's trips split by type  (Morning / Return)
    ///   • last 7 days' trip counts (chronological)
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Stats()
    {
        var today     = DateOnly.FromDateTime(DateTime.UtcNow.Date);
        var todayPage = await ApiClient.GetTripsAsync(1, 200, date: today);

        var byStatus = new Dictionary<string, int>
        {
            ["Scheduled"]  = 0,
            ["InProgress"] = 0,
            ["Completed"]  = 0
        };
        var byType = new Dictionary<string, int> { ["Morning"] = 0, ["Return"] = 0 };

        foreach (var t in todayPage?.Items ?? Enumerable.Empty<SmartBus.Application.Features.Trips.Queries.GetAllTrips.TripDto>())
        {
            if (byStatus.ContainsKey(t.Status)) byStatus[t.Status]++;
            var type = string.Equals(t.TripType, "morning", StringComparison.OrdinalIgnoreCase) ? "Morning" : "Return";
            byType[type]++;
        }

        // Seven days ending today (chronological: oldest → newest)
        var weeklyTasks = Enumerable.Range(0, 7)
            .Select(i => today.AddDays(-6 + i))
            .Select(async d => new
            {
                date  = d,
                count = (await ApiClient.GetTripsAsync(1, 1, date: d))?.TotalCount ?? 0
            })
            .ToArray();
        var weekly = await Task.WhenAll(weeklyTasks);

        return Json(new
        {
            todayByStatus = byStatus,
            todayByType   = byType,
            weekly        = weekly.Select(w => new
            {
                label = w.date.ToString("ddd"),
                date  = w.date.ToString("yyyy-MM-dd"),
                count = w.count
            }).ToArray()
        });
    }
}
