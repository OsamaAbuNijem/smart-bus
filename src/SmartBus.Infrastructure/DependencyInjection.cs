using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Hangfire;
using Hangfire.PostgreSql;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Infrastructure.Identity;
using SmartBus.Infrastructure.Jobs;
using SmartBus.Infrastructure.Notifications;
using SmartBus.Infrastructure.Persistence;
using SmartBus.Infrastructure.Services;
using StackExchange.Redis;
using System.Text;

namespace SmartBus.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        // Database
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection"),
                b => b.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)));

        services.AddScoped<IApplicationDbContext>(sp => sp.GetRequiredService<ApplicationDbContext>());
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        // Identity
        services.AddIdentity<ApplicationUser, IdentityRole>(options =>
        {
            options.Password.RequiredLength = 8;
            options.Password.RequireDigit = true;
            options.Password.RequireUppercase = true;
            options.User.RequireUniqueEmail = true;
        })
        .AddEntityFrameworkStores<ApplicationDbContext>()
        .AddDefaultTokenProviders();

        services.AddScoped<IUserStore, UserStoreService>();
        services.AddScoped<IParentUpsertService, ParentUpsertService>();
        services.AddScoped<IActiveSubscriptionService, Subscriptions.ActiveSubscriptionService>();

        // JWT
        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddJwtBearer(options =>
        {
            options.RequireHttpsMetadata = false;
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = configuration["Jwt:Issuer"],
                ValidAudience = configuration["Jwt:Audience"],
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]!)),
                ClockSkew = TimeSpan.FromMinutes(5)
            };

            options.Events = new JwtBearerEvents
            {
                OnMessageReceived = context =>
                {
                    var accessToken = context.Request.Query["access_token"];
                    var path = context.HttpContext.Request.Path;
                    if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                        context.Token = accessToken;
                    return Task.CompletedTask;
                },
                OnAuthenticationFailed = context =>
                {
                    Console.WriteLine($"[JWT] Authentication failed: {context.Exception.GetType().Name}: {context.Exception.Message}");
                    return Task.CompletedTask;
                },
                OnChallenge = context =>
                {
                    Console.WriteLine($"[JWT] Challenge: {context.Error} - {context.ErrorDescription}");
                    return Task.CompletedTask;
                }
            };
        });

        services.AddScoped<IJwtService, JwtService>();
        services.AddScoped<IOtpSender, DevOtpSender>();

        // Redis
        var redisConnection = configuration.GetConnectionString("Redis") ?? "localhost:6379";
        services.AddSingleton<IConnectionMultiplexer>(ConnectionMultiplexer.Connect(redisConnection));
        services.AddScoped<ICacheService, CacheService>();

        // Hangfire
        services.AddHangfire(config => config
            .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
            .UseSimpleAssemblyNameTypeSerializer()
            .UseRecommendedSerializerSettings()
            .UsePostgreSqlStorage(c =>
                c.UseNpgsqlConnection(configuration.GetConnectionString("DefaultConnection")),
                new PostgreSqlStorageOptions
                {
                    QueuePollInterval = TimeSpan.FromSeconds(15),
                    InvisibilityTimeout = TimeSpan.FromMinutes(5),
                    DistributedLockTimeout = TimeSpan.FromMinutes(1),
                    PrepareSchemaIfNecessary = true
                }));

        // Cap worker count so background jobs can't starve live request threads.
        // Default is Math.Min(Environment.ProcessorCount * 5, 20); here we pin it low
        // because this API also serves user traffic. Bump if jobs back up.
        services.AddHangfireServer(opts =>
        {
            opts.WorkerCount              = 4;
            opts.Queues                   = new[] { "default" };
            opts.SchedulePollingInterval  = TimeSpan.FromSeconds(15);
            opts.ServerTimeout            = TimeSpan.FromMinutes(5);
        });
        services.AddScoped<BusTrackingCleanupJob>();

        // Firebase Cloud Messaging — initialize once with the service-account
        // JSON whose path is in Firebase:CredentialsPath. App still boots if
        // the file is missing; pushes will just fail gracefully at send time.
        var fcmCredsPath = configuration["Firebase:CredentialsPath"];
        if (!string.IsNullOrWhiteSpace(fcmCredsPath) && File.Exists(fcmCredsPath))
        {
            if (FirebaseApp.DefaultInstance == null)
            {
                FirebaseApp.Create(new AppOptions
                {
                    Credential = GoogleCredential.FromFile(fcmCredsPath),
                });
            }
        }
        services.AddScoped<IPushNotificationService, FcmPushNotificationService>();
        services.AddScoped<INotificationTemplateService, NotificationTemplateService>();

        // Note: ISignalRNotificationService is registered in the API layer (needs Hub type)

        return services;
    }
}
