using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Attendance.Commands.RecordAttendance;

public class RecordAttendanceCommandHandler : IRequestHandler<RecordAttendanceCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public RecordAttendanceCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(RecordAttendanceCommand request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.Attendances.GetByStudentAndTripAsync(request.StudentId, request.TripId, cancellationToken);
        if (existing is not null)
        {
            existing.Status = request.Status;
            existing.BoardingTime = request.BoardingTime;
            existing.DropoffTime = request.DropoffTime;
            await _unitOfWork.Attendances.UpdateAsync(existing);
            await _unitOfWork.SaveChangesAsync(cancellationToken);
            return Result<Guid>.Success(existing.Id);
        }

        var attendance = new Domain.Entities.Attendance
        {
            StudentId = request.StudentId,
            TripId = request.TripId,
            Date = request.Date,
            Status = request.Status,
            BoardingTime = request.BoardingTime,
            DropoffTime = request.DropoffTime
        };

        await _unitOfWork.Attendances.AddAsync(attendance, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(attendance.Id);
    }
}
