using Microsoft.AspNetCore.Mvc;
using TilmezBus.Web.Filters;

namespace TilmezBus.Web.Controllers.SuperAdmin;

/// <summary>
/// Super-admin file uploads (school logos for now). Saves binaries straight
/// to the Web project's wwwroot/uploads/* so they're served by the standard
/// UseStaticFiles middleware — no cross-project URL juggling, no auth on
/// reads. The schools API stores the returned URL in <c>School.LogoUrl</c>.
/// </summary>
[RequireJwt]
[Route("SuperAdmin/Uploads")]
public class UploadsController : Controller
{
    private readonly IWebHostEnvironment _env;

    // Image MIME → file extension whitelist. Anything else gets a 400 so
    // random binaries can't land in wwwroot/uploads.
    private static readonly Dictionary<string, string> _logoExt = new(StringComparer.OrdinalIgnoreCase)
    {
        ["image/png"]     = ".png",
        ["image/jpeg"]    = ".jpg",
        ["image/jpg"]     = ".jpg",
        ["image/webp"]    = ".webp",
        ["image/gif"]     = ".gif",
        ["image/svg+xml"] = ".svg",
    };

    public UploadsController(IWebHostEnvironment env) => _env = env;

    [HttpPost("SchoolLogo")]
    [RequestSizeLimit(4 * 1024 * 1024)]  // 4 MB ceiling — logos are small
    public async Task<IActionResult> SchoolLogo(IFormFile? file, CancellationToken cancellationToken)
    {
        if (file is null || file.Length == 0)
            return BadRequest(new { error = "No file uploaded." });
        if (!_logoExt.TryGetValue(file.ContentType, out var ext))
            return BadRequest(new { error = "Unsupported image type." });

        var dir = Path.Combine(_env.WebRootPath ?? "wwwroot", "uploads", "schools");
        Directory.CreateDirectory(dir);
        var fileName = $"{Guid.NewGuid():N}{ext}";
        var filePath = Path.Combine(dir, fileName);

        await using (var stream = System.IO.File.Create(filePath))
            await file.CopyToAsync(stream, cancellationToken);

        return Json(new { url = $"/uploads/schools/{fileName}" });
    }
}
