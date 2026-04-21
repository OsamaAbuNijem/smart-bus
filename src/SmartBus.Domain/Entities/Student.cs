using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class Student : BaseEntity
{
    public string FullName { get; set; } = default!;
    public string? FullNameEn { get; set; }
    public string SchoolId { get; set; } = default!;

    /// <summary>Jordan national ID number (10 digits). Unique per live student.</summary>
    public string NationalNumber { get; set; } = string.Empty;

    public string Grade { get; set; } = default!;
    public string? Class { get; set; }
    public DateOnly? DateOfBirth { get; set; }
    public string? Address { get; set; }

    // Parent relationship — all parent details live on Parent entity
    public Guid? ParentId { get; set; }
    public Parent? Parent { get; set; }

    // Route & pickup
    public Guid? RouteId { get; set; }
    public Route? Route { get; set; }
    public Guid? PickupStopId { get; set; }
    public Stop? PickupStop { get; set; }

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
