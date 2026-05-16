using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Filters;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.SuperAdmin;

/// <summary>
/// SuperAdmin "log in as school admin" flow.
///   * POST /SuperAdmin/Impersonate/{schoolId} swaps the SA's session JWT
///     for one minted against the school admin and bounces to /Dashboard.
///   * GET  /SuperAdmin/StopImpersonate restores the SA JWT and returns
///     the user to the super-admin dashboard.
/// The SA's original token is stashed under <c>OriginalJwtToken</c> so we
/// can swap back without making the user log in twice.
/// </summary>
[RequireJwt]
[Route("SuperAdmin")]
public class SuperAdminImpersonateController : Controller
{
    private const string OriginalTokenKey = "OriginalJwtToken";
    private const string ImpersonatedAsKey = "ImpersonatedAs";

    private readonly IApiClient _api;

    public SuperAdminImpersonateController(IApiClient api) => _api = api;

    [HttpPost("Impersonate/{schoolId:guid}")]
    public async Task<IActionResult> Impersonate(Guid schoolId)
    {
        var (data, error) = await _api.ImpersonateSchoolAdminAsync(schoolId);
        if (data is null)
        {
            TempData["ImpersonateError"] = error ?? "Could not start impersonation.";
            return Redirect("/SuperAdmin/Schools");
        }

        // Stash the SA's own JWT so StopImpersonate can put it back; do NOT
        // overwrite an existing OriginalJwtToken (avoids losing the SA's
        // session if the SA accidentally impersonates twice in a row).
        var current = HttpContext.Session.GetString("JwtToken");
        if (current is not null && HttpContext.Session.GetString(OriginalTokenKey) is null)
            HttpContext.Session.SetString(OriginalTokenKey, current);
        HttpContext.Session.SetString("JwtToken", data.Token);
        HttpContext.Session.SetString(ImpersonatedAsKey, $"{data.SchoolName} · {data.Email}");

        // Cache the admin's school (the regular admin login does this too)
        // so the admin layout has SchoolName / SchoolCity right away.
        HttpContext.Session.SetString("SchoolName", data.SchoolName);
        HttpContext.Session.SetString("SchoolCity", string.Empty);

        return Redirect("/Dashboard");
    }

    [HttpGet("StopImpersonate")]
    public IActionResult StopImpersonate()
    {
        var saToken = HttpContext.Session.GetString(OriginalTokenKey);

        // Always clear the impersonation breadcrumbs + cached admin chrome,
        // even if there's no SA token to restore — the goal is a deterministic
        // exit, not a partial cleanup.
        HttpContext.Session.Remove(OriginalTokenKey);
        HttpContext.Session.Remove(ImpersonatedAsKey);
        HttpContext.Session.Remove("SchoolName");
        HttpContext.Session.Remove("SchoolCity");

        if (string.IsNullOrEmpty(saToken))
        {
            // No SA token to restore — leaving the admin token in JwtToken
            // would make every /api-proxy/superadmin/* call 403 once we land
            // on the SA schools page ("failed to load data"). Force a clean
            // re-login so the SA lands in a valid SA session.
            HttpContext.Session.Remove("JwtToken");
            return Redirect("/SuperAdmin/Login");
        }

        HttpContext.Session.SetString("JwtToken", saToken);
        return Redirect("/SuperAdmin/Schools");
    }
}
