using FluentValidation;

namespace SmartBus.Application.Features.Drivers.Commands.UpdateDriver;

public class UpdateDriverCommandValidator : AbstractValidator<UpdateDriverCommand>
{
    public UpdateDriverCommandValidator()
    {
        RuleFor(x => x.DriverId).NotEmpty();
        RuleFor(x => x.FullName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .MaximumLength(20)
            .Matches(@"^07[789]\d{7}$")
            .WithMessage("Phone must start with 077, 078 or 079 and be 10 digits long.");
    }
}
