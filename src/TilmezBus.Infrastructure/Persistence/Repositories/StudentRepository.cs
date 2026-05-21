using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Infrastructure.Persistence.Repositories;

public class StudentRepository : GenericRepository<Student>, IStudentRepository
{
    public StudentRepository(ApplicationDbContext context) : base(context) { }
}
