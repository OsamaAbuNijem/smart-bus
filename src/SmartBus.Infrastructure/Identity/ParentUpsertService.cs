using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;
using SmartBus.Infrastructure.Persistence;

namespace SmartBus.Infrastructure.Identity;

public class ParentUpsertService : IParentUpsertService
{
    private readonly ApplicationDbContext _context;
    private readonly UserManager<ApplicationUser> _userManager;

    public ParentUpsertService(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
    {
        _context     = context;
        _userManager = userManager;
    }

    public async Task<Guid> UpsertAsync(string fullName, string phoneNumber, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(phoneNumber))
            throw new ArgumentException("Phone number is required.", nameof(phoneNumber));

        var phone = phoneNumber.Trim();

        var parent = await _context.Parents
            .FirstOrDefaultAsync(p => !p.IsDeleted && p.PhoneNumber == phone, cancellationToken);

        if (parent is null)
        {
            parent = new Parent
            {
                FullName    = fullName,
                PhoneNumber = phone
            };
            _context.Parents.Add(parent);
            await _context.SaveChangesAsync(cancellationToken); // assign Id
        }
        else
        {
            // Keep parent name in sync with latest admin input.
            parent.FullName = fullName;
        }

        // Ensure an Identity user exists for this parent.
        if (string.IsNullOrEmpty(parent.UserId))
        {
            var email = PhoneToEmail(phone);
            var user  = await _userManager.FindByEmailAsync(email);

            if (user is null)
            {
                user = new ApplicationUser
                {
                    UserName       = email,
                    Email          = email,
                    FullName       = fullName,
                    EmailConfirmed = true
                };
                var password = DefaultPasswordFor(phone);
                var result   = await _userManager.CreateAsync(user, password);
                if (!result.Succeeded)
                    throw new InvalidOperationException(
                        $"Failed to create parent user: {string.Join("; ", result.Errors.Select(e => e.Description))}");

                await _userManager.AddToRoleAsync(user, "Parent");
            }

            parent.UserId = user.Id;
            await _context.SaveChangesAsync(cancellationToken);
        }

        return parent.Id;
    }

    // Matches the synthetic-email pattern used by the OTP flow so the same
    // parent account works for both admin-created and OTP-authenticated sign-ins.
    private static string PhoneToEmail(string phone)
    {
        var digits = new string(phone.Where(char.IsDigit).ToArray());
        return $"mob_{digits}@smartbus.local";
    }

    // Default Identity policy also requires lowercase + non-alphanumeric. "Parent@{phone}!"
    // covers: uppercase P, lowercase arent, digit from phone, @ and ! specials, length ≥ 8.
    // Matches the synthetic pattern used by the OTP flow.
    private static string DefaultPasswordFor(string phone) => $"Parent@{phone}!";
}
