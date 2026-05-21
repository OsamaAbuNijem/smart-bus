using TilmezBus.Domain.Common;

namespace TilmezBus.Domain.Entities;

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

    // Home location (from map picker)
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string? HomeArea { get; set; }
    public string? HomeStreet { get; set; }
    public string? HomeBuildingNumber { get; set; }

    // Trip & attendance history
    public ICollection<StudentTrip> StudentTrips { get; set; } = new List<StudentTrip>();
    public ICollection<AbsenceRequest> AbsenceRequests { get; set; } = new List<AbsenceRequest>();
}
