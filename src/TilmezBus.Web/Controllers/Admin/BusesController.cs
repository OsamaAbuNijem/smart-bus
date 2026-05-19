using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using QRCoder;
using TilmezBus.Web.Models;
using TilmezBus.Web.Resources;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.Admin;

/// <summary>
/// Admin Buses page. The list is fully server-rendered; the grid supports
/// bulk-create (the only add path), inline rename + status toggle, and
/// delete. Trip-schedule editing happens elsewhere — the grid no longer
/// surfaces a schedule icon per the latest design.
/// </summary>
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

    /// <summary>Bulk-create N buses. The server picks BUS-#### serials.</summary>
    [HttpPost]
    public async Task<IActionResult> CreateBatch([FromForm] int count,
                                                 [FromQuery] string? plateNumber = null,
                                                 [FromQuery] string? personName = null)
    {
        if (count <= 0) return StatusCode(400, new { result = _l["Bus_Batch_InvalidCount"].Value });
        var (ok, err) = await ApiClient.CreateBusesBatchAsync(count);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["Bus_Batch_Created", count].Value, 1, plateNumber, personName);
    }

    /// <summary>Inline update: change a single field (number or status).</summary>
    [HttpPost]
    public async Task<IActionResult> UpdateField(Guid id,
                                                 [FromForm] string? plateNumber = null,
                                                 [FromForm] string? status = null,
                                                 [FromQuery] int page = 1,
                                                 [FromQuery] string? plateFilter = null,
                                                 [FromQuery] string? personName = null)
    {
        var (ok, err) = await ApiClient.UpdateBusFieldAsync(id, plateNumber, status);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_BusSaved"], page, plateFilter, personName);
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

    /// <summary>
    /// Returns a PNG QR code for the given token. Generation happens server-
    /// side via QRCoder so the grid no longer depends on the qrcode.js CDN
    /// (which was loading inconsistently in some networks). The token is
    /// the bus's QrToken value; size is the pixels-per-module multiplier so
    /// callers can ask for a thumbnail (size=4) or print resolution (size=10).
    /// </summary>
    [HttpGet]
    [ResponseCache(Duration = 60 * 60 * 24, Location = ResponseCacheLocation.Any)]
    public IActionResult Qr(string token, int size = 4)
    {
        if (string.IsNullOrWhiteSpace(token)) return BadRequest();
        if (size < 1 || size > 20) size = 4;
        using var gen   = new QRCodeGenerator();
        using var data  = gen.CreateQrCode(token, QRCodeGenerator.ECCLevel.M);
        using var png   = new PngByteQRCode(data);
        var bytes       = png.GetGraphic(size);
        return File(bytes, "image/png");
    }

    private async Task<IActionResult> SuccessWithList(string message, int page, string? plateNumber = null, string? personName = null)
    {
        var data = await ApiClient.GetBusesAsync(page, 10, plateNumber, personName);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
