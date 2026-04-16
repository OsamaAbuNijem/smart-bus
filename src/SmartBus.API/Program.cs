using Asp.Versioning;
using Hangfire;
using Microsoft.OpenApi.Models;
using Serilog;
using SmartBus.API.Hubs;
using SmartBus.API.Middleware;
using SmartBus.Application;
using SmartBus.Infrastructure;
using SmartBus.Infrastructure.Jobs;

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

    // Controllers
    builder.Services.AddControllers();

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
            Description = "JWT Authorization. Enter: Bearer {token}",
            Name = "Authorization",
            In = ParameterLocation.Header,
            Type = SecuritySchemeType.ApiKey,
            Scheme = "Bearer"
        });

        c.AddSecurityRequirement(new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } },
                Array.Empty<string>()
            }
        });
    });

    // SignalR
    builder.Services.AddSignalR();

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

    app.UseMiddleware<ExceptionHandlingMiddleware>();
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

    app.UseHttpsRedirection();
    app.UseCors("SmartBusPolicy");
    app.UseAuthentication();
    app.UseAuthorization();

    // Hangfire Dashboard (admin only in production)
    app.UseHangfireDashboard("/hangfire", new DashboardOptions
    {
        Authorization = []
    });

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
