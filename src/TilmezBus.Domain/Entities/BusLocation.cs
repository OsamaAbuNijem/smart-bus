using TilmezBus.Domain.Common;

namespace TilmezBus.Domain.Entities;

public class BusLocation : BaseEntity
{
    public Guid BusId { get; set; }
    public Bus Bus { get; set; } = default!;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public double? Speed { get; set; }
    public double? Heading { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}
