using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Alerts.Queries.GetAllAlerts;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;
using SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;
using SmartBus.Application.Features.Schools.Queries.GetAllSchools;
using SmartBus.Application.Features.Students.Queries.GetAllStudents;
using SmartBus.Application.Features.Trips.Queries.GetAllTrips;
using SmartBus.Application.Features.Trips.Queries.GetBusSchedule;
using SmartBus.Web.Models;

namespace SmartBus.Web.Services;

public class ApiClient : IApiClient
{
    private readonly HttpClient _httpClient;
    private readonly IHttpContextAccessor _contextAccessor;
    private readonly ILogger<ApiClient> _logger;

    private static readonly JsonSerializerOptions _jsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        Converters = { new System.Text.Json.Serialization.JsonStringEnumConverter() }
    };

    public ApiClient(HttpClient httpClient, IHttpContextAccessor contextAccessor, ILogger<ApiClient> logger)
    {
        _httpClient = httpClient;
        _contextAccessor = contextAccessor;
        _logger = logger;
    }

    // Build a per-request message with the JWT attached.
    // DO NOT touch HttpClient.DefaultRequestHeaders — HttpClient is shared across
    // concurrent callers and mutating its headers causes cross-user auth leakage.
    private HttpRequestMessage AuthorizedRequest(HttpMethod method, string url, HttpContent? content = null)
    {
        var req = new HttpRequestMessage(method, url);
        if (content is not null) req.Content = content;
        var token = _contextAccessor.HttpContext?.Session.GetString("JwtToken");
        if (!string.IsNullOrEmpty(token))
            req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return req;
    }

    public async Task<(string? Token, IEnumerable<string> Roles)> LoginAsync(string email, string password)
    {
        // Login has no bearer yet — no auth header needed.
        var content = new StringContent(
            JsonSerializer.Serialize(new { email, password }), Encoding.UTF8, "application/json");
        var response = await _httpClient.PostAsync("api/v1/auth/login", content);
        if (!response.IsSuccessStatusCode) return (null, []);
        var json = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<LoginResult>(json, _jsonOptions);
        return (result?.Token, result?.Roles ?? []);
    }

    // ── Generic HTTP helpers ───────────────────────────────────────────────
    private async Task<T?> GetAsync<T>(string url)
    {
        using var req = AuthorizedRequest(HttpMethod.Get, url);
        using var response = await _httpClient.SendAsync(req);
        if (!response.IsSuccessStatusCode) return default;
        var json = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<T>(json, _jsonOptions);
    }

    private async Task<(bool Ok, string? Error)> SendAsync(HttpMethod method, string url, object? body = null)
    {
        HttpContent? content = null;
        if (body is not null)
            content = new StringContent(JsonSerializer.Serialize(body, _jsonOptions), Encoding.UTF8, "application/json");
        using var req = AuthorizedRequest(method, url, content);
        using var response = await _httpClient.SendAsync(req);
        if (response.IsSuccessStatusCode) return (true, null);
        var resBody = await response.Content.ReadAsStringAsync();
        _logger.LogWarning("{Method} {Url} failed. Status={Status} Body={Body}", method, url, response.StatusCode, resBody);
        return (false, ExtractError(resBody));
    }

    private async Task<bool> DeleteAsync(string url)
    {
        using var req = AuthorizedRequest(HttpMethod.Delete, url);
        using var response = await _httpClient.SendAsync(req);
        return response.IsSuccessStatusCode;
    }

    private static string? ExtractError(string? body)
    {
        if (string.IsNullOrWhiteSpace(body)) return null;
        try
        {
            using var doc = JsonDocument.Parse(body);
            var root = doc.RootElement;
            if (root.ValueKind != JsonValueKind.Object) return body;
            foreach (var key in new[] { "error", "message", "detail", "title" })
                if (root.TryGetProperty(key, out var p) && p.ValueKind == JsonValueKind.String)
                    return p.GetString();
        }
        catch { }
        return body;
    }

    // ── Schools ────────────────────────────────────────────────────────────
    public Task<SchoolDto?> GetMySchoolAsync()
        => GetAsync<SchoolDto>("api/v1/schools/current");

    // ── Drivers ────────────────────────────────────────────────────────────
    public Task<PagedResult<DriverDto>?> GetDriversAsync(int pageNumber = 1, int pageSize = 10, string? driverType = null)
    {
        var url = $"api/v1/drivers?pageNumber={pageNumber}&pageSize={pageSize}";
        if (!string.IsNullOrEmpty(driverType)) url += $"&driverType={driverType}";
        return GetAsync<PagedResult<DriverDto>>(url);
    }

    public Task<DriverDto?> GetDriverByIdAsync(Guid id)
        => GetAsync<DriverDto>($"api/v1/drivers/{id}");

    public Task<(bool Ok, string? Error)> CreateDriverAsync(DriverInput input)
        => SendAsync(HttpMethod.Post, "api/v1/drivers", input);

    public Task<(bool Ok, string? Error)> UpdateDriverAsync(Guid id, DriverInput input)
        => SendAsync(HttpMethod.Put, $"api/v1/drivers/{id}", input);

    public Task<bool> DeleteDriverAsync(Guid id) => DeleteAsync($"api/v1/drivers/{id}");

    // ── Students ───────────────────────────────────────────────────────────
    public Task<PagedResult<StudentDto>?> GetStudentsAsync(int pageNumber = 1, int pageSize = 10,
        string? name = null, string? grade = null, string? homeArea = null)
    {
        var url = $"api/v1/students?pageNumber={pageNumber}&pageSize={pageSize}";
        if (!string.IsNullOrEmpty(name))     url += $"&name={Uri.EscapeDataString(name)}";
        if (!string.IsNullOrEmpty(grade))    url += $"&grade={grade}";
        if (!string.IsNullOrEmpty(homeArea)) url += $"&homeArea={Uri.EscapeDataString(homeArea)}";
        return GetAsync<PagedResult<StudentDto>>(url);
    }

    public Task<StudentDto?> GetStudentByIdAsync(Guid id)
        => GetAsync<StudentDto>($"api/v1/students/{id}");

    public Task<(bool Ok, string? Error)> CreateStudentAsync(StudentInput input)
        => SendAsync(HttpMethod.Post, "api/v1/students", input);

    public Task<(bool Ok, string? Error)> UpdateStudentAsync(Guid id, StudentInput input)
        => SendAsync(HttpMethod.Put, $"api/v1/students/{id}", input);

    public Task<bool> DeleteStudentAsync(Guid id) => DeleteAsync($"api/v1/students/{id}");

    // ── Buses ──────────────────────────────────────────────────────────────
    public Task<PagedResult<BusDto>?> GetBusesAsync(int pageNumber = 1, int pageSize = 10,
        string? plateNumber = null, string? personName = null)
    {
        var url = $"api/v1/buses?pageNumber={pageNumber}&pageSize={pageSize}";
        if (!string.IsNullOrWhiteSpace(plateNumber)) url += $"&plateNumber={Uri.EscapeDataString(plateNumber)}";
        if (!string.IsNullOrWhiteSpace(personName))  url += $"&personName={Uri.EscapeDataString(personName)}";
        return GetAsync<PagedResult<BusDto>>(url);
    }

    public Task<BusDto?> GetBusByIdAsync(Guid id)
        => GetAsync<BusDto>($"api/v1/buses/{id}");

    public Task<(bool Ok, string? Error)> CreateBusAsync(BusInput input)
        => SendAsync(HttpMethod.Post, "api/v1/buses", input);

    public Task<(bool Ok, string? Error)> UpdateBusAsync(Guid id, BusInput input)
        => SendAsync(HttpMethod.Put, $"api/v1/buses/{id}", input);

    public Task<bool> DeleteBusAsync(Guid id) => DeleteAsync($"api/v1/buses/{id}");

    // ── Trips ──────────────────────────────────────────────────────────────
    public Task<PagedResult<TripDto>?> GetTripsAsync(int pageNumber = 1, int pageSize = 10,
        string? personName = null, DateOnly? date = null, string? status = null)
    {
        var url = $"api/v1/trips?pageNumber={pageNumber}&pageSize={pageSize}";
        if (!string.IsNullOrEmpty(personName)) url += $"&personName={Uri.EscapeDataString(personName)}";
        if (date.HasValue)                     url += $"&date={date.Value:yyyy-MM-dd}";
        if (!string.IsNullOrEmpty(status))     url += $"&status={status}";
        return GetAsync<PagedResult<TripDto>>(url);
    }

    public Task<List<SmartBus.Application.Features.Trips.Queries.GetTripStudents.TripStudentDto>?> GetTripStudentsAsync(Guid tripId)
        => GetAsync<List<SmartBus.Application.Features.Trips.Queries.GetTripStudents.TripStudentDto>>($"api/v1/trips/{tripId}/students");

    public Task<(bool Ok, string? Error)> StartTripAsync(Guid id)
        => SendAsync(HttpMethod.Post, $"api/v1/trips/{id}/start");

    public Task<(bool Ok, string? Error)> CompleteTripAsync(Guid id)
        => SendAsync(HttpMethod.Post, $"api/v1/trips/{id}/complete");

    public Task<bool> DeleteTripAsync(Guid id) => DeleteAsync($"api/v1/trips/{id}");

    public Task<BusScheduleDto?> GetBusScheduleAsync(Guid busId)
        => GetAsync<BusScheduleDto>($"api/v1/trips/bus/{busId}/schedule");

    public Task<(bool Ok, string? Error)> SetBusScheduleAsync(Guid busId, BusScheduleInput input)
        => SendAsync(HttpMethod.Post, $"api/v1/trips/bus/{busId}/schedule", input);

    // ── Alerts ─────────────────────────────────────────────────────────────
    public Task<PagedResult<AlertDto>?> GetAlertsAsync(int pageNumber = 1, int pageSize = 10, int? status = null)
    {
        var url = $"api/v1/alerts?pageNumber={pageNumber}&pageSize={pageSize}";
        if (status.HasValue) url += $"&status={status.Value}";
        return GetAsync<PagedResult<AlertDto>>(url);
    }

    public async Task<bool> SetAlertStatusAsync(Guid id, int status)
    {
        var (ok, _) = await SendAsync(HttpMethod.Post, $"api/v1/alerts/{id}/status", new { status });
        return ok;
    }

    private record LoginResult(string Token, string Email, IEnumerable<string> Roles, DateTime ExpiresAt);
}
