using System.ComponentModel.DataAnnotations;

namespace SmartBus.Web.Models;

public class DriverInput
{
    [Required(ErrorMessage = "Validation_Required")]
    public string FullName { get; set; } = string.Empty;

    public string? FullNameEn { get; set; }

    // Jordan mobile: 077 / 078 / 079 followed by 7 digits. 10 digits total.
    [Required(ErrorMessage = "Validation_Required")]
    [RegularExpression(@"^07[789]\d{7}$", ErrorMessage = "Validation_PhoneFormat")]
    public string PhoneNumber { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    [RegularExpression("Driver|Assistant", ErrorMessage = "Validation_DriverType")]
    public string DriverType { get; set; } = "Driver";
}
