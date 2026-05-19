using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Commands.DeleteStudent;

public record DeleteStudentCommand(Guid StudentId) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"student:{StudentId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "students:page:*" };
}
