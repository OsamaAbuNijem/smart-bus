namespace SmartBus.Web.Models;

public class BusFormViewModel
{
    public BusInput Input { get; set; } = new();
    public Guid? BusId { get; set; }
}
