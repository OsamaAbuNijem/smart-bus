using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;
using SmartBus.Infrastructure.Identity;

namespace SmartBus.Infrastructure.Persistence;

public static class DbSeeder
{
    public static async Task SeedAsync(IServiceProvider services)
    {
        var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
        var db          = services.GetRequiredService<ApplicationDbContext>();

        // Apply any pending migrations automatically
        await db.Database.MigrateAsync();

        // ── Roles ──────────────────────────────────────────────────────────
        string[] roles = ["SuperAdmin", "Admin", "Driver", "Parent", "Assistant"];
        foreach (var role in roles)
            if (!await roleManager.RoleExistsAsync(role))
                await roleManager.CreateAsync(new IdentityRole(role));

        // ── Default Admin ──────────────────────────────────────────────────
        const string adminEmail    = "admin@smartbus.com";
        const string adminPassword = "Admin@123456";

        if (await userManager.FindByEmailAsync(adminEmail) is null)
        {
            var admin = new ApplicationUser
            {
                UserName       = adminEmail,
                Email          = adminEmail,
                FullName       = "SmartBus Admin",
                EmailConfirmed = true
            };

            var result = await userManager.CreateAsync(admin, adminPassword);
            if (result.Succeeded)
                await userManager.AddToRoleAsync(admin, "Admin");
        }

        // ── Seed School row for the default admin (if not already present) ─
        bool schoolExists = await db.Schools
            .IgnoreQueryFilters()
            .AnyAsync(s => s.AdminEmail == adminEmail);

        if (!schoolExists)
        {
            db.Schools.Add(new School
            {
                Name         = "SmartBus Demo School",
                City         = "الرياض",
                ContactEmail = adminEmail,
                PhoneNumber  = "0112345678",
                AdminEmail   = adminEmail
            });
            await db.SaveChangesAsync();
        }

        // Ensure the demo school has an active subscription. Without this the
        // admin panel won't surface any students — student lookups are scoped
        // to the active subscription window. The subscription is the source
        // of truth for MaxStudents / MaxBuses now that those caps no longer
        // live on the School entity.
        var demoSchool = await db.Schools
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(s => s.AdminEmail == adminEmail);
        if (demoSchool is not null)
        {
            var hasSub = await db.Subscriptions
                .IgnoreQueryFilters()
                .AnyAsync(s => s.SchoolId == demoSchool.Id);
            if (!hasSub)
            {
                db.Subscriptions.Add(new Subscription
                {
                    SchoolId         = demoSchool.Id,
                    MaxStudents      = 500,
                    MaxBuses         = 20,
                    ActivationDate   = DateTime.UtcNow,
                    ExpirationDate   = DateTime.UtcNow.AddYears(1),
                    IsActive         = true,
                    Price            = 0m,
                    IsPaid           = false,
                    RemainingAmount  = 0m,
                    SubscriptionType = SubscriptionType.Trial
                });
                await db.SaveChangesAsync();
            }
        }

        // ── Super Admin ────────────────────────────────────────────────────
        const string superAdminEmail    = "superadmin@smartbus.com";
        const string superAdminPassword = "SuperAdmin@123456";

        if (await userManager.FindByEmailAsync(superAdminEmail) is null)
        {
            var superAdmin = new ApplicationUser
            {
                UserName       = superAdminEmail,
                Email          = superAdminEmail,
                FullName       = "SmartBus Super Admin",
                EmailConfirmed = true
            };

            var result = await userManager.CreateAsync(superAdmin, superAdminPassword);
            if (result.Succeeded)
                await userManager.AddToRoleAsync(superAdmin, "SuperAdmin");
        }
    }
}
