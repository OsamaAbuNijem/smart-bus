using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TilmezBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class LinkNfcCardToStudent : Migration
    {
        // The NFC UID printed on the card the school issued for this
        // student. UIDs are stable per card; iOS / Android both read
        // them as a colon-separated hex string and that's what the
        // mobile scanner POSTs, so we store the same shape verbatim.
        private const string NfcUid    = "04:11:8D:AA:36:67:81";
        private const string StudentId = "207b71ff-d1f0-4555-95ce-8ee15fc47954";

        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Link the NFC card to the student by inserting a registered
            // StudentQrToken row carrying the NFC UID in the Token column.
            // The scan endpoint (/students/scan) already resolves any
            // token string to its student so the existing pickup-attendance
            // flow doesn't need a code change to accept NFC reads — the
            // mobile scanner just POSTs the UID like it does any QR.
            //
            // Idempotent: skip when a row for the same Token already
            // exists (re-runs are no-ops).
            migrationBuilder.Sql($@"
INSERT INTO ""StudentQrTokens""
    (""Id"", ""Token"", ""SchoolId"", ""StudentId"",
     ""IsRegistered"", ""RegisteredAt"", ""CreatedAt"", ""IsDeleted"")
SELECT
    gen_random_uuid(),
    '{NfcUid}',
    s.""SchoolId""::uuid,
    s.""Id"",
    true,
    TIMEZONE('UTC', NOW()),
    TIMEZONE('UTC', NOW()),
    false
FROM ""Students"" s
WHERE s.""Id"" = '{StudentId}'
  AND NOT s.""IsDeleted""
  AND NOT EXISTS (
      SELECT 1
      FROM ""StudentQrTokens"" t
      WHERE t.""Token"" = '{NfcUid}'
        AND NOT t.""IsDeleted""
  );
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                $@"DELETE FROM ""StudentQrTokens"" WHERE ""Token"" = '{NfcUid}';");
        }
    }
}
