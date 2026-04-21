using FluentValidation;

namespace SmartBus.Application.Features.Students.Commands.CreateStudent;

public class CreateStudentCommandValidator : AbstractValidator<CreateStudentCommand>
{
    public CreateStudentCommandValidator()
    {
        RuleFor(x => x.FullName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.NationalNumber)
            .NotEmpty()
            .Matches(@"^\d{10}$")
            .WithMessage("National number must be 10 digits.");
        RuleFor(x => x.Grade).NotEmpty().MaximumLength(20);
        RuleFor(x => x.ParentName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.ParentPhone).NotEmpty().MaximumLength(20);
    }
}
