using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TilmezBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddStudentArrivedAtSchoolTemplate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Seed Arabic + English templates for NotificationType.StudentArrivedAtSchool (10).
            // Fired when the assistant ends a Morning trip — all boarded students get
            // flipped to DroppedOff and each parent gets a push.
            const string nowSql = "TIMEZONE('UTC', NOW())";

            var seeds = new object[,]
            {
                {
                    System.Guid.NewGuid(), 10, "ar",
                    "الوصول إلى المدرسة",
                    "وصل {studentName} إلى المدرسة.",
                },
                {
                    System.Guid.NewGuid(), 10, "en",
                    "Arrived at school",
                    "{studentName} has arrived at school.",
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
            migrationBuilder.Sql(@"DELETE FROM ""NotificationTemplates"" WHERE ""Type"" = 10;");
        }
    }
}
