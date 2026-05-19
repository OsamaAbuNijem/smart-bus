namespace TilmezBus.Application.Common.Interfaces;

/// <summary>
/// Resolves or creates a Parent row for a given phone number, and ensures
/// an Identity user exists with role "Parent" linked via <c>Parent.UserId</c>.
/// Called from student create/update handlers.
/// </summary>
public interface IParentUpsertService
{
    /// <returns>Id of the Parent row (existing or newly created).</returns>
    Task<Guid> UpsertAsync(string fullName, string phoneNumber, CancellationToken cancellationToken = default);
}
