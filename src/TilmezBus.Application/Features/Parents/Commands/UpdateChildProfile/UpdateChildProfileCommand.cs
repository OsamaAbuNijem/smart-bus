using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Parents.Commands.UpdateChildProfile;

/// <summary>
/// Parent-scoped update of one of their children's editable fields, plus
/// the parent's own name + phone. Used by the mobile Edit Student screen.
/// </summary>
public record UpdateChildProfileCommand(
    Guid ParentId,
    Guid StudentId,
    string FullName,
    string Grade,
    string? Class,
    string? Notes,
    string ParentName,
    string ParentPhone
) : IRequest<Result>;
