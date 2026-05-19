using Microsoft.AspNetCore.Mvc;
using TilmezBus.Web.Filters;
using TilmezBus.Web.Models;
using TilmezBus.Web.Services;

namespace TilmezBus.Web.Controllers.SuperAdmin;

/// <summary>
/// Shared base for every per-tab super-admin controller. Mirrors
/// <see cref="Admin.AdminControllerBase"/> so the patterns line up:
///   * Injects <see cref="IApiClient"/> for downstream API calls.
///   * Applies <see cref="RequireJwtAttribute"/> so each tab is auth-gated
///     by default (the per-tab Index actions don't need to repeat it).
///   * Tags responses as non-cacheable — these pages display server-rendered
///     state that changes whenever the super-admin mutates a school / sub /
///     password, and back-button-into-stale-data is worse than a tiny refetch.
/// </summary>
[RequireJwt]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public abstract class SuperAdminControllerBase : Controller
{
    protected readonly IApiClient ApiClient;

    protected SuperAdminControllerBase(IApiClient apiClient) => ApiClient = apiClient;

    /// <summary>Fills the page-chrome bits (sidebar active marker + title).</summary>
    protected SuperAdminPageViewModel Page(string activePage, string pageTitle) =>
        new() { ActivePage = activePage, PageTitle = pageTitle };
}
