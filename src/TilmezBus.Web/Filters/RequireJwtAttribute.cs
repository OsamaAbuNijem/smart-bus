using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace TilmezBus.Web.Filters;

/// <summary>
/// Applied to MVC actions/controllers. If no JwtToken in session, redirects to Account/Login.
/// For XHR requests returns 401 so the JS layer can redirect.
/// </summary>
public class RequireJwtAttribute : Attribute, IAuthorizationFilter
{
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var token = context.HttpContext.Session.GetString("JwtToken");
        if (!string.IsNullOrEmpty(token)) return;

        var isXhr = context.HttpContext.Request.Headers["X-Requested-With"] == "XMLHttpRequest";
        if (isXhr) { context.Result = new UnauthorizedResult(); return; }

        // Path-aware redirect: there's both an admin and a super-admin
        // AccountController; RedirectToAction("Login","Account") is ambiguous
        // and URL gen picks the attribute-routed SA one. Pick by the request
        // path so super-admin pages bounce to /SuperAdmin/Login and everything
        // else to /Account/Login.
        var path = context.HttpContext.Request.Path.Value ?? string.Empty;
        var isSuperAdmin = path.StartsWith("/SuperAdmin", StringComparison.OrdinalIgnoreCase);
        context.Result = new RedirectResult(isSuperAdmin ? "/SuperAdmin/Login" : "/Account/Login");
    }
}
