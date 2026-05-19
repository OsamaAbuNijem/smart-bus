using System.ComponentModel.DataAnnotations;

namespace TilmezBus.Web.Models;

public class StudentInput
{
    [Required(ErrorMessage = "Validation_Required")]
    public string FullName { get; set; } = string.Empty;

    public string? FullNameEn { get; set; }

    // Jordan national ID — 10 digits.
    [Required(ErrorMessage = "Validation_Required")]
    [RegularExpression(@"^\d{10}$", ErrorMessage = "Validation_NationalNumberFormat")]
    public string NationalNumber { get; set; } = string.Empty;

    [Required(ErrorMessage = "Validation_Required")]
    public string Grade { get; set; } = "1";

    [Required(ErrorMessage = "Validation_Required")]
    public string ParentName { get; set; } = string.Empty;

    // Jordan mobile: 9-digit local part shaped "7XXXXXXXX" — first digit is
    // always 7 and the second digit is 7, 8, or 9 (077 / 078 / 079 prefixes).
    // The wire value is either "07XXXXXXXX" (legacy local form) or
    // "+9627XXXXXXXX" (canonical) depending on the caller — both are accepted
    // server-side; the handler normalises via PhoneNumberHelper.Normalize.
    [Required(ErrorMessage = "Validation_Required")]
    [RegularExpression(@"^(\+962|0)?7[789]\d{7}$", ErrorMessage = "Validation_PhoneFormat")]
    public string ParentPhone { get; set; } = string.Empty;

    public double? Latitude    { get; set; }
    public double? Longitude   { get; set; }
    public string? HomeArea    { get; set; }
    public string? HomeStreet  { get; set; }
    public string? HomeBuildingNumber { get; set; }
}
