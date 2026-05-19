using Microsoft.AspNetCore.Http;
using System.Globalization;
using System.Text.Json;
using TilmezBus.Application.Features.Schools.Queries.GetAllSchools;
using TilmezBus.Web.Models;

namespace TilmezBus.Web.Services;

/// <summary>
/// Small helper that mirrors the admin's school snapshot
/// (name + city + most-recent subscription) into the HTTP session so the
/// sidebar plan card and topbar can render without an extra
/// /schools/current roundtrip on every page.
///
/// The login flow stashes once on sign-in; <c>AdminControllerBase.PopulateAsync</c>
/// re-fetches on cache miss (handles older sessions issued before the snapshot
/// was added).
/// </summary>
public static class AdminSessionCache
{
    private const string KeyName            = "SchoolName";
    private const string KeyCity            = "SchoolCity";
    private const string KeySubscription    = "SchoolSub";

    /// <summary>Writes the school snapshot to session. Safe with a null school.</summary>
    public static void StashSchoolInSession(ISession session, SchoolDto? school)
    {
        session.SetString(KeyName, school?.Name ?? string.Empty);
        session.SetString(KeyCity, school?.City ?? string.Empty);

        var sub = new SessionSubscription(
            school?.LastSubscriptionActivationDate,
            school?.LastSubscriptionExpirationDate,
            school?.LastSubscriptionType,
            school?.LastSubscriptionIsActive,
            school?.LastSubscriptionMaxStudents,
            school?.LastSubscriptionMaxBuses,
            school?.LastSubscriptionPrice);
        session.SetString(KeySubscription, JsonSerializer.Serialize(sub));
    }

    /// <summary>Reads the cached subscription snapshot. Null when not yet stashed.</summary>
    public static SessionSubscription? ReadSubscription(ISession session)
    {
        var raw = session.GetString(KeySubscription);
        if (string.IsNullOrEmpty(raw)) return null;
        try { return JsonSerializer.Deserialize<SessionSubscription>(raw); }
        catch { return null; }
    }

    /// <summary>Hydrates the subscription fields on any admin view model.</summary>
    public static void ApplySubscription(AdminPageViewModel vm, SessionSubscription? s)
    {
        if (s is null) return;
        vm.SubscriptionActivationDate = s.ActivationDate;
        vm.SubscriptionExpirationDate = s.ExpirationDate;
        vm.SubscriptionType           = s.Type;
        vm.SubscriptionIsActive       = s.IsActive;
        vm.SubscriptionMaxStudents    = s.MaxStudents;
        vm.SubscriptionMaxBuses       = s.MaxBuses;
        vm.SubscriptionPrice          = s.Price;
    }
}

/// <summary>
/// Session-serializable snapshot of the school's most-recent subscription.
/// Kept separate from <c>AdminPageViewModel</c> so the wire format is stable
/// even if the view model grows new fields later.
/// </summary>
public record SessionSubscription(
    DateTime? ActivationDate,
    DateTime? ExpirationDate,
    TilmezBus.Domain.Enums.SubscriptionType? Type,
    bool?     IsActive,
    int?      MaxStudents,
    int?      MaxBuses,
    decimal?  Price);
