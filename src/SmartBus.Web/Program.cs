using Microsoft.AspNetCore.Localization;
using Serilog;
using SmartBus.Web.Services;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    builder.Host.UseSerilog((context, services, config) => config
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Console()
        .WriteTo.Seq(context.Configuration["Seq:ServerUrl"] ?? "http://localhost:5341"));

    // Serve static files from the source wwwroot in all environments
    // (by default UseStaticWebAssets only runs in Development; this makes it work under IIS Production too)
    builder.WebHost.UseStaticWebAssets();

    builder.Services.AddLocalization(o => o.ResourcesPath = "Resources");
    builder.Services.AddControllersWithViews()
        .AddViewLocalization()
        .AddDataAnnotationsLocalization();
    builder.Services.AddHttpContextAccessor();
    builder.Services.AddSession(options =>
    {
        options.IdleTimeout = TimeSpan.FromHours(8);
        options.Cookie.HttpOnly = true;
        options.Cookie.IsEssential = true;
    });

    builder.Services.AddHttpClient<IApiClient, ApiClient>(client =>
    {
        client.BaseAddress = new Uri(builder.Configuration["ApiBaseUrl"] ?? "https://localhost:7100/");
    });

    builder.Services.AddHttpClient("ApiProxy", client =>
    {
        client.Timeout = TimeSpan.FromSeconds(30);
    }).ConfigurePrimaryHttpMessageHandler(() => new HttpClientHandler
    {
        ServerCertificateCustomValidationCallback = HttpClientHandler.DangerousAcceptAnyServerCertificateValidator
    });

    var app = builder.Build();

    if (!app.Environment.IsDevelopment())
    {
        app.UseExceptionHandler("/Home/Error");
        app.UseHsts();
        app.UseHttpsRedirection();
    }
    app.UseStaticFiles();
    app.UseSerilogRequestLogging();
    app.UseRouting();

    var webCultures = new[] { "ar", "en" };
    var webLocOpts  = new RequestLocalizationOptions()
        .SetDefaultCulture("ar")
        .AddSupportedCultures(webCultures)
        .AddSupportedUICultures(webCultures);
    webLocOpts.RequestCultureProviders.Insert(
        0, new CookieRequestCultureProvider());
    app.UseRequestLocalization(webLocOpts);

    app.UseSession();
    app.UseAuthentication();
    app.UseAuthorization();

    app.MapControllerRoute(
        name: "default",
        pattern: "{controller=Account}/{action=Login}/{id?}");

    // Redirect /hangfire (and any sub-paths) to the API project's Hangfire dashboard
    app.MapGet("/hangfire", (IConfiguration cfg) =>
    {
        var apiBase = cfg["ApiBaseUrl"]?.TrimEnd('/') ?? "http://localhost:8083";
        return Results.Redirect($"{apiBase}/hangfire", permanent: false);
    });
    app.MapGet("/hangfire/{**path}", (string path, IConfiguration cfg) =>
    {
        var apiBase = cfg["ApiBaseUrl"]?.TrimEnd('/') ?? "http://localhost:8083";
        return Results.Redirect($"{apiBase}/hangfire/{path}", permanent: false);
    });

    await app.RunAsync();
}
catch (Exception ex)
{
    Log.Fatal(ex, "SmartBus Web terminated unexpectedly");
}
finally
{
    await Log.CloseAndFlushAsync();
}
