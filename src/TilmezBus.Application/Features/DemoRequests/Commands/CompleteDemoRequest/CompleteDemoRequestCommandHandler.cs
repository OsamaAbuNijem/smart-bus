using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.DemoRequests.Commands.CompleteDemoRequest;

public class CompleteDemoRequestCommandHandler : IRequestHandler<CompleteDemoRequestCommand, Result>
{
    private readonly IApplicationDbContext _context;

    public CompleteDemoRequestCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result> Handle(CompleteDemoRequestCommand request, CancellationToken cancellationToken)
    {
        var entity = await _context.DemoRequests
            .FirstOrDefaultAsync(d => d.Id == request.Id, cancellationToken);
        if (entity is null) return Result.Failure("Demo request not found.");

        // Idempotent: don't overwrite an existing completion record. If the
        // request is already completed we just return success so the UI can
        // refresh without surfacing an error.
        if (entity.Status == DemoRequestStatus.Pending)
        {
            entity.Status            = DemoRequestStatus.Completed;
            entity.CompletedAt       = DateTime.UtcNow;
            entity.CompletedByUserId = request.CompletedByUserId;
            entity.UpdatedAt         = DateTime.UtcNow;
            await _context.SaveChangesAsync(cancellationToken);
        }

        return Result.Success();
    }
}
