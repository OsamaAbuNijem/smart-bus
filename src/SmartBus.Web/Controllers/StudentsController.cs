using ClosedXML.Excel;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using SmartBus.Web.Models;
using SmartBus.Web.Resources;
using SmartBus.Web.Services;

namespace SmartBus.Web.Controllers;

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
                Grade              = s.Grade,
                ParentName         = s.ParentName,
                ParentNameEn       = s.ParentNameEn,
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

    // ── Export ─────────────────────────────────────────────────────────────
    [HttpGet]
    public async Task<IActionResult> Export(string? name = null, string? grade = null, string? homeArea = null)
    {
        // Pull enough rows for a school-sized export. Filters respected.
        var data = await ApiClient.GetStudentsAsync(1, 10000, name, grade, homeArea);
        using var wb = new XLWorkbook();
        var ws = wb.AddWorksheet("Students");

        string[] headers = { "FullName","FullNameEn","Grade","ParentName","ParentNameEn",
                             "ParentPhone","HomeArea","HomeStreet","HomeBuildingNumber",
                             "Latitude","Longitude","CreatedAt" };
        for (int i = 0; i < headers.Length; i++) ws.Cell(1, i + 1).Value = headers[i];
        ws.Row(1).Style.Font.Bold = true;

        var row = 2;
        foreach (var s in data?.Items ?? Array.Empty<Application.Features.Students.Queries.GetAllStudents.StudentDto>())
        {
            ws.Cell(row, 1).Value  = s.FullName;
            ws.Cell(row, 2).Value  = s.FullNameEn;
            ws.Cell(row, 3).Value  = GradeLabel(s.Grade);           // label (e.g. "الأول") instead of "1"
            ws.Cell(row, 4).Value  = s.ParentName;
            ws.Cell(row, 5).Value  = s.ParentNameEn;
            ws.Cell(row, 6).Value  = s.ParentPhone;
            ws.Cell(row, 7).Value  = s.HomeArea;
            ws.Cell(row, 8).Value  = s.HomeStreet;
            ws.Cell(row, 9).Value  = s.HomeBuildingNumber;
            ws.Cell(row, 10).Value = s.Latitude;
            ws.Cell(row, 11).Value = s.Longitude;
            ws.Cell(row, 12).Value = s.CreatedAt;
            row++;
        }
        ws.Columns().AdjustToContents();

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

        string[] headers = { "FullName","FullNameEn","Grade","ParentName","ParentNameEn",
                             "ParentPhone","HomeArea","HomeStreet","HomeBuildingNumber" };
        for (int i = 0; i < headers.Length; i++) ws.Cell(1, i + 1).Value = headers[i];
        ws.Row(1).Style.Font.Bold = true;
        ws.Row(1).Style.Fill.BackgroundColor = XLColor.FromHtml("#FFFDE7");

        // Example row so the importer can see the expected shape
        ws.Cell(2, 1).Value = "أحمد محمد";
        ws.Cell(2, 2).Value = "Ahmad Mohammad";
        ws.Cell(2, 3).Value = "1";
        ws.Cell(2, 4).Value = "محمد خالد";
        ws.Cell(2, 5).Value = "Mohammad Khaled";
        ws.Cell(2, 6).Value = "+962791234567";
        ws.Cell(2, 7).Value = "عمان";
        ws.Cell(2, 8).Value = "شارع الجامعة";
        ws.Cell(2, 9).Value = "12";
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
            int cGrade  = Col("Grade");
            int cPar    = Col("ParentName");
            int cPhone  = Col("ParentPhone");
            int cFullEn = Col("FullNameEn");
            int cParEn  = Col("ParentNameEn");
            int cArea   = Col("HomeArea");
            int cStreet = Col("HomeStreet");
            int cBuild  = Col("HomeBuildingNumber");

            if (cFull < 0 || cGrade < 0 || cPar < 0 || cPhone < 0)
                return StatusCode(400, new { result = _l["Student_ImportHint"].Value });

            foreach (var row in sheet.RowsUsed().Skip(1))
            {
                string Get(int col) => col > 0 ? row.Cell(col).GetString().Trim() : string.Empty;

                var input = new StudentInput
                {
                    FullName           = Get(cFull),
                    Grade              = GradeFromAnything(Get(cGrade)),  // accept "1" or "الأول"
                    ParentName         = Get(cPar),
                    ParentPhone        = Get(cPhone),
                    FullNameEn         = Get(cFullEn),
                    ParentNameEn       = Get(cParEn),
                    HomeArea           = Get(cArea),
                    HomeStreet         = Get(cStreet),
                    HomeBuildingNumber = Get(cBuild)
                };
                if (string.IsNullOrEmpty(input.FullName) || string.IsNullOrEmpty(input.Grade) ||
                    string.IsNullOrEmpty(input.ParentName) || string.IsNullOrEmpty(input.ParentPhone))
                { failed++; continue; }

                var (ok, _) = await ApiClient.CreateStudentAsync(input);
                if (ok) imported++; else failed++;
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
