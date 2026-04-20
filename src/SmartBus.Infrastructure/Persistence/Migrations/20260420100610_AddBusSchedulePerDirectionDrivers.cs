using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddBusSchedulePerDirectionDrivers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "MorningAssistantId",
                table: "BusSchedules",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "MorningDriverId",
                table: "BusSchedules",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ReturnAssistantId",
                table: "BusSchedules",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ReturnDriverId",
                table: "BusSchedules",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_BusSchedules_MorningAssistantId",
                table: "BusSchedules",
                column: "MorningAssistantId");

            migrationBuilder.CreateIndex(
                name: "IX_BusSchedules_MorningDriverId",
                table: "BusSchedules",
                column: "MorningDriverId");

            migrationBuilder.CreateIndex(
                name: "IX_BusSchedules_ReturnAssistantId",
                table: "BusSchedules",
                column: "ReturnAssistantId");

            migrationBuilder.CreateIndex(
                name: "IX_BusSchedules_ReturnDriverId",
                table: "BusSchedules",
                column: "ReturnDriverId");

            migrationBuilder.AddForeignKey(
                name: "FK_BusSchedules_Drivers_MorningAssistantId",
                table: "BusSchedules",
                column: "MorningAssistantId",
                principalTable: "Drivers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_BusSchedules_Drivers_MorningDriverId",
                table: "BusSchedules",
                column: "MorningDriverId",
                principalTable: "Drivers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_BusSchedules_Drivers_ReturnAssistantId",
                table: "BusSchedules",
                column: "ReturnAssistantId",
                principalTable: "Drivers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_BusSchedules_Drivers_ReturnDriverId",
                table: "BusSchedules",
                column: "ReturnDriverId",
                principalTable: "Drivers",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_BusSchedules_Drivers_MorningAssistantId",
                table: "BusSchedules");

            migrationBuilder.DropForeignKey(
                name: "FK_BusSchedules_Drivers_MorningDriverId",
                table: "BusSchedules");

            migrationBuilder.DropForeignKey(
                name: "FK_BusSchedules_Drivers_ReturnAssistantId",
                table: "BusSchedules");

            migrationBuilder.DropForeignKey(
                name: "FK_BusSchedules_Drivers_ReturnDriverId",
                table: "BusSchedules");

            migrationBuilder.DropIndex(
                name: "IX_BusSchedules_MorningAssistantId",
                table: "BusSchedules");

            migrationBuilder.DropIndex(
                name: "IX_BusSchedules_MorningDriverId",
                table: "BusSchedules");

            migrationBuilder.DropIndex(
                name: "IX_BusSchedules_ReturnAssistantId",
                table: "BusSchedules");

            migrationBuilder.DropIndex(
                name: "IX_BusSchedules_ReturnDriverId",
                table: "BusSchedules");

            migrationBuilder.DropColumn(
                name: "MorningAssistantId",
                table: "BusSchedules");

            migrationBuilder.DropColumn(
                name: "MorningDriverId",
                table: "BusSchedules");

            migrationBuilder.DropColumn(
                name: "ReturnAssistantId",
                table: "BusSchedules");

            migrationBuilder.DropColumn(
                name: "ReturnDriverId",
                table: "BusSchedules");
        }
    }
}
