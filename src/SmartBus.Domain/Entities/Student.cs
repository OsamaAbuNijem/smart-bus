using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class Student : BaseEntity
{
    public string FullName { get; set; } = default!;
    public string? FullNameEn { get; set; }
    public string SchoolId { get; set; } = default!;
    public string Grade { get; set; } = default!;
    public string? Class { get; set; }
    public DateOnly? DateOfBirth { get; set; }
    public string? Address { get; set; }

    // Parent relationship
    public Guid? ParentId { get; set; }
    public Parent? Parent { get; set; }

    // Kept for backward-compat / denormalized quick access
    public string ParentName { get; set; } = default!;
    public string? ParentNameEn { get; set; }
    public string ParentPhone { get; set; } = default!;

    // Route & pickup
    public Guid? RouteId { get; set; }
    public Route? Route { get; set; }
    public Guid? PickupStopId { get; set; }
    public Stop? PickupStop { get; set; }

    // Bus assignment
    public Guid? BusId { get; set; }
    public Bus? AssignedBus { get; set; }

    // Home location (from map picker)
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string? HomeArea { get; set; }
    public string? HomeStreet { get; set; }
    public string? HomeBuildingNumber { get; set; }

    // Medical & contacts
    public ICollection<StudentAllergy> Allergies { get; set; } = new List<StudentAllergy>();
    public ICollection<EmergencyContact> EmergencyContacts { get; set; } = new List<EmergencyContact>();

    // Trip & attendance history
    public ICollection<StudentTrip> StudentTrips { get; set; } = new List<StudentTrip>();
    public ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
    public ICollection<AbsenceRequest> AbsenceRequests { get; set; } = new List<AbsenceRequest>();
}
