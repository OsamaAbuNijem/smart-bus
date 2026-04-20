using System.Globalization;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace SmartBus.Web.Infrastructure;

/// <summary>
/// Parses <see cref="double"/> / <see cref="double?"/> form/query values using
/// <see cref="CultureInfo.InvariantCulture"/>, regardless of the request culture.
/// Needed because form fields like "31.960027" fail to bind under RTL / ar cultures
/// that use a different decimal separator.
/// </summary>
public class InvariantDoubleBinder : IModelBinder
{
    public Task BindModelAsync(ModelBindingContext ctx)
    {
        var raw = ctx.ValueProvider.GetValue(ctx.ModelName).FirstValue;
        if (string.IsNullOrWhiteSpace(raw))
        {
            ctx.Result = ModelBindingResult.Success(null);
            return Task.CompletedTask;
        }
        if (double.TryParse(raw, NumberStyles.Float, CultureInfo.InvariantCulture, out var value))
        {
            ctx.Result = ModelBindingResult.Success(value);
        }
        else
        {
            ctx.ModelState.TryAddModelError(ctx.ModelName, $"'{raw}' is not a valid number.");
        }
        return Task.CompletedTask;
    }
}

public class InvariantDoubleBinderProvider : IModelBinderProvider
{
    public IModelBinder? GetBinder(ModelBinderProviderContext context)
    {
        var t = context.Metadata.ModelType;
        return t == typeof(double) || t == typeof(double?)
            ? new InvariantDoubleBinder()
            : null;
    }
}
