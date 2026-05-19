using Microsoft.AspNetCore.Mvc;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers;

/// <summary>
/// Public marketing landing page served at "/". Anyone can visit; the
/// page's only call to action is a button that links to the school-admin
/// login at /Account/Login. Logged-in admins can still bounce straight to
/// /Dashboard from there.
/// </summary>
public class HomeController : Controller
{
    private readonly IApiClient _apiClient;

    public HomeController(IApiClient apiClient) => _apiClient = apiClient;

    [HttpGet]
    public IActionResult Index() => View();

    /// <summary>
    /// Public "Request a demo" form submission. Hands off to the API
    /// (anonymous endpoint there), then re-renders the landing page with
    /// a success or error banner via TempData so a hard refresh after
    /// submission doesn't resubmit.
    /// </summary>
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> RequestDemo(string schoolName, string contactName, string email, string? phoneNumber, string? notes)
    {
        if (string.IsNullOrWhiteSpace(schoolName) ||
            string.IsNullOrWhiteSpace(contactName) ||
            string.IsNullOrWhiteSpace(email))
        {
            TempData["DemoResult"] = "error";
            TempData["DemoMessage"] = "missing-fields";
            return Redirect("/#request-demo");
        }

        var (ok, error) = await _apiClient.SubmitDemoRequestAsync(
            schoolName.Trim(), contactName.Trim(), email.Trim(), phoneNumber?.Trim(), notes?.Trim());

        TempData["DemoResult"]  = ok ? "ok" : "error";
        TempData["DemoMessage"] = ok ? null : error;
        return Redirect("/#request-demo");
    }
}
