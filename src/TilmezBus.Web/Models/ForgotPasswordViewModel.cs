using System.ComponentModel.DataAnnotations;

namespace TilmezBus.Web.Models;

public class ForgotPasswordViewModel
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = default!;
}

public class ResetPasswordViewModel
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = default!;

    [Required]
    public string Token { get; set; } = default!;

    [Required]
    [DataType(DataType.Password)]
    [MinLength(8)]
    public string NewPassword { get; set; } = default!;

    [Required]
    [DataType(DataType.Password)]
    [Compare(nameof(NewPassword), ErrorMessage = "Passwords do not match.")]
    public string ConfirmPassword { get; set; } = default!;
}
