using System.ComponentModel.DataAnnotations;

namespace TilmezBus.Web.Models;

public class SuperAdminLoginViewModel
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = default!;

    [Required]
    [DataType(DataType.Password)]
    public string Password { get; set; } = default!;
}
