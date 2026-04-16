using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Students.Queries.GetAllStudents;

namespace SmartBus.Application.Features.Parents.Queries.GetParentById;

public record GetParentByIdQuery(Guid ParentId) : IRequest<Result<ParentDetailDto>>;

public record ParentDetailDto(
    Guid Id, string FullName, string PhoneNumber,
    IReadOnlyList<StudentDto> Children,
    DateTime CreatedAt
);
