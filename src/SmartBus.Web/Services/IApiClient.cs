using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Alerts.Queries.GetAllAlerts;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;
using SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;
using SmartBus.Application.Features.Students.Queries.GetAllStudents;
using SmartBus.Application.Features.Trips.Queries.GetAllTrips;

namespace SmartBus.Web.Services;

public interface IApiClient
{
    Task<(string? Token, IEnumerable<string> Roles)> LoginAsync(string email, string password);
    Task<PagedResult<BusDto>?> GetBusesAsync(int pageNumber = 1, int pageSize = 10);
    Task<BusDto?> GetBusByIdAsync(Guid busId);
    Task<PagedResult<TripDto>?> GetTripsAsync(int pageNumber = 1, int pageSize = 10);
    Task<PagedResult<StudentDto>?> GetStudentsAsync(int pageNumber = 1, int pageSize = 10);
    Task<PagedResult<DriverDto>?> GetDriversAsync(int pageNumber = 1, int pageSize = 10);
    Task<PagedResult<AlertDto>?> GetAlertsAsync(int pageNumber = 1, int pageSize = 10, int? status = null);
}
