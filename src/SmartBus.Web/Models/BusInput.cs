using System.ComponentModel.DataAnnotations;

namespace SmartBus.Web.Models;

public class BusInput
{
    [Required(ErrorMessage = "Validation_Required")]
    public string PlateNumber { get; set; } = string.Empty;

    [Range(1, 100, ErrorMessage = "Validation_Required")]
    public int Capacity { get; set; }

    [Required(ErrorMessage = "Validation_Required")]
    public string Status { get; set; } = "Inactive";

    public Guid? DriverId { get; set; }
    public Guid? AssistantDriverId { get; set; }

    public List<Guid> StudentIds { get; set; } = new();
}
