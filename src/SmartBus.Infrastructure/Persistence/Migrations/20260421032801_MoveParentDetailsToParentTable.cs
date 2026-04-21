using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class MoveParentDetailsToParentTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Add the new FullNameEn column FIRST so backfill can populate it.
            migrationBuilder.AddColumn<string>(
                name: "FullNameEn",
                table: "Parents",
                type: "nvarchar(max)",
                nullable: true);

            // Tighten PhoneNumber to support the unique index.
            migrationBuilder.AlterColumn<string>(
                name: "PhoneNumber",
                table: "Parents",
                type: "nvarchar(450)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            // Backfill step 1: for every distinct ParentPhone on live students without
            // a Parent row yet, create one using the first student's denormalized name.
            migrationBuilder.Sql(@"
INSERT INTO Parents (Id, FullName, FullNameEn, PhoneNumber, UserId, CreatedAt, IsDeleted)
SELECT NEWID(), MAX(s.ParentName), MAX(s.ParentNameEn), s.ParentPhone, NULL, SYSUTCDATETIME(), 0
FROM Students s
WHERE s.IsDeleted = 0
  AND s.ParentPhone IS NOT NULL AND s.ParentPhone <> ''
  AND NOT EXISTS (
      SELECT 1 FROM Parents p WHERE p.IsDeleted = 0 AND p.PhoneNumber = s.ParentPhone)
GROUP BY s.ParentPhone;
");

            // Backfill step 2: point every live student without a ParentId at the matching Parent row.
            migrationBuilder.Sql(@"
UPDATE s
SET s.ParentId = p.Id
FROM Students s
JOIN Parents p ON p.PhoneNumber = s.ParentPhone AND p.IsDeleted = 0
WHERE s.IsDeleted = 0 AND s.ParentId IS NULL;
");

            // Unique phone per live parent — installed AFTER backfill so duplicate
            // denormalized phones in Students collapse into one Parent row.
            migrationBuilder.CreateIndex(
                name: "IX_Parents_PhoneNumber",
                table: "Parents",
                column: "PhoneNumber",
                unique: true,
                filter: "[IsDeleted] = 0");

            // Finally drop the denormalized student columns.
            migrationBuilder.DropColumn(
                name: "ParentName",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "ParentNameEn",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "ParentPhone",
                table: "Students");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Parents_PhoneNumber",
                table: "Parents");

            migrationBuilder.DropColumn(
                name: "FullNameEn",
                table: "Parents");

            migrationBuilder.AddColumn<string>(
                name: "ParentName",
                table: "Students",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ParentNameEn",
                table: "Students",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ParentPhone",
                table: "Students",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<string>(
                name: "PhoneNumber",
                table: "Parents",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(450)");
        }
    }
}
