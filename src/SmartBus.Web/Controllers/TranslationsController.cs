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

    // GET /api/translations/superadmin — keys consumed by wwwroot/js/superadmin/*.
    // Keep this dictionary in sync with keys referenced in those modules.
    [HttpGet("superadmin")]
    public IActionResult SuperAdmin()
    {
        var culture = System.Globalization.CultureInfo.CurrentUICulture;
        var isRtl   = culture.TextInfo.IsRightToLeft;

        var payload = new Dictionary<string, object>
        {
            // Schools page
            ["saSchoolsLoadFailed"]    = _l["SA_Schools_LoadFailed"].Value,
            ["saSchoolsCountInfo"]     = _l["SA_Schools_CountInfo"].Value,
            ["saSchoolsUpdated"]       = _l["SA_Schools_Updated"].Value,
            ["saSchoolsCreated"]       = _l["SA_Schools_Created"].Value,
            ["saSchoolsSaveFailed"]    = _l["SA_Schools_SaveFailed"].Value,
            ["saSchoolsConfirmDelete"] = _l["SA_Schools_ConfirmDelete"].Value,
            ["saSchoolsDeleted"]       = _l["SA_Schools_Deleted"].Value,
            ["saSchoolsDeleteFailed"]  = _l["SA_Schools_DeleteFailed"].Value,
            ["saSchoolsCreatedAt"]     = _l["SA_Schools_CreatedAt"].Value,
            ["saSchoolsNoResults"]     = _l["SA_Schools_NoResults"].Value,
            ["saSchoolsNoSchools"]     = _l["SA_Schools_NoSchools"].Value,
            ["saSchoolsNoSearchMatch"] = _l["SA_Schools_NoSearchMatch"].Value,
            ["saSchoolsEmptyHint"]     = _l["SA_Schools_EmptyHint"].Value,
            ["saSchoolsClearSearch"]   = _l["SA_Schools_ClearSearch"].Value,
            ["saSchoolsAddBtn"]        = _l["SA_Schools_AddBtn"].Value,

            // Dashboard
            ["saDashEmptyTitle"]       = _l["SA_Dash_EmptyTitle"].Value,
            ["saDashEmptyHint"]        = _l["SA_Dash_EmptyHint"].Value,
            ["saDashActiveSuffix"]     = _l["SA_Dash_ActiveSuffix"].Value,
            ["saDashSchoolsActiveSub"] = _l["SA_Dash_SchoolsActiveSub"].Value,
            ["saDashDriversBreakdown"] = _l["SA_Dash_DriversBreakdown"].Value,

            // Subscription type labels (used both in subscriptions table + schools badge fallback)
            ["saSubTypeTrial"]         = _l["SA_Sub_Type_Trial"].Value,
            ["saSubTypeBasic"]         = _l["SA_Sub_Type_Basic"].Value,
            ["saSubTypeStandard"]     = _l["SA_Sub_Type_Standard"].Value,
            ["saSubTypePremium"]       = _l["SA_Sub_Type_Premium"].Value,

            // Common
            ["saEdit"]                 = _l["SA_Common_Edit"].Value,
            ["saDelete"]               = _l["SA_Common_Delete"].Value,
            ["saLoading"]              = _l["SA_Common_Loading"].Value,
            ["saImpersonate"]          = _l["SA_Schools_Action_Impersonate"].Value,
            ["saResetPwdTitle"]        = _l["SA_Schools_Action_ResetPwd"].Value,

            // School map picker (read by schools.js when clearing the form)
            ["saSchoolMapNoPin"]       = _l["SA_School_Map_NoPin"].Value,

            // Schools filter bar — empty state + 2 status pill labels reused in the grid.
            ["saSchoolsFilterEmpty"]   = _l["SA_Schools_Filter_Empty"].Value,
            ["saSchoolsFilterReset"]   = _l["SA_Schools_Filter_Reset"].Value,
            ["saStatusActive"]         = _l["SA_Status_Active"].Value,
            ["saStatusInactive"]       = _l["SA_Status_Inactive"].Value,

            // Drawer — active subscription panel
            ["saDrawerSubUpdate"]      = _l["SA_Drawer_Sub_Update"].Value,
            ["saDrawerSubCreate"]      = _l["SA_Drawer_Sub_Create"].Value,
            ["saDrawerSubNone"]        = _l["SA_Drawer_Sub_None"].Value,
            ["saSubActivationDate"]    = _l["SA_Sub_ActivationDate"].Value,
            ["saSubExpirationDate"]    = _l["SA_Sub_ExpirationDate"].Value,
            ["saSubMaxStudents"]       = _l["SA_Sub_Page_MaxStudents"].Value,
            ["saSubMaxBuses"]          = _l["SA_Sub_Page_MaxBuses"].Value,
            ["saSubPrice"]             = _l["SA_Sub_Price"].Value,
            ["saSubRemaining"]         = _l["SA_Sub_Remaining"].Value,
            ["saSubPaid"]              = _l["SA_Sub_Paid"].Value,
            ["saSubPaidYes"]           = _l["SA_Sub_Paid_Yes"].Value,
            ["saSubPaidPartial"]       = _l["SA_Sub_Paid_Partial"].Value,
            ["saSubPaidNo"]            = _l["SA_Sub_Paid_No"].Value,

            // Settings (change password)
            ["saChangePwdSuccess"]     = _l["SA_Settings_PwdSuccess"].Value,
            ["saChangePwdFailed"]      = _l["SA_Settings_PwdFailed"].Value,

            // Reset school admin password (drawer modal)
            ["saResetPwdSuccess"]      = _l["SA_ResetPwd_Success"].Value,
            ["saResetPwdFailed"]       = _l["SA_ResetPwd_Failed"].Value,

            ["isRtl"]                  = isRtl,
            ["dir"]                    = isRtl ? "rtl" : "ltr"
        };
        return Json(payload);
    }
}
