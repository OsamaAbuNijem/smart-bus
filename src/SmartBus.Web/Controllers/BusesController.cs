using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

public class BusesController : Controller
{
    private readonly IApiClient _apiClient;

    public BusesController(IApiClient apiClient)
        => _apiClient = apiClient;

    public async Task<IActionResult> Index([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10)
    {
        if (string.IsNullOrEmpty(HttpContext.Session.GetString("JwtToken")))
            return RedirectToAction("Login", "Account");

        var result = await _apiClient.GetBusesAsync(pageNumber, pageSize);
        return View(result);
    }

    public async Task<IActionResult> Details(Guid id)
    {
        if (string.IsNullOrEmpty(HttpContext.Session.GetString("JwtToken")))
            return RedirectToAction("Login", "Account");

        var bus = await _apiClient.GetBusByIdAsync(id);
        return bus is null ? NotFound() : View(bus);
    }
}
