using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace SmartBus.Web.Filters;

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
        context.Result = isXhr
            ? new UnauthorizedResult()
            : new RedirectToActionResult("Login", "Account", null);
    }
}
