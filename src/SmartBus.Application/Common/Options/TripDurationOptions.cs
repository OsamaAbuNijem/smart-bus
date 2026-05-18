namespace SmartBus.Application.Common.Options;

/// <summary>
/// Expected duration (in minutes) for an in-progress trip to complete,
/// per trip type. Used by the live dashboard to project an ExpectedEnd
/// timestamp from each running trip's ActualDeparture.
///
/// Bind from configuration section "TripDuration":
///   "TripDuration": { "MorningMinutes": 45, "ReturnMinutes": 60 }
/// </summary>
public class TripDurationOptions
{
    public const string SectionName = "TripDuration";

    /// <summary>Morning trip (home → school) typical duration in minutes.</summary>
    public int MorningMinutes { get; set; } = 45;

    /// <summary>Return trip (school → home) typical duration in minutes.</summary>
    public int ReturnMinutes { get; set; } = 60;
}
