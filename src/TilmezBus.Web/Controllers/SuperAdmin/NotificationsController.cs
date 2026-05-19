using Microsoft.AspNetCore.Mvc;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.SuperAdmin;

// Class is named SuperAdminNotificationsController (not NotificationsController)
// so MVC's controller name becomes "SuperAdminNotifications" — keeps URL
// generation unambiguous if Admin ever adds its own NotificationsController.
[Route("SuperAdmin/Notifications")]
public class SuperAdminNotificationsController : SuperAdminControllerBase
{
    public SuperAdminNotificationsController(IApiClient apiClient) : base(apiClient) { }

    [HttpGet]
    public IActionResult Index() =>
        View(Page("notifications", "الإشعارات"));
}
