using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Razor;

namespace TilmezBus.Web.Infrastructure;

/// <summary>
/// View-location resolution. Each controller looks for its views under the
/// matching area folder so the file tree mirrors Controllers/{Admin,SuperAdmin}/
///   * Controllers in TilmezBus.Web.Controllers.Admin       → /Views/Admin/{Controller}/{Action}.cshtml
///   * Controllers in TilmezBus.Web.Controllers.SuperAdmin  → /Views/SuperAdmin/{Controller}/{Action}.cshtml
///   * Anything else falls through to Razor's classic /Views/{Controller}/{Action}.cshtml,
///     /Views/Shared/{Action}.cshtml, plus a back-compat Features/ tree.
///
/// Some super-admin controllers carry the prefix in their class name (e.g.
/// <c>SuperAdminAccountController</c>) to keep URL generation unambiguous
/// against admin counterparts. For these, we also look under the prefix-
/// stripped folder (<c>/Views/SuperAdmin/Account/</c>) so the on-disk layout
/// stays clean.
/// </summary>
public class FeatureFolderViewLocationExpander : IViewLocationExpander
{
    private const string AreaKey = "area";
    private const string StripKey = "controllerShort";

    public void PopulateValues(ViewLocationExpanderContext context)
    {
        var desc = context.ActionContext.ActionDescriptor as ControllerActionDescriptor;
        var ns   = desc?.ControllerTypeInfo.Namespace ?? string.Empty;
        if (ns.EndsWith(".Admin", StringComparison.Ordinal))
            context.Values[AreaKey] = "Admin";
        else if (ns.EndsWith(".SuperAdmin", StringComparison.Ordinal))
            context.Values[AreaKey] = "SuperAdmin";

        // If the controller name starts with the area prefix (e.g. controller
        // class SuperAdminAccountController → controller name "SuperAdminAccount"
        // in the SuperAdmin area), stash the stripped form ("Account") so the
        // view lookup can also try /Views/SuperAdmin/Account/Login.cshtml.
        var area = context.Values.TryGetValue(AreaKey, out var a) ? a : null;
        var name = desc?.ControllerName ?? string.Empty;
        if (area is not null && name.StartsWith(area, StringComparison.Ordinal) && name.Length > area.Length)
            context.Values[StripKey] = name[area.Length..];
    }

    public IEnumerable<string> ExpandViewLocations(
        ViewLocationExpanderContext context,
        IEnumerable<string> viewLocations)
    {
        context.Values.TryGetValue(AreaKey,  out var area);
        context.Values.TryGetValue(StripKey, out var shortName);

        var extra = new List<string>();

        if (area is "Admin")
        {
            extra.Add("/Views/Admin/{1}/{0}.cshtml");
            if (shortName is not null) extra.Add($"/Views/Admin/{shortName}/{{0}}.cshtml");
            extra.Add("/Views/Admin/Shared/{0}.cshtml");
        }
        else if (area is "SuperAdmin")
        {
            extra.Add("/Views/SuperAdmin/{1}/{0}.cshtml");
            if (shortName is not null) extra.Add($"/Views/SuperAdmin/{shortName}/{{0}}.cshtml");
            extra.Add("/Views/SuperAdmin/Shared/{0}.cshtml");
        }

        // Legacy feature-folder layout — kept for backwards compatibility.
        extra.Add("/Features/{1}/{0}.cshtml");
        extra.Add("/Features/{1}/Views/{0}.cshtml");
        extra.Add("/Features/Shared/{0}.cshtml");

        return extra.Concat(viewLocations);
    }
}
