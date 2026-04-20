using System.ComponentModel.DataAnnotations;

namespace SmartBus.Web.Models;

public class DriverInput
{
    [Required(ErrorMessage = "Validation_Required")]
    public string FullName { get; set; } = string.Empty;

    public string? FullNameEn { get; set; }

    [Required(ErrorMessage = "Validation_Required")]
    public string PhoneNumber { get; set; } = string.Empty;

    [Required(ErrorMessage = "Validation_Required")]
    public string LicenseNumber { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    [RegularExpression("Driver|Assistant", ErrorMessage = "Validation_DriverType")]
    public string DriverType { get; set; } = "Driver";
}
