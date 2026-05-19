using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TilmezBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddSchoolToTrip : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "SchoolId",
                table: "Trips",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Trips_SchoolId",
                table: "Trips",
                column: "SchoolId");

            migrationBuilder.AddForeignKey(
                name: "FK_Trips_Schools_SchoolId",
                table: "Trips",
                column: "SchoolId",
                principalTable: "Schools",
                principalColumn: "Id");

            // Backfill: every existing trip belongs to whichever school its
            // bus belongs to. New trips get SchoolId stamped in
            // StartTripCommandHandler going forward.
            migrationBuilder.Sql(@"
                UPDATE ""Trips"" t
                   SET ""SchoolId"" = b.""SchoolId""
                  FROM ""Buses"" b
                 WHERE t.""BusId""    = b.""Id""
                   AND t.""SchoolId"" IS NULL;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Trips_Schools_SchoolId",
                table: "Trips");

            migrationBuilder.DropIndex(
                name: "IX_Trips_SchoolId",
                table: "Trips");

            migrationBuilder.DropColumn(
                name: "SchoolId",
                table: "Trips");
        }
    }
}
