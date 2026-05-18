using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddAssistantToTrip : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "AssistantId",
                table: "Trips",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Trips_AssistantId",
                table: "Trips",
                column: "AssistantId");

            migrationBuilder.AddForeignKey(
                name: "FK_Trips_Drivers_AssistantId",
                table: "Trips",
                column: "AssistantId",
                principalTable: "Drivers",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Trips_Drivers_AssistantId",
                table: "Trips");

            migrationBuilder.DropIndex(
                name: "IX_Trips_AssistantId",
                table: "Trips");

            migrationBuilder.DropColumn(
                name: "AssistantId",
                table: "Trips");
        }
    }
}
