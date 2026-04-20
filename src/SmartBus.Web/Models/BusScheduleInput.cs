using System.ComponentModel.DataAnnotations;

namespace SmartBus.Web.Models;

public class BusScheduleInput
{
    [Required(ErrorMessage = "Validation_Required")]
    [RegularExpression(@"^([01]\d|2[0-3]):[0-5]\d$", ErrorMessage = "Validation_TimeFormat")]
    public string MorningTime { get; set; } = string.Empty;

    [Required(ErrorMessage = "Validation_Required")]
    [RegularExpression(@"^([01]\d|2[0-3]):[0-5]\d$", ErrorMessage = "Validation_TimeFormat")]
    public string ReturnTime { get; set; } = string.Empty;

    public byte RepeatDays { get; set; }

    public Guid? MorningDriverId { get; set; }
    public Guid? MorningAssistantId { get; set; }
    public Guid? ReturnDriverId { get; set; }
    public Guid? ReturnAssistantId { get; set; }

    public List<Guid> StudentIds { get; set; } = new();
}
