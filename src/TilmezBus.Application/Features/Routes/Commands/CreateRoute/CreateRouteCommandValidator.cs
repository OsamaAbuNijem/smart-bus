using FluentValidation;

namespace TilmezBus.Application.Features.Routes.Commands.CreateRoute;

public class CreateRouteCommandValidator : AbstractValidator<CreateRouteCommand>
{
    public CreateRouteCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Stops).NotNull();
        RuleForEach(x => x.Stops).ChildRules(stop =>
        {
            stop.RuleFor(s => s.Name).NotEmpty().MaximumLength(100);
            stop.RuleFor(s => s.Order).GreaterThanOrEqualTo(0);
        });
    }
}
