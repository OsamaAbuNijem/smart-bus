using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Models;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.Admin;

public class SettingsController : AdminControllerBase
{
    public SettingsController(IApiClient apiClient) : base(apiClient) { }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "settings", "الإعدادات"));
}
