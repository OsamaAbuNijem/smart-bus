using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;

namespace TilmezBus.Web.Controllers;

/// <summary>Sets the culture cookie and redirects back.</summary>
public class LanguageController : Controller
{
    [HttpGet]
    public IActionResult Set(string culture, string returnUrl = "/")
    {
        if (!string.IsNullOrWhiteSpace(culture))
            Response.Cookies.Append(
                CookieRequestCultureProvider.DefaultCookieName,
                CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(culture)),
                new CookieOptions
                {
                    Expires  = DateTimeOffset.UtcNow.AddYears(1),
                    IsEssential = true,
                    Path     = "/"
                });

        return LocalRedirect(returnUrl);
    }
}
