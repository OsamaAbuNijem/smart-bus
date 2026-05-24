using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Features.Students.Queries.GetStudentQrPublic;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers;

/// <summary>
/// Anonymous "lost-and-found" page reached by anyone who scans a
/// student's printed QR with their phone camera. The QR encodes
/// <c>https://&lt;host&gt;/q/{token}</c>; this controller resolves the
/// token against the API and renders a modern card showing student +
/// parent + school contact info so the finder can reunite the kid.
/// </summary>
[AllowAnonymous]
[Route("q")]
public class PublicStudentController : Controller
{
    private readonly IApiClient _api;

    public PublicStudentController(IApiClient api) => _api = api;

    [HttpGet("{token}")]
    public async Task<IActionResult> Show(string token)
    {
        var data = string.IsNullOrWhiteSpace(token)
            ? null
            : await _api.ResolveStudentQrPublicAsync(token);
        return View(data);
    }
}
