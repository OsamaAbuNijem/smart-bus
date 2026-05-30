using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TilmezBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class SeedTripCompletedTemplate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // TripCompleted (1) — driver-facing push fired once on
            // * → Completed for either trip type. Mirrors the TripStarted
            // (0) seed in tone — short banner the driver sees on the
            // lock screen confirming the trip closed cleanly.
            var nowSql = "now() at time zone 'utc'";
            object[,] seeds =
            {
                {
                    System.Guid.NewGuid(), 1, "ar",
                    "انتهت {tripType}",
                    "تم إنهاء رحلة الحافلة {busPlateNumber} بنجاح.",
                },
                {
                    System.Guid.NewGuid(), 1, "en",
                    "{tripType} completed",
                    "Bus {busPlateNumber} has finished the trip.",
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
            migrationBuilder.Sql(@"DELETE FROM ""NotificationTemplates"" WHERE ""Type"" = 1;");
        }
    }
}
