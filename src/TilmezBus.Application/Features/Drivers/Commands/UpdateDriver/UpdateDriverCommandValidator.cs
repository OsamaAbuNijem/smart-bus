using FluentValidation;

namespace TilmezBus.Application.Features.Drivers.Commands.UpdateDriver;

public class UpdateDriverCommandValidator : AbstractValidator<UpdateDriverCommand>
{
    public UpdateDriverCommandValidator()
    {
        RuleFor(x => x.DriverId).NotEmpty();
        // Partial update: only enforce constraints on fields the caller is
        // actually changing (null means "leave as-is").
        When(x => x.FullName is not null, () =>
        {
            RuleFor(x => x.FullName!).NotEmpty().MaximumLength(100);
        });
        When(x => x.PhoneNumber is not null, () =>
        {
            RuleFor(x => x.PhoneNumber!)
                .NotEmpty()
                .MaximumLength(20)
                .Matches(@"^(\+962|0)?7[789]\d{7}$")
                .WithMessage("Phone must be a Jordan mobile: 9-digit local part starting with 77, 78, or 79 (the '+962' prefix is implicit).");
        });
    }
}
