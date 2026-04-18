using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Schools.Queries.GetAllSchools;

namespace SmartBus.Application.Features.Schools.Queries.GetMySchool;

public record GetMySchoolQuery(string AdminEmail) : IRequest<Result<SchoolDto>>;
