using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace SmartBus.API.Extensions;

public class AcceptLanguageOperationFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        operation.Parameters ??= [];

        operation.Parameters.Add(new OpenApiParameter
        {
            Name        = "Accept-Language",
            In          = ParameterLocation.Header,
            Required    = false,
            Description = "Response language. Supported: `ar` (default), `en`",
            Schema = new OpenApiSchema
            {
                Type    = "string",
                Enum    = [new OpenApiString("ar"), new OpenApiString("en")],
                Default = new OpenApiString("ar")
            }
        });
    }
}
