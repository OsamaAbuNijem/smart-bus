using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using TilmezBus.Web.Models;
using TilmezBus.Web.Resources;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.Admin;

public class TripsController : AdminControllerBase
{
    private readonly IStringLocalizer<SharedResources> _l;

    public TripsController(IApiClient apiClient, IStringLocalizer<SharedResources> l)
        : base(apiClient) { _l = l; }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "trips", _l["Nav_Trips"]));

    [HttpGet]
    public async Task<IActionResult> List(int page = 1, string? personName = null, string? date = null, string? status = null, string? busPlateNumber = null)
    {
        DateOnly? parsedDate = DateOnly.TryParse(date, out var d) ? d : null;
        return PartialView("_List", await ApiClient.GetTripsAsync(page, 10, personName, parsedDate, status, busPlateNumber));
    }

    [HttpGet]
    public async Task<IActionResult> Students(Guid id)
        => PartialView("_Students", await ApiClient.GetTripStudentsAsync(id));

    [HttpPost]
    public async Task<IActionResult> Start(Guid id, int page = 1)
    {
        var (ok, error) = await ApiClient.StartTripAsync(id);
        if (!ok) return StatusCode(502, new { result = error ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_TripStarted"].Value, page);
    }

    [HttpPost]
    public async Task<IActionResult> Complete(Guid id, int page = 1)
    {
        var (ok, error) = await ApiClient.CompleteTripAsync(id);
        if (!ok) return StatusCode(502, new { result = error ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_TripCompleted"].Value, page);
    }

    [HttpPost]
    public async Task<IActionResult> Delete(Guid id, int page = 1)
    {
        if (!await ApiClient.DeleteTripAsync(id)) return StatusCode(502);
        return await SuccessWithList(_l["JS_DeletedSuccess"], page);
    }

    private async Task<IActionResult> SuccessWithList(string message, int page)
    {
        var data = await ApiClient.GetTripsAsync(page, 10);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
