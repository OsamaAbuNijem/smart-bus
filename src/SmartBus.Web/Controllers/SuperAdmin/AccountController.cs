using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Models;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.SuperAdmin;

/// <summary>
/// Super-admin sign-in only. Logout shares the regular /Account/Logout
/// endpoint, so we don't reimplement it here.
///
/// Class name is intentionally <c>SuperAdminAccountController</c> (not
/// <c>AccountController</c>) so the MVC convention-derived controller name
/// is "SuperAdminAccount". Without this, two classes share the name
/// "AccountController" (admin + SA) and `asp-controller="Account"` /
/// `RedirectToAction(...,"Account")` from anywhere in the app would
/// resolve to whichever URL gen picked first (the SA attribute route wins),
/// so the admin login form would post to /SuperAdmin/Login.
/// </summary>
[Route("SuperAdmin")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class SuperAdminAccountController : Controller
{
    private readonly IApiClient _apiClient;

    public SuperAdminAccountController(IApiClient apiClient) => _apiClient = apiClient;

    [HttpGet("Login")]
    public IActionResult Login()
    {
        if (!string.IsNullOrEmpty(HttpContext.Session.GetString("JwtToken")))
            return Redirect("/SuperAdmin/Dashboard");
        return View();
    }

    [HttpPost("Login")]
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
        return Redirect("/SuperAdmin/Dashboard");
    }
}
