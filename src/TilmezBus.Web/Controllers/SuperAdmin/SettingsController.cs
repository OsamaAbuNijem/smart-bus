using Microsoft.AspNetCore.Mvc;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.SuperAdmin;

// Class is named SuperAdminSettingsController (not SettingsController) so
// the MVC controller name is "SuperAdminSettings" — keeps URL generation
// unambiguous next to Admin.SettingsController.
[Route("SuperAdmin/Settings")]
public class SuperAdminSettingsController : SuperAdminControllerBase
{
    public SuperAdminSettingsController(IApiClient apiClient) : base(apiClient) { }

    [HttpGet]
    public IActionResult Index() =>
        View(Page("settings", "الإعدادات"));
}
