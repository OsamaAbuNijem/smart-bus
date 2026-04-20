using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Alerts.Queries.GetAllAlerts;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;
using SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;
using SmartBus.Application.Features.Schools.Queries.GetAllSchools;
using SmartBus.Application.Features.Students.Queries.GetAllStudents;
using SmartBus.Application.Features.Trips.Queries.GetAllTrips;
using SmartBus.Web.Models;

namespace SmartBus.Web.Services;

public interface IApiClient
{
    Task<(string? Token, IEnumerable<string> Roles)> LoginAsync(string email, string password);

    // Schools
    Task<SchoolDto?> GetMySchoolAsync();

    // Drivers
    Task<PagedResult<DriverDto>?> GetDriversAsync(int pageNumber = 1, int pageSize = 10, string? driverType = null);
    Task<DriverDto?> GetDriverByIdAsync(Guid id);
    Task<(bool Ok, string? Error)> CreateDriverAsync(DriverInput input);
    Task<(bool Ok, string? Error)> UpdateDriverAsync(Guid id, DriverInput input);
    Task<bool> DeleteDriverAsync(Guid id);

    // Students
    Task<PagedResult<StudentDto>?> GetStudentsAsync(int pageNumber = 1, int pageSize = 10,
        string? name = null, string? grade = null, string? homeArea = null);
    Task<StudentDto?> GetStudentByIdAsync(Guid id);
    Task<(bool Ok, string? Error)> CreateStudentAsync(StudentInput input);
    Task<(bool Ok, string? Error)> UpdateStudentAsync(Guid id, StudentInput input);
    Task<bool> DeleteStudentAsync(Guid id);

    // Buses
    Task<PagedResult<BusDto>?> GetBusesAsync(int pageNumber = 1, int pageSize = 10);
    Task<BusDto?> GetBusByIdAsync(Guid busId);
    Task<(bool Ok, string? Error)> CreateBusAsync(BusInput input);
    Task<(bool Ok, string? Error)> UpdateBusAsync(Guid id, BusInput input);
    Task<bool> DeleteBusAsync(Guid id);

    // Trips
    Task<PagedResult<TripDto>?> GetTripsAsync(int pageNumber = 1, int pageSize = 10,
        string? personName = null, DateOnly? date = null, string? status = null);
    Task<List<SmartBus.Application.Features.Trips.Queries.GetTripStudents.TripStudentDto>?> GetTripStudentsAsync(Guid tripId);
    Task<bool> StartTripAsync(Guid id);
    Task<bool> CompleteTripAsync(Guid id);
    Task<bool> DeleteTripAsync(Guid id);
    Task<(bool Ok, string? Message)> GenerateTodayTripsAsync();

    // Alerts
    Task<PagedResult<AlertDto>?> GetAlertsAsync(int pageNumber = 1, int pageSize = 10, int? status = null);
    Task<bool> SetAlertStatusAsync(Guid id, int status);
}
