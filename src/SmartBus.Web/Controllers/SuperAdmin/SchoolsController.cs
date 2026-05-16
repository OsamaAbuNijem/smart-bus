using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.SuperAdmin;

[Route("SuperAdmin/Schools")]
public class SchoolsController : SuperAdminControllerBase
{
    public SchoolsController(IApiClient apiClient) : base(apiClient) { }

    [HttpGet]
    public IActionResult Index() =>
        View(Page("schools", "المدارس"));
}
