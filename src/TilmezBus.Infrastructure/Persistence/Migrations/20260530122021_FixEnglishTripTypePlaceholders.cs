using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TilmezBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class FixEnglishTripTypePlaceholders : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // English templates for TripStarted (0), TripCompleted (1) and
            // ParentTripStarted (11) referenced {tripType}, but the call
            // sites put the Arabic label (e.g. "رحلة الصباح") into
            // {tripType} and the English label (e.g. "Morning trip") into
            // {tripTypeEn} — kept that way so the Arabic templates render
            // correctly. Point the English rows at {tripTypeEn} so an
            // English-language device gets an English banner instead of
            // an Arabic word embedded in an English sentence.
            migrationBuilder.Sql(@"
UPDATE ""NotificationTemplates""
SET ""Title""     = REPLACE(""Title"",   '{tripType}', '{tripTypeEn}'),
    ""Message""   = REPLACE(""Message"", '{tripType}', '{tripTypeEn}'),
    ""UpdatedAt"" = now() at time zone 'utc'
WHERE ""LanguageCode"" = 'en' AND ""Type"" IN (0, 1, 11);
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
UPDATE ""NotificationTemplates""
SET ""Title""     = REPLACE(""Title"",   '{tripTypeEn}', '{tripType}'),
    ""Message""   = REPLACE(""Message"", '{tripTypeEn}', '{tripType}'),
    ""UpdatedAt"" = now() at time zone 'utc'
WHERE ""LanguageCode"" = 'en' AND ""Type"" IN (0, 1, 11);
");
        }
    }
}
