using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class Route : BaseEntity
{
    public string Name { get; set; } = default!;
    public string Description { get; set; } = default!;
    public double StartLatitude { get; set; }
    public double StartLongitude { get; set; }
    public double EndLatitude { get; set; }
    public double EndLongitude { get; set; }
    public ICollection<Stop> Stops { get; set; } = new List<Stop>();
    public ICollection<Trip> Trips { get; set; } = new List<Trip>();
}
