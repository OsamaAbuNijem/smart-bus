using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Models;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

public class AccountController : Controller
{
    private readonly IApiClient _apiClient;

    public AccountController(IApiClient apiClient)
        => _apiClient = apiClient;

    [HttpGet]
    public IActionResult Login(string? returnUrl = null)
    {
        ViewData["ReturnUrl"] = returnUrl;
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(LoginViewModel model, string? returnUrl = null)
    {
        if (!ModelState.IsValid) return View(model);

        var (token, roles) = await _apiClient.LoginAsync(model.Email, model.Password);
        if (token is null)
        {
            ModelState.AddModelError(string.Empty, "البريد الإلكتروني أو كلمة المرور غير صحيحة.");
            return View(model);
        }

        HttpContext.Session.SetString("JwtToken", token);

        if (roles.Contains("SuperAdmin"))
            return RedirectToAction("Dashboard", "SuperAdmin");

        // Cache the admin's school once so every page doesn't re-hit /schools/current.
        var school = await _apiClient.GetMySchoolAsync();
        HttpContext.Session.SetString("SchoolName", school?.Name ?? string.Empty);
        HttpContext.Session.SetString("SchoolCity", school?.City ?? string.Empty);

        if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
            return Redirect(returnUrl);

        return RedirectToAction("Index", "Dashboard");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Logout()
    {
        HttpContext.Session.Clear();
        return RedirectToAction(nameof(Login));
    }
}
