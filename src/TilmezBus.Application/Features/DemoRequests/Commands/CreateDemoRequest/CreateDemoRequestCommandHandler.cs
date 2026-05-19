using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.DemoRequests.Commands.CreateDemoRequest;

public class CreateDemoRequestCommandHandler : IRequestHandler<CreateDemoRequestCommand, Result<Guid>>
{
    private readonly IApplicationDbContext _context;

    public CreateDemoRequestCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<Guid>> Handle(CreateDemoRequestCommand request, CancellationToken cancellationToken)
    {
        var schoolName  = (request.SchoolName  ?? string.Empty).Trim();
        var contactName = (request.ContactName ?? string.Empty).Trim();
        var email       = (request.Email       ?? string.Empty).Trim();
        var phone       = string.IsNullOrWhiteSpace(request.PhoneNumber) ? null : request.PhoneNumber!.Trim();
        var notes       = string.IsNullOrWhiteSpace(request.Notes)       ? null : request.Notes!.Trim();

        // Minimal server-side validation — the form does its own checks, but
        // this is a public endpoint so we re-validate the essentials.
        if (string.IsNullOrEmpty(schoolName) || string.IsNullOrEmpty(contactName) || string.IsNullOrEmpty(email))
            return Result<Guid>.Failure("School name, contact name and email are required.");
        if (!email.Contains('@') || email.Length < 5)
            return Result<Guid>.Failure("Email looks invalid.");

        var entity = new DemoRequest
        {
            SchoolName  = schoolName,
            ContactName = contactName,
            Email       = email,
            PhoneNumber = phone,
            Notes       = notes,
            Status      = DemoRequestStatus.Pending
        };
        _context.DemoRequests.Add(entity);
        await _context.SaveChangesAsync(cancellationToken);

        return Result<Guid>.Success(entity.Id);
    }
}
