using ClosedXML.Excel;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using SmartBus.Web.Models;
using SmartBus.Web.Resources;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers.Admin;

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

        string[] headers = { "FullName","FullNameEn","NationalNumber","Grade","ParentName",
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
                GradeLabel(s.Grade),
                s.ParentName,
                s.ParentPhone,
                s.Latitude,
                s.Longitude,
                s.CreatedAt
            });
        ws.Cell(2, 1).InsertData(rows);

        // Fixed column widths — skipping AdjustToContents() is the biggest export
        // speedup; autosize is O(rows × cols) and dominates wall-clock time for
        // large sheets. Values chosen to comfortably fit typical content.
        int[] widths = { 28, 28, 18, 14, 22, 16, 12, 12, 18 };
        for (int i = 0; i < widths.Length; i++) ws.Column(i + 1).Width = widths[i];
        // Display CreatedAt as a real date instead of an Excel serial number.
        ws.Column(9).Style.DateFormat.Format = "yyyy-MM-dd HH:mm";

        using var ms = new MemoryStream();
        wb.SaveAs(ms);
        return File(ms.ToArray(),
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            $"students-{DateTime.UtcNow:yyyyMMdd-HHmm}.xlsx");
    }

    // Translates a grade code ("1", "2", ...) to its localized label.
    // Tries the resource localizer first; if that returns the key unchanged
    // (ResourceNotFound) or any unexpected value, falls back to a hardcoded
    // table so the export is never left with raw numeric codes.
    private static readonly Dictionary<string, (string Ar, string En)> _gradeFallback = new()
    {
        ["KG1"] = ("روضة أولى",       "KG 1"),
        ["KG2"] = ("روضة ثانية",      "KG 2"),
        ["1"]   = ("الصف الأول",       "Grade 1"),
        ["2"]   = ("الصف الثاني",      "Grade 2"),
        ["3"]   = ("الصف الثالث",      "Grade 3"),
        ["4"]   = ("الصف الرابع",      "Grade 4"),
        ["5"]   = ("الصف الخامس",      "Grade 5"),
        ["6"]   = ("الصف السادس",      "Grade 6"),
        ["7"]   = ("الصف السابع",      "Grade 7"),
        ["8"]   = ("الصف الثامن",      "Grade 8"),
        ["9"]   = ("الصف التاسع",      "Grade 9"),
        ["10"]  = ("الصف العاشر",      "Grade 10"),
        ["11"]  = ("الصف الحادي عشر",  "Grade 11"),
        ["12"]  = ("الصف الثاني عشر",  "Grade 12"),
    };

    private string GradeLabel(string? grade)
    {
        if (string.IsNullOrEmpty(grade)) return string.Empty;

        var key = "Std_Grade" + grade;
        var ls  = _l[key];
        if (!ls.ResourceNotFound && !string.IsNullOrEmpty(ls.Value) && ls.Value != key)
            return ls.Value;

        // Fallback table — honours the current UI culture.
        if (_gradeFallback.TryGetValue(grade, out var pair))
        {
            var isAr = System.Globalization.CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ar";
            return isAr ? pair.Ar : pair.En;
        }
        return grade;
    }

    // ── Import template (empty file with headers + example row) ────────────
    [HttpGet]
    public IActionResult Template()
    {
        using var wb = new XLWorkbook();
        var ws = wb.AddWorksheet("Students");

        string[] headers = { "FullName","FullNameEn","NationalNumber","Grade","ParentName","ParentPhone" };
        for (int i = 0; i < headers.Length; i++) ws.Cell(1, i + 1).Value = headers[i];
        ws.Row(1).Style.Font.Bold = true;
        ws.Row(1).Style.Fill.BackgroundColor = XLColor.FromHtml("#FFFDE7");

        // Example row so the importer can see the expected shape
        ws.Cell(2, 1).Value = "أحمد محمد";
        ws.Cell(2, 2).Value = "Ahmad Mohammad";
        ws.Cell(2, 3).Value = "9991234567";
        ws.Cell(2, 4).Value = "1";
        ws.Cell(2, 5).Value = "محمد خالد";
        ws.Cell(2, 6).Value = "0791234567";
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
            int cGrade  = Col("Grade");
            int cPar    = Col("ParentName");
            int cPhone  = Col("ParentPhone");
            int cFullEn = Col("FullNameEn");

            if (cFull < 0 || cNat < 0 || cGrade < 0 || cPar < 0 || cPhone < 0)
                return StatusCode(400, new { result = _l["Student_ImportHint"].Value });

            // Parse every data row into a typed DTO. Row-level structural validation
            // (required fields) happens here so failed rows are counted client-side
            // and don't need a server round-trip. Format conversion (Grade label →
            // canonical code) happens here too.
            var bulkRows = new List<Application.Features.Students.Commands.BulkUpsertStudents.BulkUpsertStudentRow>();
            foreach (var row in sheet.RowsUsed().Skip(1))
            {
                string Get(int col) => col > 0 ? row.Cell(col).GetString().Trim() : string.Empty;

                var fullName   = Get(cFull);
                var nat        = Get(cNat);
                var grade      = GradeFromAnything(Get(cGrade));  // accept "1" or "الأول"
                var parentName = Get(cPar);
                var phone      = Get(cPhone);
                var fullEn     = Get(cFullEn);

                if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(grade) ||
                    string.IsNullOrEmpty(nat) ||
                    string.IsNullOrEmpty(parentName) || string.IsNullOrEmpty(phone))
                {
                    failed++;
                    continue;
                }

                bulkRows.Add(new Application.Features.Students.Commands.BulkUpsertStudents.BulkUpsertStudentRow(
                    fullName, fullEn, nat, grade, parentName, phone));
            }

            if (bulkRows.Count > 0)
            {
                var (ok, result, error) = await ApiClient.BulkUpsertStudentsAsync(bulkRows);
                if (ok && result is not null)
                {
                    imported += result.Created + result.Updated;
                    failed   += result.Failed;
                }
                else
                {
                    _logger.LogWarning("Bulk-upsert returned an error: {Error}", error);
                    failed += bulkRows.Count;
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Student import failed");
            return StatusCode(400, new { result = ex.Message });
        }

        var message = string.Format(_l["Student_ImportResult"].Value, imported, failed);
        return await SuccessWithList(message, page: 1, null, null);
    }

    // Accepts a numeric code like "1" OR a localized label like "الأول" / "Grade 1"
    // and returns the canonical code ("1" — "9" / "KG1" / "KG2").
    private string GradeFromAnything(string raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return string.Empty;
        var trimmed = raw.Trim();
        // Direct numeric / KG code passthrough
        if (trimmed.All(char.IsDigit) || trimmed.StartsWith("KG", StringComparison.OrdinalIgnoreCase))
            return trimmed.ToUpperInvariant();

        // Try to reverse-map a label to its code
        string[] candidates = ["KG1","KG2","1","2","3","4","5","6","7","8","9","10","11","12"];
        foreach (var code in candidates)
        {
            var ls = _l["Std_Grade" + code];
            if (!ls.ResourceNotFound && string.Equals(ls.Value, trimmed, StringComparison.OrdinalIgnoreCase))
                return code;
        }
        return trimmed;
    }

    private async Task<IActionResult> SuccessWithList(string message, int page, string? name, string? grade, string? homeArea = null)
    {
        var data = await ApiClient.GetStudentsAsync(page, 10, name, grade, homeArea);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
