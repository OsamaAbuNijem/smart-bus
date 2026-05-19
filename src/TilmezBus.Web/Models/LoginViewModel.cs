using System.ComponentModel.DataAnnotations;

namespace TilmezBus.Web.Models;

public class LoginViewModel
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = default!;

    [Required]
    [DataType(DataType.Password)]
    [MinLength(6)]
    public string Password { get; set; } = default!;

    public bool RememberMe { get; set; }
}
