using TilmezBus.Application.Features.Drivers.Queries.GetAllDrivers;
using TilmezBus.Application.Features.Students.Queries.GetAllStudents;

namespace TilmezBus.Web.Models;

public class BusScheduleViewModel
{
    public Guid BusId { get; set; }
    public string BusPlateNumber { get; set; } = string.Empty;
    public BusScheduleInput Input { get; set; } = new();
    public IReadOnlyList<DriverDto> Drivers    { get; set; } = Array.Empty<DriverDto>();
    public IReadOnlyList<DriverDto> Assistants { get; set; } = Array.Empty<DriverDto>();
    public IReadOnlyList<StudentDto> Students  { get; set; } = Array.Empty<StudentDto>();
    public HashSet<Guid> SelectedStudentIds    { get; set; } = new();
}
