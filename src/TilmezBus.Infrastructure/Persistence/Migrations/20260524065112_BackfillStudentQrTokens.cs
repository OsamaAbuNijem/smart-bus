using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TilmezBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class BackfillStudentQrTokens : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Mint a registered StudentQrToken for every existing student
            // that doesn't already have one. New students get tokens from
            // the create-student handler; this is the one-shot backfill
            // for rows that existed before the auto-mint shipped.
            //
            // - Students.SchoolId is a `text` column carrying the Guid; cast
            //   to uuid for the StudentQrTokens.SchoolId FK.
            // - 16 random bytes → 32-char lowercase hex matches the legacy
            //   sticker token shape so URLs stay stable across the cutover.
            migrationBuilder.Sql(@"
INSERT INTO ""StudentQrTokens""
    (""Id"", ""Token"", ""SchoolId"", ""StudentId"",
     ""IsRegistered"", ""RegisteredAt"", ""CreatedAt"", ""IsDeleted"")
SELECT
    gen_random_uuid(),
    LOWER(ENCODE(gen_random_bytes(16), 'hex')),
    s.""SchoolId""::uuid,
    s.""Id"",
    true,
    TIMEZONE('UTC', NOW()),
    TIMEZONE('UTC', NOW()),
    false
FROM ""Students"" s
WHERE NOT s.""IsDeleted""
  AND NOT EXISTS (
      SELECT 1
      FROM ""StudentQrTokens"" t
      WHERE t.""StudentId"" = s.""Id""
        AND NOT t.""IsDeleted""
  );
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Backfill is non-destructive — leaving the tokens in place on
            // rollback is the safer choice (orphan rows can be cleaned up
            // manually if ever needed).
        }
    }
}
