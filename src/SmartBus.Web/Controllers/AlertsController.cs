using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using SmartBus.Web.Models;
using SmartBus.Web.Resources;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

public class AlertsController : AdminControllerBase
{
    private readonly IStringLocalizer<SharedResources> _l;

    public AlertsController(IApiClient apiClient, IStringLocalizer<SharedResources> l)
        : base(apiClient) { _l = l; }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "alerts", _l["Alert_PageTitle"]));

    [HttpGet]
    public async Task<IActionResult> List(int page = 1)
        => PartialView("_List", await ApiClient.GetAlertsAsync(page, 10));

    [HttpPost]
    public async Task<IActionResult> Resolve(Guid id, int page = 1)
    {
        if (!await ApiClient.SetAlertStatusAsync(id, 1)) return StatusCode(502);
        return await SuccessWithList(_l["JS_AlertResolved"], page);
    }

    [HttpPost]
    public async Task<IActionResult> Ignore(Guid id, int page = 1)
    {
        if (!await ApiClient.SetAlertStatusAsync(id, 2)) return StatusCode(502);
        return await SuccessWithList(_l["JS_AlertDismissed"], page);
    }

    private async Task<IActionResult> SuccessWithList(string message, int page)
    {
        var data = await ApiClient.GetAlertsAsync(page, 10);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
