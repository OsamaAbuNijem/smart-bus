using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;
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

    private record LoginResult(string Token, string Email, IEnumerable<string> Roles, DateTime ExpiresAt);
}
