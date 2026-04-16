using FluentValidation;

namespace SmartBus.Application.Features.Drivers.Commands.CreateDriver;

public class CreateDriverCommandValidator : AbstractValidator<CreateDriverCommand>
{
    public CreateDriverCommandValidator()
    {
        RuleFor(x => x.FullName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.PhoneNumber).NotEmpty().MaximumLength(20);
        RuleFor(x => x.LicenseNumber).NotEmpty().MaximumLength(50);
    }
}
