using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using SmartBus.Web.Filters;
using SmartBus.Web.Models;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

[RequireJwt]
public abstract class AdminControllerBase : Controller
{
    protected readonly IApiClient ApiClient;

    protected AdminControllerBase(IApiClient apiClient) => ApiClient = apiClient;

    /// <summary>Hydrates the common sidebar fields (school name + city) on a view model.</summary>
    protected async Task<T> PopulateAsync<T>(T vm, string activePage, string pageTitle)
        where T : AdminPageViewModel
    {
        var school = await ApiClient.GetMySchoolAsync();
        vm.ActivePage = activePage;
        vm.PageTitle  = pageTitle;
        vm.SchoolName = school?.Name ?? string.Empty;
        vm.SchoolCity = school?.City ?? string.Empty;
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
