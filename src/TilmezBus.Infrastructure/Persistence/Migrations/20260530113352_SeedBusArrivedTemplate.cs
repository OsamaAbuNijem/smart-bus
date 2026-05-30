using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TilmezBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class SeedBusArrivedTemplate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // BusArrived (3) — parent push fired when the assistant taps
            // "Notify arrived" on a student's row in trip details. Renders
            // per the parent's registered device language so a parent with
            // an Arabic phone gets the Arabic copy.
            var nowSql = "now() at time zone 'utc'";
            object[,] seeds =
            {
                {
                    System.Guid.NewGuid(), 3, "ar",
                    "وصلت الحافلة",
                    "وصلت الحافلة إلى منزل {studentName}.",
                },
                {
                    System.Guid.NewGuid(), 3, "en",
                    "Bus arrived",
                    "The bus has arrived at {studentName}'s home.",
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
            migrationBuilder.Sql(@"DELETE FROM ""NotificationTemplates"" WHERE ""Type"" = 3;");
        }
    }
}
