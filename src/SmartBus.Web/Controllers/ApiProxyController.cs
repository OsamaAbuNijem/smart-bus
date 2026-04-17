using Microsoft.AspNetCore.Mvc;
using System.Net.Http.Headers;

namespace SmartBus.Web.Controllers;

/// <summary>
/// Thin reverse-proxy: forwards browser fetch() calls to the backend API,
/// injecting the JWT stored in the server-side session.
/// Route: /api-proxy/{*path}
/// </summary>
[Route("api-proxy/{**path}")]
public class ApiProxyController : ControllerBase
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _config;

    public ApiProxyController(IHttpClientFactory factory, IConfiguration config)
    {
        _httpClient = factory.CreateClient("ApiProxy");
        _config = config;
    }

    [HttpGet, HttpPost, HttpPut, HttpPatch, HttpDelete]
    public async Task<IActionResult> Proxy(string path, CancellationToken ct)
    {
        // Only allow XHR calls from this app
        if (Request.Headers["X-Requested-With"] != "XMLHttpRequest")
            return Forbid();

        var token = HttpContext.Session.GetString("JwtToken");
        if (string.IsNullOrEmpty(token))
            return Unauthorized(new { error = "Session expired. Please log in again." });

        var baseUrl = _config["ApiBaseUrl"]?.TrimEnd('/') ?? "https://localhost:7100";
        var query = Request.QueryString.Value ?? "";
        var targetUrl = $"{baseUrl}/api/v1/{path}{query}";

        using var upstream = new HttpRequestMessage(new HttpMethod(Request.Method), targetUrl);
        upstream.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        // Forward body for POST/PUT/PATCH
        if (Request.ContentLength > 0 || Request.Method == "POST")
        {
            var body = await new StreamReader(Request.Body).ReadToEndAsync(ct);
            upstream.Content = new StringContent(body, System.Text.Encoding.UTF8, "application/json");
        }

        HttpResponseMessage response;
        try { response = await _httpClient.SendAsync(upstream, ct); }
        catch (Exception ex) { return StatusCode(502, new { error = ex.Message }); }

        var json = await response.Content.ReadAsStringAsync(ct);
        return Content(json, "application/json", System.Text.Encoding.UTF8);
    }
}
