using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Localization;
using Serilog;
using TilmezBus.Web.Services;

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

    builder.Services.AddLocalization();
    builder.Services.AddControllersWithViews(options =>
        {
            // Always parse double/double? form values using InvariantCulture —
            // the request culture (ar/en) shouldn't affect lat/lng parsing.
            options.ModelBinderProviders.Insert(0, new TilmezBus.Web.Infrastructure.InvariantDoubleBinderProvider());
        })
        .AddViewLocalization()
        .AddDataAnnotationsLocalization(options =>
        {
            options.DataAnnotationLocalizerProvider = (type, factory) =>
                factory.Create(typeof(TilmezBus.Web.Resources.SharedResources));
        });

    // Feature-folder support: look in Features/{Controller}/ for views.
    builder.Services.Configure<Microsoft.AspNetCore.Mvc.Razor.RazorViewEngineOptions>(o =>
        o.ViewLocationExpanders.Add(new TilmezBus.Web.Infrastructure.FeatureFolderViewLocationExpander()));
    builder.Services.AddHttpContextAccessor();

    // Persist Data Protection keys to a mounted volume so session cookies
    // survive container restarts/redeploys. Without this, every redeploy
    // generates a new key ring and old cookies throw CryptographicException
    // ("key {…} was not found in the key ring") in Session middleware.
    var keysPath = builder.Configuration["DataProtection:KeysPath"]
        ?? (builder.Environment.IsDevelopment() ? null : "/keys");
    var dp = builder.Services.AddDataProtection()
        .SetApplicationName("TilmezBus.Web");
    if (!string.IsNullOrWhiteSpace(keysPath))
    {
        Directory.CreateDirectory(keysPath);
        dp.PersistKeysToFileSystem(new DirectoryInfo(keysPath));
    }

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
    // Only honor an explicit cookie set by the language toggle. Drop the
    // built-in QueryString + Accept-Language providers so the browser's
    // OS-level preference doesn't auto-flip first-time visitors to English —
    // we want Arabic out of the box, and the toggle is the only way to opt
    // into English (the toggle writes the same cookie this provider reads).
    webLocOpts.RequestCultureProviders.Clear();
    webLocOpts.RequestCultureProviders.Add(new CookieRequestCultureProvider());
    app.UseRequestLocalization(webLocOpts);

    app.UseSession();
    app.UseAuthentication();
    app.UseAuthorization();

    // "/" → public marketing landing page (Home/Index). The page has a
    // login CTA that links to /Account/Login for school admins.
    app.MapControllerRoute(
        name: "home",
        pattern: "",
        defaults: new { controller = "Home", action = "Index" });

    // Everything else uses Index as the default action, so /Drivers works without /Index.
    app.MapControllerRoute(
        name: "default",
        pattern: "{controller}/{action=Index}/{id?}");

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
    Log.Fatal(ex, "TilmezBus Web terminated unexpectedly");
}
finally
{
    await Log.CloseAndFlushAsync();
}
