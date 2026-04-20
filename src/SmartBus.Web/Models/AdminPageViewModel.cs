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
