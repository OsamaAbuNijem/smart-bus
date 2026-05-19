using Microsoft.AspNetCore.Mvc;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.SuperAdmin;

[Route("SuperAdmin/Schools")]
public class SchoolsController : SuperAdminControllerBase
{
    public SchoolsController(IApiClient apiClient) : base(apiClient) { }

    [HttpGet]
    public IActionResult Index() =>
        View(Page("schools", "المدارس"));
}
