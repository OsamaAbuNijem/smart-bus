using System.ComponentModel.DataAnnotations;

namespace SmartBus.Web.Models;

public class StudentInput
{
    [Required(ErrorMessage = "Validation_Required")]
    public string FullName { get; set; } = string.Empty;

    public string? FullNameEn { get; set; }

    [Required(ErrorMessage = "Validation_Required")]
    public string Grade { get; set; } = "1";

    [Required(ErrorMessage = "Validation_Required")]
    public string ParentName { get; set; } = string.Empty;

    public string? ParentNameEn { get; set; }

    [Required(ErrorMessage = "Validation_Required")]
    public string ParentPhone { get; set; } = string.Empty;

    public double? Latitude    { get; set; }
    public double? Longitude   { get; set; }
    public string? HomeArea    { get; set; }
    public string? HomeStreet  { get; set; }
    public string? HomeBuildingNumber { get; set; }
}
