using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using SmartBus.Web.Models;
using SmartBus.Web.Resources;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

public class TripsController : AdminControllerBase
{
    private readonly IStringLocalizer<SharedResources> _l;

    public TripsController(IApiClient apiClient, IStringLocalizer<SharedResources> l)
        : base(apiClient) { _l = l; }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "trips", _l["Nav_Trips"]));

    [HttpGet]
    public async Task<IActionResult> List(int page = 1, string? personName = null, string? date = null, string? status = null)
    {
        DateOnly? parsedDate = DateOnly.TryParse(date, out var d) ? d : null;
        return PartialView("_List", await ApiClient.GetTripsAsync(page, 10, personName, parsedDate, status));
    }

    [HttpGet]
    public async Task<IActionResult> Students(Guid id)
        => PartialView("_Students", await ApiClient.GetTripStudentsAsync(id));

    [HttpPost]
    public async Task<IActionResult> Start(Guid id, int page = 1)
    {
        if (!await ApiClient.StartTripAsync(id)) return StatusCode(502);
        return await SuccessWithList(_l["JS_TripStarted"].Value, page);
    }

    [HttpPost]
    public async Task<IActionResult> Complete(Guid id, int page = 1)
    {
        if (!await ApiClient.CompleteTripAsync(id)) return StatusCode(502);
        return await SuccessWithList(_l["JS_TripCompleted"].Value, page);
    }

    [HttpPost]
    public async Task<IActionResult> Delete(Guid id, int page = 1)
    {
        if (!await ApiClient.DeleteTripAsync(id)) return StatusCode(502);
        return await SuccessWithList(_l["JS_DeletedSuccess"], page);
    }

    [HttpPost]
    public async Task<IActionResult> GenerateToday(int page = 1)
    {
        var (ok, message) = await ApiClient.GenerateTodayTripsAsync();
        if (!ok) return StatusCode(502, new { result = message ?? "Upstream API error" });
        return await SuccessWithList(message ?? _l["JS_TripsGenerated"].Value, page);
    }

    private async Task<IActionResult> SuccessWithList(string message, int page)
    {
        var data = await ApiClient.GetTripsAsync(page, 10);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
