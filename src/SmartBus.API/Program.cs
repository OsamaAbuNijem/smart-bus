using Asp.Versioning;
using Hangfire;
using Microsoft.AspNetCore.Localization;
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
