using System.ComponentModel.DataAnnotations;

namespace TilmezBus.Web.Models;

/// <summary>
/// Add/edit payload for drivers + assistants. The admin UI uses a single
/// name field (no separate Arabic / English column), a phone number stored
/// as "07XXXXXXXXX", and a Driver/Assistant type. Status defaults to Active
/// at create time and is toggled from the grid rather than the form.
/// </summary>
public class DriverInput
{
    [Required(ErrorMessage = "Validation_Required")]
    public string FullName { get; set; } = string.Empty;

    // Jordan mobile, 9-digit local part shaped "7XXXXXXXX" — first digit 7,
    // second digit 7/8/9 (77/78/79 carrier prefixes). The "+962" the user
    // sees is a visual chip only; values arrive raw. Server-side validators
    // also accept the legacy "0XXXXXXXXX" and canonical "+9627XXXXXXXX"
    // forms (optional prefix) so older data round-trips.
    [Required(ErrorMessage = "Validation_Required")]
    [RegularExpression(@"^(\+962|0)?7[789]\d{7}$", ErrorMessage = "Validation_PhoneFormat")]
    public string PhoneNumber { get; set; } = string.Empty;

    [RegularExpression("Driver|Assistant", ErrorMessage = "Validation_DriverType")]
    public string DriverType { get; set; } = "Driver";
}
