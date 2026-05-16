using SmartBus.Application.Features.SuperAdmin.Queries.GetDashboardStats;

namespace SmartBus.Web.Models;

/// <summary>
/// Server-rendered model for /SuperAdmin/Dashboard. The controller fetches
/// <see cref="DashboardStatsDto"/> via IApiClient and exposes the values
/// directly so the Razor view can <c>@Model.TotalSchools</c> without an
/// XHR roundtrip. Mirrors the admin DashboardPageViewModel pattern.
/// </summary>
public class SuperAdminDashboardViewModel : SuperAdminPageViewModel
{
    public int TotalSchools     { get; init; }
    public int SchoolsActiveSub { get; init; }
    public int TotalBuses       { get; init; }
    public int TotalDrivers     { get; init; }
    public int TotalAssistants  { get; init; }
    public int TotalStudents    { get; init; }

    public int ActiveParents    { get; init; }
    public int ActiveDrivers    { get; init; }
    public int ActiveAssistants { get; init; }

    public int TodayParents     { get; init; }
    public int TodayDrivers     { get; init; }
    public int TodayAssistants  { get; init; }

    public int TripsScheduled   { get; init; }
    public int TripsInProgress  { get; init; }
    public int TripsCompleted   { get; init; }

    /// <summary>Convenience for the "drivers + assistants" stat card.</summary>
    public int TotalDriversAndAssistants => TotalDrivers + TotalAssistants;

    public static SuperAdminDashboardViewModel FromDto(DashboardStatsDto? dto, string activePage, string pageTitle)
    {
        // Fall-back zeros when the API call fails so the view still renders;
        // the controller decides whether to surface the error separately.
        return new SuperAdminDashboardViewModel
        {
            ActivePage       = activePage,
            PageTitle        = pageTitle,
            TotalSchools     = dto?.TotalSchools     ?? 0,
            SchoolsActiveSub = dto?.SchoolsActiveSub ?? 0,
            TotalBuses       = dto?.TotalBuses       ?? 0,
            TotalDrivers     = dto?.TotalDrivers     ?? 0,
            TotalAssistants  = dto?.TotalAssistants  ?? 0,
            TotalStudents    = dto?.TotalStudents    ?? 0,
            ActiveParents    = dto?.ActiveUsers.Parent    ?? 0,
            ActiveDrivers    = dto?.ActiveUsers.Driver    ?? 0,
            ActiveAssistants = dto?.ActiveUsers.Assistant ?? 0,
            TodayParents     = dto?.TodayUsers.Parent     ?? 0,
            TodayDrivers     = dto?.TodayUsers.Driver     ?? 0,
            TodayAssistants  = dto?.TodayUsers.Assistant  ?? 0,
            TripsScheduled   = dto?.Trips.Scheduled  ?? 0,
            TripsInProgress  = dto?.Trips.InProgress ?? 0,
            TripsCompleted   = dto?.Trips.Completed  ?? 0,
        };
    }
}
