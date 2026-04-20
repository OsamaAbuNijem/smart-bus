using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
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

    private void LogModelStateErrors(string action)
    {
        foreach (var kvp in ModelState)
            foreach (var err in kvp.Value!.Errors)
                _logger.LogWarning("{Action} ModelState: {Field} = {Error}", action, kvp.Key, err.ErrorMessage);
    }

    public async Task<IActionResult> Index()
        => View(await PopulateAsync(new AdminPageViewModel(), "students", _l["Student_PageTitle"]));

    [HttpGet]
    public async Task<IActionResult> List(int page = 1)
        => PartialView("_List", await ApiClient.GetStudentsAsync(page, 10));

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
                FullName          = s.FullName,
                FullNameEn        = s.FullNameEn,
                Grade             = s.Grade,
                ParentName        = s.ParentName,
                ParentNameEn      = s.ParentNameEn,
                ParentPhone       = s.ParentPhone,
                Latitude          = s.Latitude,
                Longitude         = s.Longitude,
                HomeArea          = s.HomeArea,
                HomeStreet        = s.HomeStreet,
                HomeBuildingNumber = s.HomeBuildingNumber
            };
            ViewBag.StudentId = s.Id;
        }
        return PartialView("_Form", model);
    }

    [HttpPost]
    public async Task<IActionResult> Save(StudentInput input)
    {
        if (!ModelState.IsValid) { LogModelStateErrors(nameof(Save)); Response.StatusCode = 400; return PartialView("_Form", input); }
        var (ok, err) = await ApiClient.CreateStudentAsync(input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_StudentSaved"], page: 1);
    }

    [HttpPost]
    public async Task<IActionResult> Update(Guid id, StudentInput input, int page = 1)
    {
        if (!ModelState.IsValid) { LogModelStateErrors(nameof(Update)); Response.StatusCode = 400; ViewBag.StudentId = id; return PartialView("_Form", input); }
        var (ok, err) = await ApiClient.UpdateStudentAsync(id, input);
        if (!ok) return StatusCode(502, new { result = err ?? "Upstream API error" });
        return await SuccessWithList(_l["JS_StudentSaved"], page);
    }

    [HttpPost]
    public async Task<IActionResult> Delete(Guid id, int page = 1)
    {
        if (!await ApiClient.DeleteStudentAsync(id)) return StatusCode(502);
        return await SuccessWithList(_l["JS_DeletedSuccess"], page);
    }

    private async Task<IActionResult> SuccessWithList(string message, int page)
    {
        var data = await ApiClient.GetStudentsAsync(page, 10);
        var html = await RenderPartialAsync("_List", data);
        return Json(new { result = message, html, page });
    }
}
