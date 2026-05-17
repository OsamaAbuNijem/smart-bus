using MediatR;

namespace SmartBus.Application.Features.Schools.Queries.GetMyFleetSchool;

/// <summary>
/// Resolves the school for a driver / assistant identity. The mobile OTP
/// flow issues tokens whose <c>NameIdentifier</c> is the AspNetUsers id,
/// which is linked to a <c>Driver</c> or <c>Assistant</c> row via UserId.
/// Returns null when neither table carries a row for the given user.
/// Cheaper than <see cref="SmartBus.Application.Features.Schools.Queries.GetMySchool.GetMySchoolQuery"/>
/// for non-admin callers since admin lookup by AdminEmail will fail anyway.
/// </summary>
public record GetMyFleetSchoolQuery(string UserId) : IRequest<Guid?>;
