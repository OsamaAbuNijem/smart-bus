using FluentValidation;

namespace TilmezBus.Application.Features.Buses.Commands.CreateBus;

public class CreateBusCommandValidator : AbstractValidator<CreateBusCommand>
{
    public CreateBusCommandValidator()
    {
        RuleFor(x => x.PlateNumber)
            .NotEmpty().WithMessage("Plate number is required.")
            .MaximumLength(20).WithMessage("Plate number must not exceed 20 characters.");

        RuleFor(x => x.Capacity)
            .GreaterThan(0).WithMessage("Capacity must be greater than 0.")
            .LessThanOrEqualTo(100).WithMessage("Capacity must not exceed 100.");
    }
}
