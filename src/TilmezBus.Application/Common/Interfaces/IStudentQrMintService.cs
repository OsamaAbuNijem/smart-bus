namespace TilmezBus.Application.Common.Interfaces;

/// <summary>
/// Mints a <c>StudentQrToken</c> row already linked + registered to a
/// freshly-created student. Called by the create-student paths (single
/// API + bulk Excel import) so every student that lands in the system
/// has a QR code from day one — used both for the public lost-and-found
/// page and for in-app pickup attendance.
/// </summary>
public interface IStudentQrMintService
{
    /// <summary>Generate and persist a registered token for [studentId].
    /// Returns the raw token string (32-char hex) that gets encoded into
    /// the printed QR.</summary>
    Task<string> MintForStudentAsync(Guid studentId, Guid schoolId, CancellationToken ct = default);
}
