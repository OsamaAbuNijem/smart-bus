namespace SmartBus.Domain.Entities;

/// <summary>
/// Join row linking a Student to the Subscription period under which the
/// student is part of the school's active roster. A student can have
/// multiple rows over time (one per subscription period); the Students
/// table itself is never duplicated.
/// </summary>
public class SubscriptionStudent
{
    public Guid SubscriptionId { get; set; }
    public Subscription? Subscription { get; set; }

    public Guid StudentId { get; set; }
    public Student? Student { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
