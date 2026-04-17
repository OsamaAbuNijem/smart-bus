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

        var busesTask = _apiClient.GetBusesAsync(1, 1);
        var tripsTask = _apiClient.GetTripsAsync(1, 1);
        var studentsTask = _apiClient.GetStudentsAsync(1, 1);
        var alertsTask = _apiClient.GetAlertsAsync(1, 1, status: 0);
        await Task.WhenAll(busesTask, tripsTask, studentsTask, alertsTask);
        var buses = busesTask.Result;
        var trips = tripsTask.Result;
        var students = studentsTask.Result;
        var alerts = alertsTask.Result;

        ViewBag.TotalBuses = buses?.TotalCount ?? 0;
        ViewBag.TotalTrips = trips?.TotalCount ?? 0;
        ViewBag.TotalStudents = students?.TotalCount ?? 0;
        ViewBag.PendingAlerts = alerts?.TotalCount ?? 0;

        return View();
    }
}
