using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;
using SmartBus.Application.Features.Trips.Queries.GetAllTrips;

namespace SmartBus.Web.Services;

public interface IApiClient
{
    Task<string?> LoginAsync(string email, string password);
    Task<PagedResult<BusDto>?> GetBusesAsync(int pageNumber = 1, int pageSize = 10);
    Task<BusDto?> GetBusByIdAsync(Guid busId);
    Task<PagedResult<TripDto>?> GetTripsAsync(int pageNumber = 1, int pageSize = 10);
}
