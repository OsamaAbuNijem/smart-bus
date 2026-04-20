using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using SmartBus.Web.Models;
using SmartBus.Web.Resources;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

public class DriversController : AdminControllerBase
{
    private readonly IStringLocalizer<SharedResources> _l;

    public DriversController(IApiClient apiClient, IStringLocalizer<SharedResources> l)
        : base(apiClient) { _l = l; }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "drivers", _l["Driver_PageTitle"]));

    [HttpGet]
    public async Task<IActionResult> List(int page = 1, string? driverType = null)
        => PartialView("_List", await ApiClient.GetDriversAsync(page, 10, driverType));

    [HttpGet]
    public async Task<IActionResult> Form(Guid? id = null)
    {
        DriverInput? model = null;
        if (id.HasValue)
        {
            var d = await ApiClient.GetDriverByIdAsync(id.Value);
            if (d is null) return NotFound();
            model = new DriverInput
            {
                FullName      = d.FullName,
                FullNameEn    = d.FullNameEn,
                PhoneNumber   = d.PhoneNumber,
                LicenseNumber = d.LicenseNumber,
                IsActive      = d.IsActive,
                DriverType    = d.DriverType.ToString()
            };
            ViewBag.DriverId = d.Id;
        }
        return PartialView("_Form", model);
    }

    // Create: jumps the user back to page 1 so the new row is visible.
    [HttpPost]
    public async Task<IActionResult> Save(DriverInput input)
    {
        if (!ModelState.IsValid) { Response.StatusCode = 400; return PartialView("_Form", input); }
        var (ok, err) = await ApiClient.CreateDriverAsync(input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_DriverSaved"], page: 1);
    }

    // [FromQuery] forces these params to bind from the URL query string. Without
    // it, the default value provider pulls `driverType` from the posted form
    // (which carries DriverType=Driver/Assistant), so the list refresh after
    // save would accidentally filter by the edited driver's type.
    [HttpPost]
    public async Task<IActionResult> Update(
        Guid id,
        DriverInput input,
        [FromQuery] int page = 1,
        [FromQuery] string? driverType = null)
    {
        if (!ModelState.IsValid) { Response.StatusCode = 400; ViewBag.DriverId = id; return PartialView("_Form", input); }
        var (ok, err) = await ApiClient.UpdateDriverAsync(id, input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_DriverSaved"], page, driverType);
    }

    [HttpPost]
    public async Task<IActionResult> Delete(
        [FromQuery] Guid id,
        [FromQuery] int page = 1,
        [FromQuery] string? driverType = null)
    {
        if (!await ApiClient.DeleteDriverAsync(id)) return StatusCode(502);
        return await SuccessWithList(_l["JS_DeletedSuccess"], page, driverType);
    }

    // Builds a single response that carries both the toast text and the refreshed list HTML.
    // JS drops `html` into the tbody and shows `result` as a toast — one round-trip instead of two.
    private async Task<IActionResult> SuccessWithList(string message, int page, string? driverType = null)
    {
        var data = await ApiClient.GetDriversAsync(page, 10, driverType);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
