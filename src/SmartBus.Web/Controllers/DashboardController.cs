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
    public async Task<IActionResult> Map()
        => PartialView("_MapBuses", await ApiClient.GetBusesAsync(1, 20));

    [HttpGet]
    public async Task<IActionResult> TodayTrips()
        => PartialView("_TodayTrips", await ApiClient.GetTripsAsync(1, 8));

    [HttpGet]
    public async Task<IActionResult> RecentAlerts()
        => PartialView("_RecentAlerts", await ApiClient.GetAlertsAsync(1, 3, 0));
}
