using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.DemoRequests.Queries.GetAllDemoRequests;

namespace TilmezBus.Web.Models;

public class DemoRequestsPageViewModel : SuperAdminPageViewModel
{
    public int    CurrentPage  { get; set; }
    public string? StatusFilter { get; set; }
    public PagedResult<DemoRequestDto> Data { get; set; } = PagedResult<DemoRequestDto>.Create(Array.Empty<DemoRequestDto>(), 0, 1, 20);
}
