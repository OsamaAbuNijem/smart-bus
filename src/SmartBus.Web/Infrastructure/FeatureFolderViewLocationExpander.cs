using Microsoft.AspNetCore.Mvc.Razor;

namespace SmartBus.Web.Infrastructure;

/// <summary>
/// Enables feature-folder layout alongside the classic Views/ structure.
/// Looks in Features/{Controller}/{View}.cshtml in addition to the defaults.
/// Drop new features into Features/Xyz/XyzController.cs + Features/Xyz/Index.cshtml.
/// </summary>
public class FeatureFolderViewLocationExpander : IViewLocationExpander
{
    public IEnumerable<string> ExpandViewLocations(
        ViewLocationExpanderContext context,
        IEnumerable<string> viewLocations)
    {
        string[] featureLocations =
        [
            "/Features/{1}/{0}.cshtml",
            "/Features/{1}/Views/{0}.cshtml",
            "/Features/Shared/{0}.cshtml"
        ];
        return featureLocations.Concat(viewLocations);
    }

    public void PopulateValues(ViewLocationExpanderContext context) { }
}
