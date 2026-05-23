using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using TilmezBus.Web.Filters;
using TilmezBus.Web.Models;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.Admin;

[RequireJwt]
public abstract class AdminControllerBase : Controller
{
    protected readonly IApiClient ApiClient;

    protected AdminControllerBase(IApiClient apiClient) => ApiClient = apiClient;

    /// <summary>Hydrates the common sidebar fields (school name + city +
    /// subscription snapshot) on a view model. Reads the cached values stashed
    /// in session at login; falls back to the API once if the session is empty
    /// (e.g. the admin logged in before the cache was introduced).</summary>
    protected async Task<T> PopulateAsync<T>(T vm, string activePage, string pageTitle)
        where T : AdminPageViewModel
    {
        vm.ActivePage = activePage;
        vm.PageTitle  = pageTitle;

        var name = HttpContext.Session.GetString("SchoolName");

        // The subscription part of the sidebar must reflect the latest DB
        // state — when the SuperAdmin extends the expiry (or it lapses
        // naturally) the sidebar should pick it up on the next page load,
        // not after the admin logs out. So we always refetch the school
        // snapshot here when the subscription isn't cached for THIS
        // request, and we never persist the sub block across requests.
        // Name + city are stable so they still get cached after the first
        // /schools/current hit.
        SessionSubscription? sub = null;
        if (name is null)
        {
            var school = await ApiClient.GetMySchoolAsync();
            AdminSessionCache.StashSchoolInSession(HttpContext.Session, school);
            name = school?.Name ?? string.Empty;
            sub  = AdminSessionCache.BuildSubscription(school);
        }
        else
        {
            var school = await ApiClient.GetMySchoolAsync();
            sub = AdminSessionCache.BuildSubscription(school);
        }

        vm.SchoolName = name ?? string.Empty;
        vm.SchoolCity = HttpContext.Session.GetString("SchoolCity") ?? string.Empty;
        AdminSessionCache.ApplySubscription(vm, sub);
        return vm;
    }

    /// <summary>Renders a partial view to an HTML string. Used when a JSON response
    /// needs to ship HTML alongside other fields (e.g. `{ result, html }`).</summary>
    protected async Task<string> RenderPartialAsync(string viewName, object? model = null)
    {
        ViewData.Model = model;
        var viewEngine = HttpContext.RequestServices.GetRequiredService<ICompositeViewEngine>();
        var viewResult = viewEngine.FindView(ControllerContext, viewName, isMainPage: false);
        if (!viewResult.Success)
            throw new InvalidOperationException($"View '{viewName}' not found.");

        using var sw = new StringWriter();
        var viewContext = new ViewContext(
            ControllerContext, viewResult.View, ViewData, TempData, sw, new HtmlHelperOptions());
        await viewResult.View.RenderAsync(viewContext);
        return sw.ToString();
    }
}
