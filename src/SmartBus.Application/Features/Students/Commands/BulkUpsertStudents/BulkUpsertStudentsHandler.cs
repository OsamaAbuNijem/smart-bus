using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Students.Commands.BulkUpsertStudents;

public class BulkUpsertStudentsHandler
    : IRequestHandler<BulkUpsertStudentsCommand, Result<BulkUpsertStudentsResult>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly IParentUpsertService _parentUpsert;

    public BulkUpsertStudentsHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        IParentUpsertService parentUpsert)
    {
        _unitOfWork   = unitOfWork;
        _context      = context;
        _parentUpsert = parentUpsert;
    }

    public async Task<Result<BulkUpsertStudentsResult>> Handle(
        BulkUpsertStudentsCommand request,
        CancellationToken cancellationToken)
    {
        var rows = request.Rows ?? Array.Empty<BulkUpsertStudentRow>();
        var errors = new List<string>();
        int created = 0, updated = 0, failed = 0;

        if (rows.Count == 0)
            return Result<BulkUpsertStudentsResult>.Success(
                new BulkUpsertStudentsResult(0, 0, 0, errors));

        // 1. Upsert parents — once per distinct phone, not per row. The Identity
        //    work (find-or-create user) still hits the DB per unique phone, but
        //    that's the floor: parents must exist before student rows reference them.
        var distinctParents = rows
            .Where(r => !string.IsNullOrWhiteSpace(r.ParentPhone))
            .GroupBy(r => r.ParentPhone.Trim(), StringComparer.OrdinalIgnoreCase)
            .Select(g => (Phone: g.Key, Name: g.First().ParentName ?? string.Empty))
            .ToList();

        var parentByPhone = new Dictionary<string, Guid>(StringComparer.OrdinalIgnoreCase);
        foreach (var p in distinctParents)
        {
            try
            {
                parentByPhone[p.Phone] = await _parentUpsert.UpsertAsync(p.Name, p.Phone, cancellationToken);
            }
            catch (Exception ex)
            {
                errors.Add($"Parent '{p.Phone}': {ex.Message}");
            }
        }

        // 2. Load any existing students for this school whose NationalNumber appears
        //    in the import. One DB roundtrip regardless of row count.
        var nationals = rows
            .Select(r => r.NationalNumber)
            .Where(n => !string.IsNullOrWhiteSpace(n))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        var existingByNational = await _context.Students
            .Where(s => !s.IsDeleted
                     && s.SchoolId == request.SchoolId
                     && nationals.Contains(s.NationalNumber))
            .ToDictionaryAsync(s => s.NationalNumber, s => s, StringComparer.OrdinalIgnoreCase, cancellationToken);

        // 3. Apply each row in memory. Validation mirrors the Web importer.
        foreach (var row in rows)
        {
            if (string.IsNullOrWhiteSpace(row.FullName)
             || string.IsNullOrWhiteSpace(row.Grade)
             || string.IsNullOrWhiteSpace(row.NationalNumber)
             || string.IsNullOrWhiteSpace(row.ParentName)
             || string.IsNullOrWhiteSpace(row.ParentPhone))
            {
                failed++;
                continue;
            }

            if (!parentByPhone.TryGetValue(row.ParentPhone.Trim(), out var parentId))
            {
                failed++;
                continue;
            }

            if (existingByNational.TryGetValue(row.NationalNumber, out var existing))
            {
                // Update only the columns carried by the import sheet. Address/GPS
                // are intentionally preserved on the existing row.
                existing.FullName   = row.FullName;
                existing.FullNameEn = row.FullNameEn;
                existing.Grade      = row.Grade;
                existing.ParentId   = parentId;
                updated++;
            }
            else
            {
                var student = new Student
                {
                    SchoolId       = request.SchoolId,
                    FullName       = row.FullName,
                    FullNameEn     = row.FullNameEn,
                    NationalNumber = row.NationalNumber,
                    Grade          = row.Grade,
                    ParentId       = parentId
                };
                _context.Students.Add(student);
                // Keep the dict updated so two rows in the same batch with the
                // same NationalNumber are treated as create-then-update, not
                // create-twice (which would violate the unique index).
                existingByNational[row.NationalNumber] = student;
                created++;
            }
        }

        // 4. Single SaveChanges for every student write in the batch.
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<BulkUpsertStudentsResult>.Success(
            new BulkUpsertStudentsResult(created, updated, failed, errors));
    }
}
