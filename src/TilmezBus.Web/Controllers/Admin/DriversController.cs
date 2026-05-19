using ClosedXML.Excel;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using TilmezBus.Domain.Enums;
using TilmezBus.Web.Models;
using TilmezBus.Web.Resources;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.Admin;

/// <summary>
/// Admin Drivers + Assistants page. Add/edit uses a slim 3-field form
/// (name, phone, type) — status defaults to Active and is toggled from
/// the grid. Every grid field (name, phone, status, type) is inline-
/// editable; the action column only carries delete. Export / Import use a
/// 3-column sheet matching the form.
/// </summary>
public class DriversController : AdminControllerBase
{
    private readonly IStringLocalizer<SharedResources> _l;
    private readonly ILogger<DriversController> _logger;

    public DriversController(IApiClient apiClient, IStringLocalizer<SharedResources> l, ILogger<DriversController> logger)
        : base(apiClient) { _l = l; _logger = logger; }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "drivers", _l["Driver_PageTitle"]));

    [HttpGet]
    public async Task<IActionResult> List(int page = 1, string? driverType = null)
        => PartialView("_List", await ApiClient.GetDriversAsync(page, 10, driverType));

    [HttpGet]
    public IActionResult Form()
    {
        // Only used for "add new" — row edits happen inline in the grid.
        return PartialView("_Form", new DriverInput { DriverType = "Driver" });
    }

    [HttpPost]
    public async Task<IActionResult> Save(DriverInput input)
    {
        if (!ModelState.IsValid) { Response.StatusCode = 400; return PartialView("_Form", input); }
        var (ok, err) = await ApiClient.CreateDriverAsync(input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_DriverSaved"], page: 1);
    }

    /// <summary>Inline patch: one or more grid fields at once.</summary>
    [HttpPost]
    public async Task<IActionResult> UpdateField(
        Guid id,
        [FromForm] string? fullName    = null,
        [FromForm] string? phoneNumber = null,
        [FromForm] bool?   isActive    = null,
        [FromForm] string? driverType  = null,
        [FromQuery] int    page        = 1,
        [FromQuery] string? typeFilter = null)
    {
        var (ok, err) = await ApiClient.UpdateDriverFieldAsync(id, fullName, phoneNumber, isActive, driverType);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_DriverSaved"], page, typeFilter);
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

    // ── Export ─────────────────────────────────────────────────────────────
    [HttpGet]
    public async Task<IActionResult> Export(string? driverType = null)
    {
        var data = await ApiClient.GetDriversAsync(1, 10000, driverType);
        using var wb = new XLWorkbook();
        var ws = wb.AddWorksheet("Drivers");

        string[] headers = { "FullName", "PhoneNumber", "DriverType" };
        for (int i = 0; i < headers.Length; i++) ws.Cell(1, i + 1).Value = headers[i];
        ws.Row(1).Style.Font.Bold = true;

        var row = 2;
        foreach (var d in data?.Items ?? Array.Empty<Application.Features.Drivers.Queries.GetAllDrivers.DriverDto>())
        {
            ws.Cell(row, 1).Value = d.FullName;
            ws.Cell(row, 2).Value = d.PhoneNumber;
            ws.Cell(row, 3).Value = TypeLabel(d.DriverType);
            row++;
        }
        ws.Columns().AdjustToContents();

        using var ms = new MemoryStream();
        wb.SaveAs(ms);
        return File(ms.ToArray(),
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            $"drivers-{DateTime.UtcNow:yyyyMMdd-HHmm}.xlsx");
    }

    // ── Template ───────────────────────────────────────────────────────────
    [HttpGet]
    public IActionResult Template()
    {
        using var wb = new XLWorkbook();
        var ws = wb.AddWorksheet("Drivers");

        string[] headers = { "FullName", "PhoneNumber", "DriverType" };
        for (int i = 0; i < headers.Length; i++) ws.Cell(1, i + 1).Value = headers[i];
        ws.Row(1).Style.Font.Bold = true;
        ws.Row(1).Style.Fill.BackgroundColor = XLColor.FromHtml("#FFFDE7");

        ws.Cell(2, 1).Value = "محمد أحمد";
        ws.Cell(2, 2).Value = "0791234567";
        ws.Cell(2, 3).Value = "Driver";
        ws.Row(2).Style.Font.Italic = true;
        ws.Row(2).Style.Font.FontColor = XLColor.FromHtml("#94A3B8");
        ws.Columns().AdjustToContents();

        using var ms = new MemoryStream();
        wb.SaveAs(ms);
        return File(ms.ToArray(),
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "drivers-template.xlsx");
    }

    // ── Import ─────────────────────────────────────────────────────────────
    [HttpPost]
    [RequestSizeLimit(5 * 1024 * 1024)]
    public async Task<IActionResult> Import(IFormFile? file)
    {
        if (file is null || file.Length == 0)
            return StatusCode(400, new { result = _l["Driver_ImportNoFile"].Value });

        int imported = 0, failed = 0;
        try
        {
            using var stream = file.OpenReadStream();
            using var wb     = new XLWorkbook(stream);
            var sheet        = wb.Worksheet(1);
            var headerRow    = sheet.FirstRowUsed();
            if (headerRow is null) return StatusCode(400, new { result = "Empty sheet" });

            var cols = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            foreach (var c in headerRow.CellsUsed())
                cols[c.GetString().Trim()] = c.Address.ColumnNumber;

            int Col(string n) => cols.TryGetValue(n, out var x) ? x : -1;
            int cFull  = Col("FullName");
            int cPhone = Col("PhoneNumber");
            int cType  = Col("DriverType");

            if (cFull < 0 || cPhone < 0 || cType < 0)
                return StatusCode(400, new { result = _l["Driver_ImportHint"].Value });

            foreach (var row in sheet.RowsUsed().Skip(1))
            {
                string Get(int col) => col > 0 ? row.Cell(col).GetString().Trim() : string.Empty;

                // DriverType accepted as enum name or localized label.
                var rawType = Get(cType);
                var driverType = rawType.Equals("Assistant", StringComparison.OrdinalIgnoreCase)
                              || rawType == _l["Driver_TypeAssist"].Value
                    ? "Assistant" : "Driver";

                var input = new DriverInput
                {
                    FullName    = Get(cFull),
                    PhoneNumber = Get(cPhone),
                    DriverType  = driverType
                };
                if (string.IsNullOrEmpty(input.FullName) || string.IsNullOrEmpty(input.PhoneNumber))
                { failed++; continue; }

                var (ok, _) = await ApiClient.CreateDriverAsync(input);
                if (ok) imported++; else failed++;
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Driver import failed");
            return StatusCode(400, new { result = ex.Message });
        }

        var message = string.Format(_l["Driver_ImportResult"].Value, imported, failed);
        return await SuccessWithList(message, page: 1);
    }

    private string TypeLabel(DriverType t)
        => t == DriverType.Assistant ? _l["Driver_TypeAssist"].Value : _l["Driver_TypeDriver"].Value;

    private async Task<IActionResult> SuccessWithList(string message, int page, string? driverType = null)
    {
        var data = await ApiClient.GetDriversAsync(page, 10, driverType);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
