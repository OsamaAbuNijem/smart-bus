using MediatR;
using Microsoft.Extensions.Logging;

namespace TilmezBus.Application.Common.Behaviors;

public class LoggingBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly ILogger<LoggingBehavior<TRequest, TResponse>> _logger;

    public LoggingBehavior(ILogger<LoggingBehavior<TRequest, TResponse>> logger)
        => _logger = logger;

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        var requestName = typeof(TRequest).Name;
        _logger.LogInformation("TilmezBus Request: {RequestName} {@Request}", requestName, request);

        TResponse response;
        try
        {
            response = await next();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "TilmezBus Request Failed: {RequestName}", requestName);
            throw;
        }

        _logger.LogInformation("TilmezBus Request Completed: {RequestName}", requestName);
        return response;
    }
}
