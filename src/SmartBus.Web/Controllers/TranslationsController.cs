using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using SmartBus.Web.Resources;

namespace SmartBus.Web.Controllers;

[Route("api/translations")]
public class TranslationsController : Controller
{
    private readonly IStringLocalizer<SharedResources> _l;

    public TranslationsController(IStringLocalizer<SharedResources> l) => _l = l;

    // GET /api/translations/admin — keys consumed by wwwroot/js/admin/*.
    // Keep this dictionary in sync with keys referenced in the JS bundle.
    [HttpGet("admin")]
    public IActionResult Admin()
    {
        var culture = System.Globalization.CultureInfo.CurrentUICulture;
        var isRtl   = culture.TextInfo.IsRightToLeft;

        var payload = new Dictionary<string, object>
        {
            ["studentSaved"]     = _l["JS_StudentSaved"].Value,
            ["driverSaved"]      = _l["JS_DriverSaved"].Value,
            ["tripSaved"]        = _l["JS_TripSaved"].Value,
            ["busSaved"]         = _l["JS_BusSaved"].Value,
            ["alertResolved"]    = _l["JS_AlertResolved"].Value,
            ["alertDismissed"]   = _l["JS_AlertDismissed"].Value,
            ["deletedSuccess"]   = _l["JS_DeletedSuccess"].Value,
            ["passwordChanged"]  = _l["JS_PasswordChanged"].Value,
            ["saveFailed"]       = _l["JS_SaveFailed"].Value,
            ["saving"]           = _l["JS_Saving"].Value,
            ["confirmStartTrip"]         = _l["JS_ConfirmStartTrip"].Value,
            ["confirmCompleteTrip"]      = _l["JS_ConfirmCompleteTrip"].Value,
            ["confirmStartTripTitle"]    = _l["JS_ConfirmStartTripTitle"].Value,
            ["confirmCompleteTripTitle"] = _l["JS_ConfirmCompleteTripTitle"].Value,
            ["startAction"]              = _l["JS_StartAction"].Value,
            ["completeAction"]           = _l["JS_CompleteAction"].Value,

            ["stdMapSearch"]     = _l["Std_MapSearch"].Value,
            ["stdMapTitle"]      = _l["Std_MapTitle"].Value,
            ["stdMapHint"]       = _l["Std_MapHint"].Value,
            ["stdMapArea"]       = _l["Std_MapArea"].Value,
            ["stdMapStreet"]     = _l["Std_MapStreet"].Value,
            ["stdMapLoading"]    = _l["Std_MapLoading"].Value,
            ["stdMapNoResult"]   = _l["Std_MapNoResult"].Value,
            ["stdAddTitle"]      = _l["Std_AddTitle"].Value,
            ["stdEditTitle"]     = _l["Std_EditTitle"].Value,
            ["stdGrade1"]        = _l["Std_Grade1"].Value,
            ["stdGrade2"]        = _l["Std_Grade2"].Value,
            ["stdGrade3"]        = _l["Std_Grade3"].Value,
            ["stdGrade4"]        = _l["Std_Grade4"].Value,
            ["stdGrade5"]        = _l["Std_Grade5"].Value,
            ["stdGrade6"]        = _l["Std_Grade6"].Value,
            ["stdGrade7"]        = _l["Std_Grade7"].Value,
            ["stdGrade8"]        = _l["Std_Grade8"].Value,
            ["stdGrade9"]        = _l["Std_Grade9"].Value,

            ["delTitle"]         = _l["Del_Title"].Value,
            ["delHeading"]       = _l["Del_Heading"].Value,
            ["delBody"]          = _l["Del_Body"].Value,
            ["delBodySuffix"]    = _l["Del_BodySuffix"].Value,
            ["delConfirm"]       = _l["Del_Confirm"].Value,
            ["delCancel"]        = _l["Del_Cancel"].Value,

            ["busScheduleReturnAfterMorning"] = _l["BusSchedule_ReturnAfterMorning"].Value,

            ["driverActive"]     = _l["Driver_Active"].Value,
            ["driverInactive"]   = _l["Driver_Inactive"].Value,
            ["driverAddTitle"]   = _l["Driver_AddTitle"].Value,
            ["driverEditTitle"]  = _l["Driver_EditTitle"].Value,
            ["driverTypeDriver"] = _l["Driver_TypeDriver"].Value,
            ["driverTypeAssist"] = _l["Driver_TypeAssist"].Value,

            ["dashTotal"]           = _l["Dash_Total"].Value,
            ["dashTripsCount"]      = _l["Dash_TripsCount"].Value,
            ["dashTripsToday"]      = _l["Dash_TripsToday"].Value,
            ["dashTripsWeek"]       = _l["Dash_TripsWeek"].Value,
            ["dashChartLabelTrips"] = _l["Dash_ChartLabelTrips"].Value,
            ["dashStatusScheduled"]  = _l["Trip_StatusScheduled"].Value,
            ["dashStatusInProgress"] = _l["Trip_StatusInProgress"].Value,
            ["dashStatusCompleted"]  = _l["Trip_StatusCompleted"].Value,
            ["dashTypeMorning"]      = _l["Trip_Morning"].Value,
            ["dashTypeReturn"]       = _l["Trip_Return"].Value,

            ["isRtl"]            = isRtl,
            ["dir"]              = isRtl ? "rtl" : "ltr"
        };
        return Json(payload);
    }
}
