using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.SuperAdmin;

// Class is named SuperAdminDashboardController (not DashboardController) so
// the MVC controller name is "SuperAdminDashboard" — keeps URL generation
// unambiguous next to Admin.DashboardController.
[Route("SuperAdmin/Dashboard")]
public class SuperAdminDashboardController : SuperAdminControllerBase
{
    public SuperAdminDashboardController(IApiClient apiClient) : base(apiClient) { }

    [HttpGet]
    public IActionResult Index() =>
        View(Page("overview", "لوحة المشرف العام"));
}
