using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using SmartBus.Web.Models;
using SmartBus.Web.Resources;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.Admin;

public class BusesController : AdminControllerBase
{
    private readonly IStringLocalizer<SharedResources> _l;
    private readonly ILogger<BusesController> _logger;

    public BusesController(IApiClient apiClient, IStringLocalizer<SharedResources> l, ILogger<BusesController> logger)
        : base(apiClient) { _l = l; _logger = logger; }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "buses", _l["Bus_PageTitle"]));

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] int page = 1,
                                          [FromQuery] string? plateNumber = null,
                                          [FromQuery] string? personName = null)
        => PartialView("_List", await ApiClient.GetBusesAsync(page, 10, plateNumber, personName));

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
                PlateNumber = b.PlateNumber,
                Capacity    = b.Capacity,
                Status      = b.Status
            };
        }
        return PartialView("_Form", vm);
    }

    [HttpPost]
    public async Task<IActionResult> Save(BusInput input,
                                          [FromQuery] string? plateNumber = null,
                                          [FromQuery] string? personName = null)
    {
        if (!ModelState.IsValid) return await FormWithErrors(null, input);
        var (ok, err) = await ApiClient.CreateBusAsync(input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_BusSaved"], 1, plateNumber, personName);
    }

    [HttpPost]
    public async Task<IActionResult> Update(Guid id, BusInput input,
                                            [FromQuery] int page = 1,
                                            [FromQuery] string? plateNumber = null,
                                            [FromQuery] string? personName = null)
    {
        if (!ModelState.IsValid) return await FormWithErrors(id, input);
        var (ok, err) = await ApiClient.UpdateBusAsync(id, input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_BusSaved"], page, plateNumber, personName);
    }

    [HttpPost]
    public async Task<IActionResult> Delete(Guid id,
                                            [FromQuery] int page = 1,
                                            [FromQuery] string? plateNumber = null,
                                            [FromQuery] string? personName = null)
    {
        if (!await ApiClient.DeleteBusAsync(id)) return StatusCode(502);
        return await SuccessWithList(_l["JS_DeletedSuccess"], page, plateNumber, personName);
    }

    [HttpGet]
    public async Task<IActionResult> Schedule(Guid id)
    {
        var bus = await ApiClient.GetBusByIdAsync(id);
        if (bus is null) return NotFound();

        var schedule = await ApiClient.GetBusScheduleAsync(id);
        var drivers  = await ApiClient.GetDriversAsync(1, 200);
        var students = await ApiClient.GetStudentsAsync(1, 500);
        var allDrivers = drivers?.Items?.ToList() ?? new();

        var selectedIds = schedule?.StudentIds?.ToHashSet() ?? new HashSet<Guid>();
        var vm = new BusScheduleViewModel
        {
            BusId          = id,
            BusPlateNumber = bus.PlateNumber,
            Input = new BusScheduleInput
            {
                MorningTime        = schedule?.MorningTime ?? "07:00",
                ReturnTime         = schedule?.ReturnTime  ?? "14:00",
                RepeatDays         = schedule?.RepeatDays  ?? 0,
                MorningDriverId    = schedule?.MorningDriverId,
                MorningAssistantId = schedule?.MorningAssistantId,
                ReturnDriverId     = schedule?.ReturnDriverId,
                ReturnAssistantId  = schedule?.ReturnAssistantId,
                StudentIds         = selectedIds.ToList()
            },
            Drivers    = allDrivers.Where(d => d.DriverType != SmartBus.Domain.Enums.DriverType.Assistant).ToList(),
            Assistants = allDrivers.Where(d => d.DriverType == SmartBus.Domain.Enums.DriverType.Assistant).ToList(),
            Students   = students?.Items?.ToList() ?? new(),
            SelectedStudentIds = selectedIds
        };
        return PartialView("_Schedule", vm);
    }

    [HttpPost]
    public async Task<IActionResult> SaveSchedule(Guid id, BusScheduleInput input,
                                                  [FromQuery] int page = 1,
                                                  [FromQuery] string? plateNumber = null,
                                                  [FromQuery] string? personName = null)
    {
        if (!ModelState.IsValid) return await ScheduleWithErrors(id, input);
        var (ok, err) = await ApiClient.SetBusScheduleAsync(id, input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["BusSchedule_Saved"], page, plateNumber, personName);
    }

    private async Task<IActionResult> ScheduleWithErrors(Guid id, BusScheduleInput input)
    {
        var bus = await ApiClient.GetBusByIdAsync(id);
        var drivers  = await ApiClient.GetDriversAsync(1, 200);
        var students = await ApiClient.GetStudentsAsync(1, 500);
        var allDrivers = drivers?.Items?.ToList() ?? new();
        var selectedIds = input.StudentIds.ToHashSet();
        var vm = new BusScheduleViewModel
        {
            BusId          = id,
            BusPlateNumber = bus?.PlateNumber ?? string.Empty,
            Input          = input,
            Drivers    = allDrivers.Where(d => d.DriverType != SmartBus.Domain.Enums.DriverType.Assistant).ToList(),
            Assistants = allDrivers.Where(d => d.DriverType == SmartBus.Domain.Enums.DriverType.Assistant).ToList(),
            Students   = students?.Items?.ToList() ?? new(),
            SelectedStudentIds = selectedIds
        };
        Response.StatusCode = 400;
        return PartialView("_Schedule", vm);
    }

    private Task<IActionResult> FormWithErrors(Guid? id, BusInput input)
    {
        foreach (var kvp in ModelState)
            foreach (var err in kvp.Value!.Errors)
                _logger.LogWarning("Bus form ModelState: {Field} = {Error}", kvp.Key, err.ErrorMessage);

        var vm = new BusFormViewModel { BusId = id, Input = input };
        Response.StatusCode = 400;
        return Task.FromResult<IActionResult>(PartialView("_Form", vm));
    }

    private async Task<IActionResult> SuccessWithList(string message, int page, string? plateNumber = null, string? personName = null)
    {
        var data = await ApiClient.GetBusesAsync(page, 10, plateNumber, personName);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
