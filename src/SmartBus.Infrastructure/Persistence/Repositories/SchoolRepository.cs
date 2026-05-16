using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class SchoolRepository : GenericRepository<School>, ISchoolRepository
{
    public SchoolRepository(ApplicationDbContext context) : base(context) { }
}
