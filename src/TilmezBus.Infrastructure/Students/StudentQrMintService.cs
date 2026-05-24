using System.Security.Cryptography;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Infrastructure.Students;

/// <summary>
/// Implementation of <see cref="IStudentQrMintService"/>. Generates a
/// cryptographically-random 32-char hex token, inserts a
/// <see cref="StudentQrToken"/> row in the registered state, and lets
/// the caller's UnitOfWork commit it alongside the rest of the
/// transaction. Does NOT call SaveChanges itself so create-student
/// flows stay atomic.
/// </summary>
public class StudentQrMintService : IStudentQrMintService
{
    private readonly IApplicationDbContext _context;

    public StudentQrMintService(IApplicationDbContext context) => _context = context;

    public Task<string> MintForStudentAsync(
        Guid studentId, Guid schoolId, CancellationToken ct = default)
    {
        var token = GenerateToken();
        _context.StudentQrTokens.Add(new StudentQrToken
        {
            Token         = token,
            SchoolId      = schoolId,
            StudentId     = studentId,
            IsRegistered  = true,
            RegisteredAt  = DateTime.UtcNow,
        });
        return Task.FromResult(token);
    }

    /// <summary>32-char lowercase hex string. 128 bits of entropy — same
    /// shape as the legacy printed-sticker tokens so URL formats stay
    /// stable and existing scanners keep working.</summary>
    private static string GenerateToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(16);
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }
}
