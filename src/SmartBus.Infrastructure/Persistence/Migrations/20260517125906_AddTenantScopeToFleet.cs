using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddTenantScopeToFleet : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "SchoolId",
                table: "Drivers",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "SchoolId",
                table: "Buses",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "SchoolId",
                table: "Assistants",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Drivers_SchoolId",
                table: "Drivers",
                column: "SchoolId");

            migrationBuilder.CreateIndex(
                name: "IX_Buses_SchoolId",
                table: "Buses",
                column: "SchoolId");

            migrationBuilder.CreateIndex(
                name: "IX_Assistants_SchoolId",
                table: "Assistants",
                column: "SchoolId");

            migrationBuilder.AddForeignKey(
                name: "FK_Assistants_Schools_SchoolId",
                table: "Assistants",
                column: "SchoolId",
                principalTable: "Schools",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Buses_Schools_SchoolId",
                table: "Buses",
                column: "SchoolId",
                principalTable: "Schools",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Drivers_Schools_SchoolId",
                table: "Drivers",
                column: "SchoolId",
                principalTable: "Schools",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            // Backfill: attribute any pre-existing fleet rows (seeded driver,
            // assistant, buses) to the seeded "SmartBus Demo School" so admin
            // grids find them. Targeted by AdminEmail (deterministic) rather
            // than CreatedAt (which can flip when schools get re-seeded). New
            // rows get a SchoolId from the calling admin's context going
            // forward; this SQL is only relevant on the legacy data.
            migrationBuilder.Sql(@"
                UPDATE ""Buses""
                   SET ""SchoolId"" = (
                       SELECT ""Id"" FROM ""Schools""
                        WHERE NOT ""IsDeleted"" AND ""AdminEmail"" = 'admin@smartbus.com'
                        LIMIT 1)
                 WHERE ""SchoolId"" IS NULL;
                UPDATE ""Drivers""
                   SET ""SchoolId"" = (
                       SELECT ""Id"" FROM ""Schools""
                        WHERE NOT ""IsDeleted"" AND ""AdminEmail"" = 'admin@smartbus.com'
                        LIMIT 1)
                 WHERE ""SchoolId"" IS NULL;
                UPDATE ""Assistants""
                   SET ""SchoolId"" = (
                       SELECT ""Id"" FROM ""Schools""
                        WHERE NOT ""IsDeleted"" AND ""AdminEmail"" = 'admin@smartbus.com'
                        LIMIT 1)
                 WHERE ""SchoolId"" IS NULL;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Assistants_Schools_SchoolId",
                table: "Assistants");

            migrationBuilder.DropForeignKey(
                name: "FK_Buses_Schools_SchoolId",
                table: "Buses");

            migrationBuilder.DropForeignKey(
                name: "FK_Drivers_Schools_SchoolId",
                table: "Drivers");

            migrationBuilder.DropIndex(
                name: "IX_Drivers_SchoolId",
                table: "Drivers");

            migrationBuilder.DropIndex(
                name: "IX_Buses_SchoolId",
                table: "Buses");

            migrationBuilder.DropIndex(
                name: "IX_Assistants_SchoolId",
                table: "Assistants");

            migrationBuilder.DropColumn(
                name: "SchoolId",
                table: "Drivers");

            migrationBuilder.DropColumn(
                name: "SchoolId",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "SchoolId",
                table: "Assistants");
        }
    }
}
