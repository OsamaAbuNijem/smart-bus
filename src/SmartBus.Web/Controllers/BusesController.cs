using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using SmartBus.Web.Models;
using SmartBus.Web.Resources;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

public class BusesController : AdminControllerBase
{
    private readonly IStringLocalizer<SharedResources> _l;
    private readonly ILogger<BusesController> _logger;

    public BusesController(IApiClient apiClient, IStringLocalizer<SharedResources> l, ILogger<BusesController> logger)
        : base(apiClient) { _l = l; _logger = logger; }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "buses", _l["Bus_PageTitle"]));

    [HttpGet]
    public async Task<IActionResult> List(int page = 1)
        => PartialView("_List", await ApiClient.GetBusesAsync(page, 10));

    [HttpGet]
    public async Task<IActionResult> Form(Guid? id = null)
    {
        var vm = new BusFormViewModel();
        if (id.HasValue)
        {
            var b = await ApiClient.GetBusByIdAsync(id.Value);
            if (b is null) return NotFound();
            vm.BusId = b.Id;
            vm.Input = new BusInput
            {
                PlateNumber       = b.PlateNumber,
                Capacity          = b.Capacity,
                Status            = b.Status,
                DriverId          = b.DriverId,
                AssistantDriverId = b.AssistantDriverId,
                StudentIds        = b.StudentIds.ToList()
            };
            vm.SelectedStudentIds = b.StudentIds.ToHashSet();
        }
        // Load dropdown data (one-off per modal open).
        var drivers  = await ApiClient.GetDriversAsync(1, 200);
        var students = await ApiClient.GetStudentsAsync(1, 500);
        var all = drivers?.Items?.ToList() ?? new();
        vm.Drivers    = all.Where(d => d.DriverType != SmartBus.Domain.Enums.DriverType.Assistant).ToList();
        vm.Assistants = all.Where(d => d.DriverType == SmartBus.Domain.Enums.DriverType.Assistant).ToList();
        vm.Students   = students?.Items?.ToList() ?? new();

        return PartialView("_Form", vm);
    }

    [HttpPost]
    public async Task<IActionResult> Save(BusInput input)
    {
        if (!ModelState.IsValid) return await FormWithErrors(null, input);
        var (ok, err) = await ApiClient.CreateBusAsync(input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_BusSaved"], page: 1);
    }

    [HttpPost]
    public async Task<IActionResult> Update(Guid id, BusInput input, int page = 1)
    {
        if (!ModelState.IsValid) return await FormWithErrors(id, input);
        var (ok, err) = await ApiClient.UpdateBusAsync(id, input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_BusSaved"], page);
    }

    [HttpPost]
    public async Task<IActionResult> Delete(Guid id, int page = 1)
    {
        if (!await ApiClient.DeleteBusAsync(id)) return StatusCode(502);
        return await SuccessWithList(_l["JS_DeletedSuccess"], page);
    }

    private async Task<IActionResult> FormWithErrors(Guid? id, BusInput input)
    {
        foreach (var kvp in ModelState)
            foreach (var err in kvp.Value!.Errors)
                _logger.LogWarning("Bus form ModelState: {Field} = {Error}", kvp.Key, err.ErrorMessage);

        var drivers  = await ApiClient.GetDriversAsync(1, 200);
        var students = await ApiClient.GetStudentsAsync(1, 500);
        var all = drivers?.Items?.ToList() ?? new();
        var vm = new BusFormViewModel
        {
            BusId = id,
            Input = input,
            Drivers    = all.Where(d => d.DriverType != SmartBus.Domain.Enums.DriverType.Assistant).ToList(),
            Assistants = all.Where(d => d.DriverType == SmartBus.Domain.Enums.DriverType.Assistant).ToList(),
            Students   = students?.Items?.ToList() ?? new(),
            SelectedStudentIds = input.StudentIds.ToHashSet()
        };
        Response.StatusCode = 400;
        return PartialView("_Form", vm);
    }

    private async Task<IActionResult> SuccessWithList(string message, int page)
    {
        var data = await ApiClient.GetBusesAsync(page, 10);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
