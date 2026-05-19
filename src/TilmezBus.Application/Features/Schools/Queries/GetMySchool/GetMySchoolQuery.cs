using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Schools.Queries.GetAllSchools;

namespace TilmezBus.Application.Features.Schools.Queries.GetMySchool;

public record GetMySchoolQuery(string AdminEmail) : IRequest<Result<SchoolDto>>;
