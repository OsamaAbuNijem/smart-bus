using ClosedXML.Excel;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using TilmezBus.Web.Models;
using TilmezBus.Web.Resources;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.Admin;

public class StudentsController : AdminControllerBase
{
    private readonly IStringLocalizer<SharedResources> _l;
    private readonly ILogger<StudentsController> _logger;

    public StudentsController(IApiClient apiClient, IStringLocalizer<SharedResources> l, ILogger<StudentsController> logger)
        : base(apiClient) { _l = l; _logger = logger; }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "students", _l["Student_PageTitle"]));

    [HttpGet]
    public async Task<IActionResult> List(int page = 1, string? name = null, string? grade = null, string? homeArea = null)
        => PartialView("_List", await ApiClient.GetStudentsAsync(page, 10, name, grade, homeArea));

    [HttpGet]
    public async Task<IActionResult> Form(Guid? id = null)
    {
        StudentInput? model = null;
        if (id.HasValue)
        {
            var s = await ApiClient.GetStudentByIdAsync(id.Value);
            if (s is null) return NotFound();
            model = new StudentInput
            {
                FullName           = s.FullName,
                FullNameEn         = s.FullNameEn,
                NationalNumber     = s.NationalNumber ?? string.Empty,
                Grade              = s.Grade,
                ParentName         = s.ParentName,
                ParentPhone        = s.ParentPhone,
                Latitude           = s.Latitude,
                Longitude          = s.Longitude,
                HomeArea           = s.HomeArea,
                HomeStreet         = s.HomeStreet,
                HomeBuildingNumber = s.HomeBuildingNumber
            };
            ViewBag.StudentId = s.Id;
        }
        return PartialView("_Form", model);
    }

    [HttpPost]
    public async Task<IActionResult> Save(StudentInput input)
    {
        if (!ModelState.IsValid) { Response.StatusCode = 400; return PartialView("_Form", input); }
        var (ok, err) = await ApiClient.CreateStudentAsync(input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_StudentSaved"], page: 1, null, null);
    }

    // [FromQuery] is critical here: without it, the default value provider pulls
    // `grade`/`homeArea` from the posted form body (which also has Grade + HomeArea),
    // so the list refresh after save accidentally filters by the edited student's
    // fields — looking like "only the edited student came back". [FromQuery]
    // forces these to bind from the URL query string only.
    [HttpPost]
    public async Task<IActionResult> Update(
        Guid id,
        StudentInput input,
        [FromQuery] int page = 1,
        [FromQuery] string? name = null,
        [FromQuery] string? grade = null,
        [FromQuery] string? homeArea = null)
    {
        if (!ModelState.IsValid) { Response.StatusCode = 400; ViewBag.StudentId = id; return PartialView("_Form", input); }
        var (ok, err) = await ApiClient.UpdateStudentAsync(id, input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_StudentSaved"], page, name, grade, homeArea);
    }

    [HttpPost]
    public async Task<IActionResult> Delete(
        [FromQuery] Guid id,
        [FromQuery] int page = 1,
        [FromQuery] string? name = null,
        [FromQuery] string? grade = null,
        [FromQuery] string? homeArea = null)
    {
        if (!await ApiClient.DeleteStudentAsync(id)) return StatusCode(502);
        return await SuccessWithList(_l["JS_DeletedSuccess"], page, name, grade, homeArea);
    }

    // ── Push notification to parent ─────────────────────────────────────────
    public record SendPushInput(string Title, string Body);

    [HttpPost]
    public async Task<IActionResult> SendPush(Guid id, [FromBody] SendPushInput input)
    {
        if (input is null || string.IsNullOrWhiteSpace(input.Title) || string.IsNullOrWhiteSpace(input.Body))
            return BadRequest(new { error = _l["Push_TitleBodyRequired"].Value });
        var (ok, delivered, error) = await ApiClient.SendPushToStudentParentAsync(id, input.Title, input.Body);
        if (!ok) return StatusCode(502, new { error = error ?? _l["JS_SaveFailed"].Value });
        return Ok(new { delivered });
    }

    // ── Export ─────────────────────────────────────────────────────────────
    [HttpGet]
    public async Task<IActionResult> Export(string? name = null, string? grade = null, string? homeArea = null)
    {
        // Pull enough rows for a school-sized export. Filters respected.
        var data = await ApiClient.GetStudentsAsync(1, 10000, name, grade, homeArea);
        using var wb = new XLWorkbook();
        var ws = wb.AddWorksheet("Students");

        // Grade dropped from the sheet per UX request; the entity still has
        // a Grade column but it's no longer surfaced to admins via Excel.
        string[] headers = { "FullName","FullNameEn","NationalNumber","ParentName",
                             "ParentPhone","Latitude","Longitude","CreatedAt" };
        for (int i = 0; i < headers.Length; i++) ws.Cell(1, i + 1).Value = headers[i];
        ws.Row(1).Style.Font.Bold = true;

        // Project rows into object[] then hand the whole batch to InsertData — the
        // bulk path inside ClosedXML is noticeably faster than per-cell .Value = …
        // assignments once the export gets into the thousands of rows.
        var rows = (data?.Items ?? Array.Empty<Application.Features.Students.Queries.GetAllStudents.StudentDto>())
            .Select(s => new object?[]
            {
                s.FullName,
                s.FullNameEn,
                s.NationalNumber,
                s.ParentName,
                s.ParentPhone,
                s.Latitude,
                s.Longitude,
                s.CreatedAt
            });
        ws.Cell(2, 1).InsertData(rows);

        int[] widths = { 28, 28, 18, 22, 16, 12, 12, 18 };
        for (int i = 0; i < widths.Length; i++) ws.Column(i + 1).Width = widths[i];
        // Display CreatedAt as a real date instead of an Excel serial number.
        ws.Column(8).Style.DateFormat.Format = "yyyy-MM-dd HH:mm";

        using var ms = new MemoryStream();
        wb.SaveAs(ms);
        return File(ms.ToArray(),
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            $"students-{DateTime.UtcNow:yyyyMMdd-HHmm}.xlsx");
    }

    // ── Import template (empty file with headers + example row) ────────────
    [HttpGet]
    public IActionResult Template()
    {
        using var wb = new XLWorkbook();
        var ws = wb.AddWorksheet("Students");

        string[] headers = { "FullName","FullNameEn","NationalNumber","ParentName","ParentPhone" };
        for (int i = 0; i < headers.Length; i++) ws.Cell(1, i + 1).Value = headers[i];
        ws.Row(1).Style.Font.Bold = true;
        ws.Row(1).Style.Fill.BackgroundColor = XLColor.FromHtml("#FFFDE7");

        // Example row so the importer can see the expected shape
        ws.Cell(2, 1).Value = "أحمد محمد";
        ws.Cell(2, 2).Value = "Ahmad Mohammad";
        ws.Cell(2, 3).Value = "9991234567";
        ws.Cell(2, 4).Value = "محمد خالد";
        ws.Cell(2, 5).Value = "0791234567";
        ws.Row(2).Style.Font.Italic = true;
        ws.Row(2).Style.Font.FontColor = XLColor.FromHtml("#94A3B8");

        ws.Columns().AdjustToContents();

        using var ms = new MemoryStream();
        wb.SaveAs(ms);
        return File(ms.ToArray(),
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "students-template.xlsx");
    }

    // ── Import ─────────────────────────────────────────────────────────────
    [HttpPost]
    [RequestSizeLimit(5 * 1024 * 1024)]
    public async Task<IActionResult> Import(IFormFile? file)
    {
        if (file is null || file.Length == 0)
            return StatusCode(400, new { result = _l["Student_ImportNoFile"].Value });

        int imported = 0, failed = 0;
        // Hoist the per-row errors list outside the try so the success-
        // path code that appends it to the toast message can see it.
        var rowErrors = new List<string>();
        try
        {
            using var stream = file.OpenReadStream();
            using var wb     = new XLWorkbook(stream);
            var sheet        = wb.Worksheet(1);
            var headerRow    = sheet.FirstRowUsed();
            if (headerRow is null) return StatusCode(400, new { result = "Empty sheet" });

            var cols = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            foreach (var c in headerRow.CellsUsed())
                cols[c.GetString().Trim()] = c.Address.ColumnNumber;

            int Col(string n) => cols.TryGetValue(n, out var x) ? x : -1;
            int cFull   = Col("FullName");
            int cNat    = Col("NationalNumber");
            int cPar    = Col("ParentName");
            int cPhone  = Col("ParentPhone");
            int cFullEn = Col("FullNameEn");
            // Grade dropped from the sheet; the entity still requires a value
            // so the importer fills in "1" as a default (matches the hidden
            // input on the admin add/edit form).
            const string DefaultGrade = "1";

            if (cFull < 0 || cNat < 0 || cPar < 0 || cPhone < 0)
                return StatusCode(400, new { result = _l["Student_ImportHint"].Value });

            var bulkRows = new List<Application.Features.Students.Commands.BulkUpsertStudents.BulkUpsertStudentRow>();
            foreach (var row in sheet.RowsUsed().Skip(1))
            {
                string Get(int col) => col > 0 ? row.Cell(col).GetString().Trim() : string.Empty;

                var fullName   = Get(cFull);
                var nat        = Get(cNat);
                var parentName = Get(cPar);
                var phone      = Get(cPhone);
                var fullEn     = Get(cFullEn);

                if (string.IsNullOrEmpty(fullName) ||
                    string.IsNullOrEmpty(nat) ||
                    string.IsNullOrEmpty(parentName) || string.IsNullOrEmpty(phone))
                {
                    failed++;
                    continue;
                }

                bulkRows.Add(new Application.Features.Students.Commands.BulkUpsertStudents.BulkUpsertStudentRow(
                    fullName, fullEn, nat, DefaultGrade, parentName, phone));
            }

            // Capture per-row errors from the API so we can surface them
            // to the admin instead of just showing "Failed: N". Without
            // this, a parent-upsert failure (invalid phone, identity
            // policy, etc.) silently rolls every student row into the
            // failed bucket with no hint why.
            if (bulkRows.Count > 0)
            {
                var (ok, result, error) = await ApiClient.BulkUpsertStudentsAsync(bulkRows);
                if (ok && result is not null)
                {
                    imported += result.Created + result.Updated;
                    failed   += result.Failed;
                    if (result.Errors is { Count: > 0 })
                    {
                        rowErrors.AddRange(result.Errors);
                        _logger.LogWarning(
                            "Bulk-upsert reported {Count} per-row errors. First: {First}",
                            result.Errors.Count, result.Errors[0]);
                    }
                }
                else
                {
                    _logger.LogWarning("Bulk-upsert returned an error: {Error}", error);
                    failed += bulkRows.Count;
                    if (!string.IsNullOrWhiteSpace(error)) rowErrors.Add(error);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Student import failed");
            return StatusCode(400, new { result = ex.Message });
        }

        var message = string.Format(_l["Student_ImportResult"].Value, imported, failed);
        // Append the first few error reasons so the admin can act on the
        // failure without digging through server logs. Capped at 3 entries
        // to keep the toast readable when every row fails the same way.
        if (rowErrors.Count > 0)
        {
            var top = rowErrors
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .Take(3)
                .ToList();
            message += " — " + string.Join(" | ", top);
            if (rowErrors.Count > top.Count) message += $" (+{rowErrors.Count - top.Count})";
        }
        return await SuccessWithList(message, page: 1, null, null);
    }

    private async Task<IActionResult> SuccessWithList(string message, int page, string? name, string? grade, string? homeArea = null)
    {
        var data = await ApiClient.GetStudentsAsync(page, 10, name, grade, homeArea);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
