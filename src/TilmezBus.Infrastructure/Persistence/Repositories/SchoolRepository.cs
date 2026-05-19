using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Infrastructure.Persistence.Repositories;

public class SchoolRepository : GenericRepository<School>, ISchoolRepository
{
    public SchoolRepository(ApplicationDbContext context) : base(context) { }
}
