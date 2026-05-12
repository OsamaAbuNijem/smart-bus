using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddNotificationTemplates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "NotificationTemplates",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Type = table.Column<int>(type: "integer", nullable: false),
                    LanguageCode = table.Column<string>(type: "text", nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    Message = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NotificationTemplates", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_NotificationTemplates_Type_LanguageCode",
                table: "NotificationTemplates",
                columns: new[] { "Type", "LanguageCode" },
                unique: true,
                filter: "\"IsDeleted\" = false");

            // Seed Arabic-first templates for the events the app currently
            // emits. Type ints map to SmartBus.Domain.Enums.NotificationType.
            var nowSql = "now() at time zone 'utc'";
            object[,] seeds =
            {
                // TripStarted (0) — driver push.
                {
                    Guid.NewGuid(), 0, "ar",
                    "بدأت {tripType}",
                    "الحافلة {busPlateNumber} مباشرة الآن — افتح خريطة الرحلة للبدء.",
                },
                {
                    Guid.NewGuid(), 0, "en",
                    "{tripType} started",
                    "Bus {busPlateNumber} is now live — open the route map to begin driving.",
                },
                // StudentBoarded (5) — parent push, Morning pickup.
                {
                    Guid.NewGuid(), 5, "ar",
                    "صعود الباص",
                    "صعد {studentName} إلى الحافلة.",
                },
                {
                    Guid.NewGuid(), 5, "en",
                    "Bus pickup",
                    "{studentName} has been picked up by the bus.",
                },
                // StudentArrived (6) — parent push, Return drop-off.
                {
                    Guid.NewGuid(), 6, "ar",
                    "الوصول إلى المنزل",
                    "وصل {studentName} إلى المنزل.",
                },
                {
                    Guid.NewGuid(), 6, "en",
                    "Arrived home",
                    "{studentName} has been dropped off by the bus.",
                },
            };
            for (var i = 0; i < seeds.GetLength(0); i++)
            {
                migrationBuilder.Sql($@"
INSERT INTO ""NotificationTemplates""
    (""Id"", ""Type"", ""LanguageCode"", ""Title"", ""Message"", ""CreatedAt"", ""IsDeleted"")
VALUES
    ('{seeds[i, 0]}', {seeds[i, 1]}, '{seeds[i, 2]}',
     '{((string)seeds[i, 3]).Replace("'", "''")}',
     '{((string)seeds[i, 4]).Replace("'", "''")}',
     {nowSql}, false);
");
            }
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "NotificationTemplates");
        }
    }
}
