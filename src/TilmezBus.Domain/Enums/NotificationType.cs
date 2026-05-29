namespace TilmezBus.Domain.Enums;

public enum NotificationType
{
    TripStarted = 0,
    TripCompleted = 1,
    BusArriving = 2,
    BusArrived = 3,
    SystemAlert = 4,
    StudentBoarded = 5,
    StudentArrived = 6,
    AbsenceConfirmed = 7,
    DriverMessage = 8,
    SchoolNotice = 9,
    StudentArrivedAtSchool = 10,
    /// <summary>Push fired to each parent on the trip's roster the
    /// moment the trip flips to InProgress — separate from the driver-
    /// facing <see cref="TripStarted"/> copy so we can keep that one
    /// imperative ("open the route map") and this one informational
    /// ("the bus is now live, follow it from the app").</summary>
    ParentTripStarted = 11,
}
