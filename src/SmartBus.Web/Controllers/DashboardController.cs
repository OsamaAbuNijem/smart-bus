using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

public class DashboardController : Controller
{
    private readonly IApiClient _apiClient;

    public DashboardController(IApiClient apiClient)
        => _apiClient = apiClient;

    public async Task<IActionResult> Index()
    {
        if (string.IsNullOrEmpty(HttpContext.Session.GetString("JwtToken")))
            return RedirectToAction("Login", "Account");

        var busesTask    = _apiClient.GetBusesAsync(1, 1);
        var tripsTask    = _apiClient.GetTripsAsync(1, 1);
        var studentsTask = _apiClient.GetStudentsAsync(1, 1);
        var alertsTask   = _apiClient.GetAlertsAsync(1, 1, status: 0);
        var schoolTask   = _apiClient.GetMySchoolAsync();
        await Task.WhenAll(busesTask, tripsTask, studentsTask, alertsTask, schoolTask);

        ViewBag.TotalBuses     = busesTask.Result?.TotalCount ?? 0;
        ViewBag.TotalTrips     = tripsTask.Result?.TotalCount ?? 0;
        ViewBag.TotalStudents  = studentsTask.Result?.TotalCount ?? 0;
        ViewBag.PendingAlerts  = alertsTask.Result?.TotalCount ?? 0;
        ViewBag.SchoolCity     = schoolTask.Result?.City ?? string.Empty;
        ViewBag.SchoolName     = schoolTask.Result?.Name ?? string.Empty;

        return View();
    }
}
