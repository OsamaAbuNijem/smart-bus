using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Features.Notifications.Commands.MarkNotificationAsRead;
using TilmezBus.Application.Features.Notifications.Commands.SendNotification;
using TilmezBus.Application.Features.Notifications.Queries.GetNotificationsByRecipient;
using TilmezBus.Domain.Entities;

namespace TilmezBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class NotificationsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IApplicationDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPushNotificationService _push;

    public NotificationsController(
        IMediator mediator,
        IApplicationDbContext db,
        ICurrentUserService currentUser,
        IPushNotificationService push)
    {
        _mediator = mediator;
        _db = db;
        _currentUser = currentUser;
        _push = push;
    }

    /// <summary>Get notifications for a recipient (parent/driver/assistant userId).</summary>
    /// <remarks>
    /// The :guid constraint keeps this from swallowing literal sibling routes
    /// like /me — without it the catch-all would win for /notifications/me.
    /// </remarks>
    [HttpGet("{recipientId:guid}")]
    public async Task<IActionResult> GetByRecipient(string recipientId, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetNotificationsByRecipientQuery(recipientId, pageNumber, pageSize), cancellationToken));

    /// <summary>Get notifications for the calling user. Mobile clients use this
    /// so they don't need to know their Identity user id.</summary>
    [HttpGet("me")]
    public async Task<IActionResult> GetMine([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 50, CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.UserId;
        if (string.IsNullOrEmpty(userId)) return Unauthorized();
        return Ok(await _mediator.Send(new GetNotificationsByRecipientQuery(userId, pageNumber, pageSize), cancellationToken));
    }

    /// <summary>Send a notification (admin only).</summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Send([FromBody] SendNotificationCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    /// <summary>Mark a notification as read.</summary>
    [HttpPatch("{id:guid}/read")]
    public async Task<IActionResult> MarkAsRead(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new MarkNotificationAsReadCommand(id), cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    /// <summary>Mark every notification for the calling user as read.</summary>
    [HttpPatch("read-all")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> MarkAllAsRead(CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId;
        if (string.IsNullOrEmpty(userId)) return Unauthorized();
        await _db.Notifications
            .Where(n => n.RecipientId == userId && !n.IsRead)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(n => n.IsRead, true)
                .SetProperty(n => n.UpdatedAt, DateTime.UtcNow),
                cancellationToken);
        return NoContent();
    }

    /// <summary>Register / refresh the FCM device token for the current user.</summary>
    [HttpPost("devices")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> RegisterDevice(
        [FromBody] RegisterDeviceRequest request,
        CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId;
        if (string.IsNullOrEmpty(userId)) return Unauthorized();
        if (string.IsNullOrWhiteSpace(request.Token))
            return BadRequest(new { error = "Token is required." });

        // Normalise the language tag to two lower-case letters so "ar-JO",
        // "AR", and "ar" all collapse to "ar". Null/blank → "ar" fallback
        // applied at send time, not stored here.
        string? lang = null;
        if (!string.IsNullOrWhiteSpace(request.Language))
        {
            var twoChar = request.Language!.Trim().ToLowerInvariant();
            if (twoChar.Length > 2) twoChar = twoChar[..2];
            lang = twoChar;
        }

        var platform = string.IsNullOrWhiteSpace(request.Platform)
            ? "android"
            : request.Platform.ToLowerInvariant();

        // Soft-delete every other token this user has on the same platform.
        // Reinstalls / FCM token rotations keep generating fresh tokens, and
        // FCM doesn't always report the old ones as UNREGISTERED in time —
        // so without this prune one push ends up landing on the phone as
        // multiple banners. Trade-off: a user with two iOS devices keeps
        // only the most recently registered one active per platform; the
        // other re-arms on next launch when that app POSTs again.
        var now = DateTime.UtcNow;
        await _db.UserDeviceTokens
            .Where(t => t.UserId == userId
                     && t.Platform == platform
                     && t.Token != request.Token
                     && !t.IsDeleted)
            .ExecuteUpdateAsync(s => s
                .SetProperty(t => t.IsDeleted, true)
                .SetProperty(t => t.UpdatedAt, now), cancellationToken);

        // Upsert by (UserId, Token). EF Core 8 has no native upsert, so do a
        // find-or-insert; the unique index protects against races.
        var existing = await _db.UserDeviceTokens
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(t => t.UserId == userId && t.Token == request.Token, cancellationToken);
        if (existing is null)
        {
            _db.UserDeviceTokens.Add(new UserDeviceToken
            {
                UserId = userId,
                Token = request.Token,
                Platform = platform,
                Language = lang,
                LastSeenAt = now,
            });
        }
        else
        {
            // Revive any soft-deleted row for the same (user, token) — the
            // user re-installed and got the same FCM token back, so we don't
            // need a fresh row.
            existing.IsDeleted = false;
            existing.Platform  = platform;
            if (lang is not null) existing.Language = lang;
            existing.LastSeenAt = now;
            existing.UpdatedAt  = now;
        }
        await _db.SaveChangesAsync(cancellationToken);
        return NoContent();
    }

    /// <summary>Sends a test push to the calling user. Use to verify FCM end-to-end.</summary>
    [HttpPost("test")]
    public async Task<IActionResult> SendTest(CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId;
        if (string.IsNullOrEmpty(userId)) return Unauthorized();
        var sent = await _push.SendToUserAsync(
            userId,
            title: "TilmezBus test",
            body: "Push notifications are working.",
            data: new Dictionary<string, string> { ["type"] = "test" },
            cancellationToken: cancellationToken);
        return Ok(new { delivered = sent });
    }

    /// <summary>Sends a push notification to the parent of a given student. Admin-only.</summary>
    [HttpPost("students/{studentId:guid}/push")]
    [Authorize(Roles = "Admin,SuperAdmin,Driver,Assistant")]
    public async Task<IActionResult> SendToStudentParent(
        Guid studentId,
        [FromBody] SendPushRequest request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Title) || string.IsNullOrWhiteSpace(request.Body))
            return BadRequest(new { error = "Title and Body are required." });

        var student = await _db.Students
            .Where(s => s.Id == studentId)
            .Select(s => new { s.ParentId })
            .FirstOrDefaultAsync(cancellationToken);
        if (student is null) return NotFound(new { error = "Student not found." });

        var parentUserId = await _db.Parents
            .Where(p => p.Id == student.ParentId)
            .Select(p => p.UserId)
            .FirstOrDefaultAsync(cancellationToken);
        if (string.IsNullOrEmpty(parentUserId))
            return Ok(new { delivered = 0, reason = "Parent has not registered any device yet." });

        var sent = await _push.SendToUserAsync(
            parentUserId,
            request.Title,
            request.Body,
            data: new Dictionary<string, string> { ["type"] = "admin-push", ["studentId"] = studentId.ToString() },
            cancellationToken: cancellationToken);
        return Ok(new { delivered = sent });
    }
}

public record RegisterDeviceRequest(string Token, string? Platform, string? Language);
public record SendPushRequest(string Title, string Body);
