using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Students.Queries.GetAllStudents;

namespace TilmezBus.Application.Features.Parents.Queries.GetParentById;

public record GetParentByIdQuery(Guid ParentId) : IRequest<Result<ParentDetailDto>>;

public record ParentDetailDto(
    Guid Id, string FullName, string PhoneNumber,
    IReadOnlyList<StudentDto> Children,
    DateTime CreatedAt
);
