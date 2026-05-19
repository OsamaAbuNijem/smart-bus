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
        var sub  = AdminSessionCache.ReadSubscription(HttpContext.Session);

        // Cache miss — fetch the school once and stash the full snapshot
        // (name + city + subscription) so subsequent renders are free.
        if (name is null || sub is null)
        {
            var school = await ApiClient.GetMySchoolAsync();
            AdminSessionCache.StashSchoolInSession(HttpContext.Session, school);
            name = school?.Name ?? string.Empty;
            sub  = AdminSessionCache.ReadSubscription(HttpContext.Session);
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
