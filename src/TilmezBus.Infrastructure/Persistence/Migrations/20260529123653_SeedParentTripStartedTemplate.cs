using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TilmezBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class SeedParentTripStartedTemplate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // ParentTripStarted (11) — informational push to every parent
            // on the trip's roster when the trip flips to InProgress.
            // Mirrors the structure of the TripStarted (0) seed but with
            // parent-facing copy: no "open the route map" CTA, since the
            // parent app already shows the live trip on its home screen.
            var nowSql = "now() at time zone 'utc'";
            object[,] seeds =
            {
                {
                    System.Guid.NewGuid(), 11, "ar",
                    "بدأت {tripType}",
                    "حافلة {busPlateNumber} انطلقت الآن — تابع رحلة طفلك من التطبيق.",
                },
                {
                    System.Guid.NewGuid(), 11, "en",
                    "{tripType} has started",
                    "Bus {busPlateNumber} is on the move — follow your child's trip from the app.",
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
            migrationBuilder.Sql(@"DELETE FROM ""NotificationTemplates"" WHERE ""Type"" = 11;");
        }
    }
}
