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

        var buses = await _apiClient.GetBusesAsync(1, 5);
        var trips = await _apiClient.GetTripsAsync(1, 5);

        ViewBag.TotalBuses = buses?.TotalCount ?? 0;
        ViewBag.TotalTrips = trips?.TotalCount ?? 0;
        ViewBag.RecentBuses = buses?.Items ?? [];
        ViewBag.RecentTrips = trips?.Items ?? [];

        return View();
    }
}
