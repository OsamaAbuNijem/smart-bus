using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Models;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

public class SuperAdminController : Controller
{
    private readonly IApiClient _apiClient;

    public SuperAdminController(IApiClient apiClient) => _apiClient = apiClient;

    [HttpGet]
    public IActionResult Login()
    {
        if (!string.IsNullOrEmpty(HttpContext.Session.GetString("JwtToken")))
            return RedirectToAction(nameof(Dashboard));
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(SuperAdminLoginViewModel model)
    {
        if (!ModelState.IsValid) return View(model);

        var (token, roles) = await _apiClient.LoginAsync(model.Email, model.Password);
        if (token is null || !roles.Contains("SuperAdmin"))
        {
            ModelState.AddModelError(string.Empty, "بيانات الاعتماد غير صحيحة أو ليس لديك صلاحية المشرف العام.");
            return View(model);
        }

        HttpContext.Session.SetString("JwtToken", token);
        return RedirectToAction(nameof(Dashboard));
    }

    public IActionResult Dashboard()
    {
        if (string.IsNullOrEmpty(HttpContext.Session.GetString("JwtToken")))
            return RedirectToAction(nameof(Login));
        return View();
    }
}
