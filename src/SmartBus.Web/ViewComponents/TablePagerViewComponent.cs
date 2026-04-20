using Microsoft.AspNetCore.Mvc;

namespace SmartBus.Web.ViewComponents;

public class TablePagerViewComponent : ViewComponent
{
    public IViewComponentResult Invoke(string prefix, string prevLabel = "‹ السابق", string nextLabel = "التالي ›")
        => View(new TablePagerModel(prefix, prevLabel, nextLabel));

    public record TablePagerModel(string Prefix, string PrevLabel, string NextLabel);
}
