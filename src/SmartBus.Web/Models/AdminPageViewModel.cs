namespace SmartBus.Web.Models;

public class AdminPageViewModel
{
    public string ActivePage { get; set; } = string.Empty;
    public string PageTitle  { get; set; } = string.Empty;
    public string SchoolName { get; set; } = string.Empty;
    public string SchoolCity { get; set; } = string.Empty;
}

public class DashboardPageViewModel : AdminPageViewModel
{
    public int TotalBuses    { get; set; }
    public int TotalTrips    { get; set; }
    public int TotalStudents { get; set; }
    public int PendingAlerts { get; set; }
}

public class SettingsPageViewModel : AdminPageViewModel
{
    // Most-recent subscription (mirrors what SuperAdmin sees). Null when the
    // school has never been issued one. The view derives a live/expired/
    // future label from IsActive + the two date bounds.
    public DateTime? SubscriptionActivationDate { get; set; }
    public DateTime? SubscriptionExpirationDate { get; set; }
    public SmartBus.Domain.Enums.SubscriptionType? SubscriptionType { get; set; }
    public bool?     SubscriptionIsActive       { get; set; }
    public int?      SubscriptionMaxStudents    { get; set; }
    public int?      SubscriptionMaxBuses       { get; set; }
    public decimal?  SubscriptionPrice          { get; set; }
}
