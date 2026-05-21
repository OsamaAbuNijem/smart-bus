using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Buses.Queries.GetAllBuses;
using TilmezBus.Application.Features.DemoRequests.Queries.GetAllDemoRequests;
using TilmezBus.Domain.Enums;
using TilmezBus.Application.Features.Drivers.Queries.GetAllDrivers;
using TilmezBus.Application.Features.Schools.Queries.GetAllSchools;
using TilmezBus.Application.Features.Students.Queries.GetAllStudents;
using TilmezBus.Application.Features.SuperAdmin.Commands.ImpersonateSchoolAdmin;
using TilmezBus.Application.Features.Dashboard.Queries.GetAdminDashboardStats;
using TilmezBus.Application.Features.Dashboard.Queries.GetLiveDashboardStats;
using TilmezBus.Application.Features.SuperAdmin.Queries.GetDashboardStats;
using TilmezBus.Application.Features.Trips.Queries.GetAllTrips;
using TilmezBus.Web.Models;

namespace TilmezBus.Web.Services;

public interface IApiClient
{
    Task<(string? Token, IEnumerable<string> Roles, bool RateLimited)> LoginAsync(string email, string password);

    // Schools
    Task<SchoolDto?> GetMySchoolAsync();

    // Super-admin dashboard aggregate (schools / buses / drivers / students /
    // active users by role / today's trips by status). Single roundtrip.
    Task<DashboardStatsDto?> GetSuperAdminDashboardStatsAsync();

    // School-admin dashboard aggregate (students / buses / drivers / assistants
    // / trips + today/morning/return trip+student+absent counts).
    Task<AdminDashboardStatsDto?> GetAdminDashboardStatsAsync();

    // Live (in-progress trips) view for the dashboard polling section.
    Task<LiveDashboardStatsDto?> GetLiveDashboardStatsAsync();

    /// <summary>
    /// SuperAdmin operation — mints a JWT for the given school's admin so
    /// the SA UI can swap into the admin session. Returns null on failure
    /// so the caller can fall back to a redirect.
    /// </summary>
    Task<(ImpersonateResultDto? Data, string? Error)> ImpersonateSchoolAdminAsync(Guid schoolId);

    // Drivers
    Task<PagedResult<DriverDto>?> GetDriversAsync(int pageNumber = 1, int pageSize = 10, string? driverType = null);
    Task<DriverDto?> GetDriverByIdAsync(Guid id);
    Task<(bool Ok, string? Error)> CreateDriverAsync(DriverInput input);
    Task<(bool Ok, string? Error)> UpdateDriverAsync(Guid id, DriverInput input);
    /// <summary>Partial driver update for inline-grid editing.</summary>
    Task<(bool Ok, string? Error)> UpdateDriverFieldAsync(Guid id,
        string? fullName = null, string? phoneNumber = null, bool? isActive = null, string? driverType = null);
    Task<bool> DeleteDriverAsync(Guid id);

    // Students
    Task<PagedResult<StudentDto>?> GetStudentsAsync(int pageNumber = 1, int pageSize = 10,
        string? name = null, string? grade = null, string? homeArea = null);
    Task<StudentDto?> GetStudentByIdAsync(Guid id);
    Task<(bool Ok, string? Error)> CreateStudentAsync(StudentInput input);
    Task<(bool Ok, string? Error)> UpdateStudentAsync(Guid id, StudentInput input);
    Task<bool> DeleteStudentAsync(Guid id);
    Task<(bool Ok, TilmezBus.Application.Features.Students.Commands.BulkUpsertStudents.BulkUpsertStudentsResult? Result, string? Error)>
        BulkUpsertStudentsAsync(IReadOnlyList<TilmezBus.Application.Features.Students.Commands.BulkUpsertStudents.BulkUpsertStudentRow> rows);

    // Buses
    Task<PagedResult<BusDto>?> GetBusesAsync(int pageNumber = 1, int pageSize = 10,
        string? plateNumber = null, string? personName = null);
    Task<BusDto?> GetBusByIdAsync(Guid busId);
    Task<(bool Ok, string? Error)> CreateBusAsync(BusInput input);
    Task<(bool Ok, string? Error)> UpdateBusAsync(Guid id, BusInput input);
    Task<(bool Ok, string? Error)> CreateBusesBatchAsync(int count);
    /// <summary>Partial bus update used by the inline-edit grid: any field
    /// left null is preserved server-side.</summary>
    Task<(bool Ok, string? Error)> UpdateBusFieldAsync(Guid id, string? plateNumber = null, string? status = null);
    Task<bool> DeleteBusAsync(Guid id);

    // Trips
    Task<PagedResult<TripDto>?> GetTripsAsync(int pageNumber = 1, int pageSize = 10,
        string? personName = null, DateOnly? date = null, string? status = null,
        string? busPlateNumber = null);
    Task<List<TilmezBus.Application.Features.Trips.Queries.GetTripStudents.TripStudentDto>?> GetTripStudentsAsync(Guid tripId);
    Task<(bool Ok, string? Error)> StartTripAsync(Guid id);
    Task<(bool Ok, string? Error)> CompleteTripAsync(Guid id);
    Task<bool> DeleteTripAsync(Guid id);

    // Notifications
    Task<(bool Ok, int Delivered, string? Error)> SendPushToStudentParentAsync(Guid studentId, string title, string body);

    // Demo requests (public submission + SuperAdmin management)
    Task<(bool Ok, string? Error)> SubmitDemoRequestAsync(string schoolName, string contactName, string email, string? phoneNumber, string? notes);
    Task<PagedResult<DemoRequestDto>?> GetDemoRequestsAsync(int pageNumber = 1, int pageSize = 20, DemoRequestStatus? status = null);
    Task<(bool Ok, string? Error)> CompleteDemoRequestAsync(Guid id);
}
