using Microsoft.AspNetCore.Mvc;
using TilmezBus.Web.Models;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers;

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

        var (token, roles, rateLimited) = await _apiClient.LoginAsync(model.Email, model.Password);
        if (rateLimited)
        {
            ModelState.AddModelError(string.Empty, "عدد كبير من الطلبات في وقت قصير. يرجى الانتظار دقيقة والمحاولة مجددًا.");
            return View(model);
        }
        if (token is null)
        {
            ModelState.AddModelError(string.Empty, "البريد الإلكتروني أو كلمة المرور غير صحيحة.");
            return View(model);
        }

        HttpContext.Session.SetString("JwtToken", token);

        // Use explicit URLs: both Admin and SuperAdmin namespaces have a
        // DashboardController, so RedirectToAction("Index","Dashboard") would
        // resolve to whichever URL gen finds first (the SA attribute route
        // wins). Same reasoning for the SA branch.
        if (roles.Contains("SuperAdmin"))
            return Redirect("/SuperAdmin/Dashboard");

        // Cache the admin's school once so every page doesn't re-hit /schools/current.
        // The subscription snapshot lives alongside the name/city so the
        // sidebar plan card can render without an extra roundtrip.
        var school = await _apiClient.GetMySchoolAsync();
        AdminSessionCache.StashSchoolInSession(HttpContext.Session, school);

        if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
            return Redirect(returnUrl);

        return Redirect("/Dashboard");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Logout()
    {
        HttpContext.Session.Clear();
        return RedirectToAction(nameof(Login));
    }

    [HttpGet]
    public IActionResult ForgotPassword() => View(new ForgotPasswordViewModel());

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordViewModel model)
    {
        // Always show the confirmation page — the API endpoint is
        // deliberately anti-enumerating; we mirror that here so an
        // attacker can't read whether the email exists from the UI.
        if (ModelState.IsValid)
            await _apiClient.ForgotPasswordAsync(model.Email);
        return View("ForgotPasswordConfirmation", model);
    }

    [HttpGet]
    public IActionResult ResetPassword(string? email, string? token)
    {
        if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(token))
        {
            ModelState.AddModelError(string.Empty,
                "رابط إعادة تعيين كلمة المرور غير صالح. يرجى طلب رابط جديد.");
        }
        return View(new ResetPasswordViewModel
        {
            Email = email ?? string.Empty,
            Token = token ?? string.Empty,
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ResetPassword(ResetPasswordViewModel model)
    {
        if (!ModelState.IsValid) return View(model);
        var (ok, error) = await _apiClient.ResetPasswordAsync(model.Email, model.Token, model.NewPassword);
        if (!ok)
        {
            ModelState.AddModelError(string.Empty,
                error ?? "تعذرت إعادة تعيين كلمة المرور. حاول مجددًا أو اطلب رابطًا جديدًا.");
            return View(model);
        }
        TempData["ResetPasswordSucceeded"] = "تم تغيير كلمة المرور بنجاح. سجّل الدخول الآن.";
        return RedirectToAction(nameof(Login));
    }
}
