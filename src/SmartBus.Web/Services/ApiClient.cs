using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Alerts.Queries.GetAllAlerts;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;
using SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;
using SmartBus.Application.Features.Students.Queries.GetAllStudents;
using SmartBus.Application.Features.Trips.Queries.GetAllTrips;

namespace SmartBus.Web.Services;

public class ApiClient : IApiClient
{
    private readonly HttpClient _httpClient;
    private readonly IHttpContextAccessor _contextAccessor;
    private readonly ILogger<ApiClient> _logger;

    private static readonly JsonSerializerOptions _jsonOptions = new() { PropertyNameCaseInsensitive = true };

    public ApiClient(HttpClient httpClient, IHttpContextAccessor contextAccessor, ILogger<ApiClient> logger)
    {
        _httpClient = httpClient;
        _contextAccessor = contextAccessor;
        _logger = logger;
    }

    private void SetAuthHeader()
    {
        var token = _contextAccessor.HttpContext?.Session.GetString("JwtToken");
        if (!string.IsNullOrEmpty(token))
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
    }

    public async Task<string?> LoginAsync(string email, string password)
    {
        var body = JsonSerializer.Serialize(new { email, password });
        var content = new StringContent(body, Encoding.UTF8, "application/json");
        var response = await _httpClient.PostAsync("api/v1/auth/login", content);

        if (!response.IsSuccessStatusCode) return null;
        var json = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<LoginResult>(json, _jsonOptions);
        return result?.Token;
    }

    public async Task<PagedResult<BusDto>?> GetBusesAsync(int pageNumber = 1, int pageSize = 10)
    {
        SetAuthHeader();
        var response = await _httpClient.GetAsync($"api/v1/buses?pageNumber={pageNumber}&pageSize={pageSize}");
        if (!response.IsSuccessStatusCode) return null;
        var json = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<PagedResult<BusDto>>(json, _jsonOptions);
    }

    public async Task<BusDto?> GetBusByIdAsync(Guid busId)
    {
        SetAuthHeader();
        var response = await _httpClient.GetAsync($"api/v1/buses/{busId}");
        if (!response.IsSuccessStatusCode) return null;
        var json = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<BusDto>(json, _jsonOptions);
    }

    public async Task<PagedResult<TripDto>?> GetTripsAsync(int pageNumber = 1, int pageSize = 10)
    {
        SetAuthHeader();
        var response = await _httpClient.GetAsync($"api/v1/trips?pageNumber={pageNumber}&pageSize={pageSize}");
        if (!response.IsSuccessStatusCode) return null;
        var json = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<PagedResult<TripDto>>(json, _jsonOptions);
    }

    public async Task<PagedResult<StudentDto>?> GetStudentsAsync(int pageNumber = 1, int pageSize = 10)
    {
        SetAuthHeader();
        var response = await _httpClient.GetAsync($"api/v1/students?pageNumber={pageNumber}&pageSize={pageSize}");
        if (!response.IsSuccessStatusCode) return null;
        var json = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<PagedResult<StudentDto>>(json, _jsonOptions);
    }

    public async Task<PagedResult<DriverDto>?> GetDriversAsync(int pageNumber = 1, int pageSize = 10)
    {
        SetAuthHeader();
        var response = await _httpClient.GetAsync($"api/v1/drivers?pageNumber={pageNumber}&pageSize={pageSize}");
        if (!response.IsSuccessStatusCode) return null;
        var json = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<PagedResult<DriverDto>>(json, _jsonOptions);
    }

    public async Task<PagedResult<AlertDto>?> GetAlertsAsync(int pageNumber = 1, int pageSize = 10, int? status = null)
    {
        SetAuthHeader();
        var url = $"api/v1/alerts?pageNumber={pageNumber}&pageSize={pageSize}";
        if (status.HasValue) url += $"&status={status.Value}";
        var response = await _httpClient.GetAsync(url);
        if (!response.IsSuccessStatusCode) return null;
        var json = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<PagedResult<AlertDto>>(json, _jsonOptions);
    }

    private record LoginResult(string Token, string Email, IEnumerable<string> Roles, DateTime ExpiresAt);
}
