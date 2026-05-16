using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Models;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.SuperAdmin;

// Class is named SuperAdminDashboardController (not DashboardController) so
// the MVC controller name is "SuperAdminDashboard" — keeps URL generation
// unambiguous next to Admin.DashboardController.
[Route("SuperAdmin/Dashboard")]
public class SuperAdminDashboardController : SuperAdminControllerBase
{
    public SuperAdminDashboardController(IApiClient apiClient) : base(apiClient) { }

    /// <summary>
    /// Action-level fetch: calls the API's dashboard aggregate, builds a
    /// typed ViewModel, and renders. Mirrors admin's DashboardController.Index
    /// pattern — every stat card binds to <c>@Model.*</c> in the view, no
    /// dashboard XHR roundtrip from the browser.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var stats = await ApiClient.GetSuperAdminDashboardStatsAsync();
        var vm    = SuperAdminDashboardViewModel.FromDto(stats, activePage: "overview", pageTitle: "لوحة المشرف العام");
        return View(vm);
    }
}
