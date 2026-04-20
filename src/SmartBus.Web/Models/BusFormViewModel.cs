using SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;
using SmartBus.Application.Features.Students.Queries.GetAllStudents;

namespace SmartBus.Web.Models;

public class BusFormViewModel
{
    public BusInput Input { get; set; } = new();
    public Guid? BusId { get; set; }
    public IReadOnlyList<DriverDto> Drivers    { get; set; } = Array.Empty<DriverDto>();
    public IReadOnlyList<DriverDto> Assistants { get; set; } = Array.Empty<DriverDto>();
    public IReadOnlyList<StudentDto> Students  { get; set; } = Array.Empty<StudentDto>();
    public HashSet<Guid> SelectedStudentIds    { get; set; } = new();
}
