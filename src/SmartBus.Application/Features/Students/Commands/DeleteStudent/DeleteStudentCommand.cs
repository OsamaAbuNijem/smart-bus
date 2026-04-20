using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Commands.DeleteStudent;

public record DeleteStudentCommand(Guid StudentId) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"student:{StudentId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "students:page:*" };
}
