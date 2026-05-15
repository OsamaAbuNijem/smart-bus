using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Schools.Commands.CreateSchool;

public record CreateSchoolCommand(
    string Name,
    string City,
    string ContactEmail,
    string PhoneNumber,
    string AdminEmail,
    string? Notes,
    // Initial subscription — created atomically with the school so the
    // admin panel has something to attach students to from day one.
    // The subscription is the source of truth for MaxStudents / MaxBuses;
    // the School entity no longer carries those caps.
    DateTime SubscriptionActivationDate,
    DateTime SubscriptionExpirationDate,
    SubscriptionType SubscriptionType,
    decimal SubscriptionPrice,
    bool SubscriptionIsPaid,
    decimal SubscriptionRemainingAmount,
    int SubscriptionMaxStudents = 500,
    int SubscriptionMaxBuses    = 20,
    double? Latitude = null,
    double? Longitude = null,
    string AdminPassword = "Admin@123456"
) : IRequest<Result<Guid>>;
