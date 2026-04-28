using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddBusQrToken : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // 1. Add the column as nullable so existing rows survive the schema change.
            migrationBuilder.AddColumn<string>(
                name: "QrToken",
                table: "Buses",
                type: "nvarchar(64)",
                maxLength: 64,
                nullable: true);

            // 2. Backfill: every existing bus gets a unique 32-char hex token
            //    derived from NEWID(). The mobile app's POST /trips/scan body
            //    uses this verbatim — anything unique and opaque is fine.
            migrationBuilder.Sql(
                "UPDATE Buses " +
                "SET QrToken = REPLACE(CONVERT(nvarchar(36), NEWID()), '-', '') " +
                "WHERE QrToken IS NULL OR QrToken = '';");

            // 3. Lock down: not-nullable + unique index so we can't accidentally
            //    issue a duplicate token (or a NULL one) going forward.
            migrationBuilder.AlterColumn<string>(
                name: "QrToken",
                table: "Buses",
                type: "nvarchar(64)",
                maxLength: 64,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(64)",
                oldMaxLength: 64,
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Buses_QrToken",
                table: "Buses",
                column: "QrToken",
                unique: true,
                filter: "[IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(name: "IX_Buses_QrToken", table: "Buses");
            migrationBuilder.DropColumn(name: "QrToken", table: "Buses");
        }
    }
}
