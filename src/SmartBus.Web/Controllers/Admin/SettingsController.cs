using Microsoft.AspNetCore.Mvc;
using SmartBus.Web.Models;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.Admin;

public class SettingsController : AdminControllerBase
{
    public SettingsController(IApiClient apiClient) : base(apiClient) { }

    public async Task<IActionResult> Index()
    {
        // The Settings page renders the school's current plan + dates, so we
        // refetch /schools/current rather than rely only on the session-cached
        // SchoolName/SchoolCity that PopulateAsync uses.
        var school = await ApiClient.GetMySchoolAsync();
        var vm = await PopulateAsync(new SettingsPageViewModel
        {
            SubscriptionActivationDate = school?.LastSubscriptionActivationDate,
            SubscriptionExpirationDate = school?.LastSubscriptionExpirationDate,
            SubscriptionType           = school?.LastSubscriptionType,
            SubscriptionIsActive       = school?.LastSubscriptionIsActive,
            SubscriptionMaxStudents    = school?.LastSubscriptionMaxStudents,
            SubscriptionMaxBuses       = school?.LastSubscriptionMaxBuses,
            SubscriptionPrice          = school?.LastSubscriptionPrice
        }, "settings", "الإعدادات");
        return View(vm);
    }
}
