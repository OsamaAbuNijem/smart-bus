using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class Student : BaseEntity
{
    public string FullName { get; set; } = default!;
    public string SchoolId { get; set; } = default!;
    public string Grade { get; set; } = default!;
    public string ParentName { get; set; } = default!;
    public string ParentPhone { get; set; } = default!;
    public Guid? RouteId { get; set; }
    public Route? Route { get; set; }
    public string? PickupStopId { get; set; }
}
