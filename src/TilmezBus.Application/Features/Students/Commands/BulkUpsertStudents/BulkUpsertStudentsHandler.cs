using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Students.Commands.BulkUpsertStudents;

public class BulkUpsertStudentsHandler
    : IRequestHandler<BulkUpsertStudentsCommand, Result<BulkUpsertStudentsResult>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly IParentUpsertService _parentUpsert;
    private readonly IActiveSubscriptionService _activeSubscription;

    public BulkUpsertStudentsHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        IParentUpsertService parentUpsert,
        IActiveSubscriptionService activeSubscription)
    {
        _unitOfWork         = unitOfWork;
        _context            = context;
        _parentUpsert       = parentUpsert;
        _activeSubscription = activeSubscription;
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

        // Resolve the school's active subscription up front. Newly-created
        // students will be linked to it; if it's missing the whole import
        // fails fast rather than half-importing into an invisible state.
        if (!Guid.TryParse(request.SchoolId, out var schoolGuid))
            return Result<BulkUpsertStudentsResult>.Failure("Invalid school identifier.");

        var activeSubId = await _activeSubscription.GetActiveSubscriptionIdAsync(schoolGuid, cancellationToken);
        if (activeSubId is null)
            return Result<BulkUpsertStudentsResult>.Failure(
                "This school has no active subscription. The super admin must create one before importing students.");

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

        // Which of those existing students are already linked to the active
        // subscription? Single query → in-memory set so per-row decisions are
        // O(1). Anything not in the set gets a new SubscriptionStudent row
        // (existing student rolls forward into the new subscription window).
        var existingStudentIds = existingByNational.Values.Select(s => s.Id).ToList();
        var alreadyLinkedSet = existingStudentIds.Count == 0
            ? new HashSet<Guid>()
            : new HashSet<Guid>(
                await _context.SubscriptionStudents
                    .Where(x => x.SubscriptionId == activeSubId.Value
                             && existingStudentIds.Contains(x.StudentId))
                    .Select(x => x.StudentId)
                    .ToListAsync(cancellationToken));

        // Detect duplicate NationalNumbers within the sheet up front so the
        // admin sees a clear "duplicate national number X" error per row
        // instead of a silent overwrite (the second occurrence used to
        // clobber the first one's name fields).
        var seenInSheet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
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

            if (!seenInSheet.Add(row.NationalNumber))
            {
                errors.Add(
                    $"Row '{row.FullName}': duplicate national number '{row.NationalNumber}' already used in this sheet.");
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

                // Roll an already-existing student into the active subscription
                // window if they aren't linked yet. This is how the user spec
                // handles re-importing after a renewal — same student row, new
                // join entry, no duplicates.
                if (!alreadyLinkedSet.Contains(existing.Id))
                {
                    _context.SubscriptionStudents.Add(new SubscriptionStudent
                    {
                        SubscriptionId = activeSubId.Value,
                        StudentId      = existing.Id
                    });
                    alreadyLinkedSet.Add(existing.Id);
                }

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
                // Link the new student to the school's currently active subscription
                // so it actually shows up in the admin grid (queries are scoped to
                // the active subscription window).
                _context.SubscriptionStudents.Add(new SubscriptionStudent
                {
                    SubscriptionId = activeSubId.Value,
                    StudentId      = student.Id
                });
                // Record this student as already-linked so a second row in the
                // same batch with the same NationalNumber doesn't try to add a
                // duplicate (SubscriptionId, StudentId) — Postgres would reject
                // the composite primary key and the whole transaction would
                // roll back, killing every row in the import.
                alreadyLinkedSet.Add(student.Id);
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
