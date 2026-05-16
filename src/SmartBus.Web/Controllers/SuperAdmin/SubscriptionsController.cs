using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.SuperAdmin;

[Route("SuperAdmin/Subscriptions")]
public class SubscriptionsController : SuperAdminControllerBase
{
    public SubscriptionsController(IApiClient apiClient) : base(apiClient) { }

    [HttpGet]
    public IActionResult Index() =>
        View(Page("subscriptions", "الاشتراكات"));
}
