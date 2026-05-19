using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.DemoRequests.Queries.GetAllDemoRequests;
using TilmezBus.Domain.Enums;
using TilmezBus.Web.Models;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.SuperAdmin;

[Route("SuperAdmin/DemoRequests")]
public class SuperAdminDemoRequestsController : SuperAdminControllerBase
{
    public SuperAdminDemoRequestsController(IApiClient apiClient) : base(apiClient) { }

    [HttpGet("")]
    public async Task<IActionResult> Index([FromQuery] int page = 1, [FromQuery] string? status = null)
    {
        DemoRequestStatus? parsed = null;
        if (Enum.TryParse<DemoRequestStatus>(status, ignoreCase: true, out var v)) parsed = v;

        var data = await ApiClient.GetDemoRequestsAsync(page, 20, parsed);
        var vm   = new DemoRequestsPageViewModel
        {
            ActivePage    = "demoRequests",
            PageTitle     = "طلبات تجربة المنصّة",
            CurrentPage   = page,
            StatusFilter  = status,
            Data          = data ?? PagedResult<DemoRequestDto>.Create(Array.Empty<DemoRequestDto>(), 0, page, 20)
        };
        return View(vm);
    }

    [HttpPost("complete/{id:guid}")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Complete(Guid id, [FromForm] int page = 1, [FromForm] string? status = null)
    {
        var (ok, _) = await ApiClient.CompleteDemoRequestAsync(id);
        TempData["DemoOpResult"] = ok ? "ok" : "err";
        var qs = $"?page={page}";
        if (!string.IsNullOrEmpty(status)) qs += $"&status={status}";
        return Redirect($"/SuperAdmin/DemoRequests{qs}");
    }
}
