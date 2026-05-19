using TilmezBus.Domain.Common;

namespace TilmezBus.Domain.Entities;

public class Stop : BaseEntity
{
    public string Name { get; set; } = default!;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public int Order { get; set; }
    public Guid RouteId { get; set; }
    public Route Route { get; set; } = default!;
}
