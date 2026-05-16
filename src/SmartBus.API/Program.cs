using Asp.Versioning;
using Hangfire;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.OpenApi.Models;
using Serilog;
using SmartBus.API.HealthChecks;
using SmartBus.API.Hubs;
using SmartBus.API.Middleware;
using SmartBus.Application;
using SmartBus.Infrastructure;
using SmartBus.Infrastructure.Jobs;
using SmartBus.Infrastructure.Persistence;
using StackExchange.Redis;
using System.Threading.RateLimiting;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    // Serilog
    builder.Host.UseSerilog((context, services, config) => config
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Console()
        .WriteTo.Seq(context.Configuration["Seq:ServerUrl"] ?? "http://localhost:5341"));

    // Application & Infrastructure
    builder.Services.AddApplication();
    builder.Services.AddInfrastructure(builder.Configuration);

    // Register SignalR notification service (needs BusTrackingHub from this layer)
    builder.Services.AddScoped<SmartBus.Application.Common.Interfaces.ISignalRNotificationService,
        SmartBus.API.Services.SignalRNotificationService>();
    builder.Services.AddScoped<SmartBus.Application.Common.Interfaces.ICurrentUserService,
        SmartBus.API.Services.CurrentUserService>();
    builder.Services.AddHttpContextAccessor();

    // Localization (reads Accept-Language from proxy)
    builder.Services.AddLocalization(o => o.ResourcesPath = "Resources");

    // Controllers
    builder.Services.AddControllers()
        .AddJsonOptions(opts =>
            opts.JsonSerializerOptions.Converters.Add(
                new System.Text.Json.Serialization.JsonStringEnumConverter()));

    // API Versioning
    builder.Services.AddApiVersioning(options =>
    {
        options.DefaultApiVersion = new ApiVersion(1, 0);
        options.AssumeDefaultVersionWhenUnspecified = true;
        options.ReportApiVersions = true;
        options.ApiVersionReader = ApiVersionReader.Combine(
            new UrlSegmentApiVersionReader(),
            new HeaderApiVersionReader("X-API-Version"));
    })
    .AddApiExplorer(options =>
    {
        options.GroupNameFormat = "'v'VVV";
        options.SubstituteApiVersionInUrl = true;
    });

    // Swagger
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new OpenApiInfo
        {
            Title = "SmartBus API",
            Version = "v1",
            Description = "School Bus Tracker API — Real-time GPS tracking with SignalR"
        });

        c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
        {
            Description = "Paste your JWT token here (without 'Bearer ' prefix)",
            Name = "Authorization",
            In = ParameterLocation.Header,
            Type = SecuritySchemeType.Http,
            Scheme = "bearer",
            BearerFormat = "JWT"
        });

        c.AddSecurityRequirement(new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } },
                Array.Empty<string>()
            }
        });

        c.OperationFilter<SmartBus.API.Extensions.AcceptLanguageOperationFilter>();
    });

    // SignalR — Redis backplane if present so broadcasts reach clients across API instances.
    var redisConnection = builder.Configuration.GetConnectionString("Redis");
    var signalR = builder.Services.AddSignalR();
    if (!string.IsNullOrEmpty(redisConnection))
        signalR.AddStackExchangeRedis(redisConnection, options => options.Configuration.ChannelPrefix = RedisChannel.Literal("smartbus"));

    // Health checks: quick SQL ping + Redis ping, exposed at /health.
    builder.Services.AddHealthChecks()
        .AddDbContextCheck<ApplicationDbContext>("sql")
        .AddCheck<RedisHealthCheck>("redis");

    // Rate limiting: 60 req/min per IP (global), plus a stricter 10 req/min "auth"
    // bucket for login / OTP endpoints to slow credential-stuffing.
    builder.Services.AddRateLimiter(o =>
    {
        o.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
        o.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(ctx =>
        {
            // SignalR negotiates and (especially) long-polling fire many requests per
            // second per client. Excluding /hubs prevents the global 60/min cap from
            // tearing down live connections in a reconnect loop.
            // Bus location ingestion is also high-frequency by design — a moving bus
            // posts every 1–2s — so exclude it too. AuthN/AuthZ still gate it.
            var path = ctx.Request.Path;
            if (path.StartsWithSegments("/hubs") ||
                path.StartsWithSegments("/health") ||
                (ctx.Request.Method == HttpMethods.Post &&
                 path.Value != null &&
                 path.Value.Contains("/buses/", StringComparison.OrdinalIgnoreCase) &&
                 path.Value.EndsWith("/location", StringComparison.OrdinalIgnoreCase)))
            {
                return RateLimitPartition.GetNoLimiter<string>("unlimited");
            }

            return RateLimitPartition.GetFixedWindowLimiter(
                partitionKey: ctx.Connection.RemoteIpAddress?.ToString() ?? "unknown",
                factory: _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = 60,
                    Window = TimeSpan.FromMinutes(1),
                    QueueLimit = 0
                });
        });
        o.AddPolicy("auth", ctx => RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: ctx.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 10,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0
            }));
    });

    // CORS
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("SmartBusPolicy", policy =>
            policy.WithOrigins(builder.Configuration.GetSection("AllowedOrigins").Get<string[]>() ?? ["http://localhost:5000", "http://localhost:7000"])
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials());
    });

    var app = builder.Build();

    // Seed database
    using (var scope = app.Services.CreateScope())
        await SmartBus.Infrastructure.Persistence.DbSeeder.SeedAsync(scope.ServiceProvider);

    app.UseMiddleware<ExceptionHandlingMiddleware>();
    app.UseMiddleware<RequestResponseLoggingMiddleware>();
    app.UseSerilogRequestLogging();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "SmartBus API v1");
            c.RoutePrefix = string.Empty;
        });
    }

    if (!app.Environment.IsDevelopment())
        app.UseHttpsRedirection();

    app.UseCors("SmartBusPolicy");

    // Honour Accept-Language header forwarded by the Web proxy
    var apiCultures = new[] { "ar", "en" };
    var apiLocOpts  = new RequestLocalizationOptions()
        .SetDefaultCulture("ar")
        .AddSupportedCultures(apiCultures)
        .AddSupportedUICultures(apiCultures);
    apiLocOpts.RequestCultureProviders.Clear();
    apiLocOpts.RequestCultureProviders.Add(new AcceptLanguageHeaderRequestCultureProvider());
    app.UseRequestLocalization(apiLocOpts);

    app.UseAuthentication();
    app.UseAuthorization();
    app.UseRateLimiter();

    // Stamp ApplicationUser.LastSeenAt on each authenticated request (throttled).
    // Powers the SuperAdmin dashboard's "currently active users" counter.
    app.UseMiddleware<SmartBus.API.Middleware.LastSeenTrackingMiddleware>();

    // Hangfire Dashboard (admin only in production)
    app.UseHangfireDashboard("/hangfire", new DashboardOptions
    {
        Authorization = []
    });

    app.MapHealthChecks("/health");
    app.MapControllers();
    app.MapHub<BusTrackingHub>("/hubs/bus-tracking");

    // Register recurring Hangfire jobs
    RecurringJob.AddOrUpdate<BusTrackingCleanupJob>(
        "cleanup-old-locations",
        job => job.CleanOldLocationsAsync(),
        Cron.Daily);

    RecurringJob.AddOrUpdate<BusTrackingCleanupJob>(
        "update-inactive-buses",
        job => job.UpdateInactiveBusStatusAsync(),
        Cron.Minutely);

    // Trips are now created on-demand when the driver/assistant scans a bus
    // QR via POST /api/v1/trips/scan — no recurring trip-generation job.
    // Drop the previously-registered "generate-daily-trips" recurring entry
    // so it stops firing on existing Hangfire DBs.
    RecurringJob.RemoveIfExists("generate-daily-trips");

    await app.RunAsync();
}
catch (Exception ex)
{
    Log.Fatal(ex, "SmartBus API terminated unexpectedly");
}
finally
{
    await Log.CloseAndFlushAsync();
}
