using Microsoft.AspNetCore.Mvc;

namespace TilmezBus.Web.ViewComponents;

public class StatCardViewComponent : ViewComponent
{
    public IViewComponentResult Invoke(
        string color,           // card accent color: "blue" | "green" | "yellow" | "red"
        string iconSvg,         // raw svg markup for icon
        string iconBgClass,     // icon-bg-*: "icon-bg-blue" | "icon-bg-green" | ...
        object number,
        string label,
        string change,
        string changeDir = "up",   // "up" | "down"
        string numberId  = "")
        => View(new StatCardModel(color, iconSvg, iconBgClass, number, label, change, changeDir, numberId));

    public record StatCardModel(string Color, string IconSvg, string IconBgClass, object Number,
                                string Label, string Change, string ChangeDir, string NumberId);
}
