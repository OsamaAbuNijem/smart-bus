namespace TilmezBus.Web.Models;

public class AdminPageViewModel
{
    public string ActivePage { get; set; } = string.Empty;
    public string PageTitle  { get; set; } = string.Empty;
    public string SchoolName { get; set; } = string.Empty;
    public string SchoolCity { get; set; } = string.Empty;

    // Most-recent subscription, surfaced in the sidebar plan card on every
    // admin page. Null when the school has no subscription yet. The view
    // derives a live/expired/future/disabled status label from IsActive +
    // the two date bounds.
    public DateTime?                              SubscriptionActivationDate { get; set; }
    public DateTime?                              SubscriptionExpirationDate { get; set; }
    public TilmezBus.Domain.Enums.SubscriptionType? SubscriptionType          { get; set; }
    public bool?                                  SubscriptionIsActive       { get; set; }
    public int?                                   SubscriptionMaxStudents    { get; set; }
    public int?                                   SubscriptionMaxBuses       { get; set; }
    public decimal?                               SubscriptionPrice          { get; set; }
}

public class DashboardPageViewModel : AdminPageViewModel
{
    // Top KPIs (overall, not date-bounded).
    public int TotalStudents   { get; set; }
    public int TotalParents    { get; set; }
    public int TotalBuses      { get; set; }
    public int TotalDrivers    { get; set; }
    public int TotalAssistants { get; set; }
    public int TotalTrips      { get; set; }

    // Today buckets — each carries Trips / Students (roster) / Absent.
    public DashboardTripsBreakdown Today   { get; set; } = new();
    public DashboardTripsBreakdown Morning { get; set; } = new();
    public DashboardTripsBreakdown Return  { get; set; } = new();
}

public class DashboardTripsBreakdown
{
    public int Trips    { get; set; }
    public int Students { get; set; }
    public int Absent   { get; set; }
}

