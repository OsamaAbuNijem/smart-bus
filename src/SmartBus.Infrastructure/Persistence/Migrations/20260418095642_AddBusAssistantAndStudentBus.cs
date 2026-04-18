using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddBusAssistantAndStudentBus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "BusId",
                table: "Students",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Model",
                table: "Buses",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AddColumn<Guid>(
                name: "AssistantDriverId",
                table: "Buses",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Students_BusId",
                table: "Students",
                column: "BusId");

            migrationBuilder.CreateIndex(
                name: "IX_Buses_AssistantDriverId",
                table: "Buses",
                column: "AssistantDriverId");

            migrationBuilder.AddForeignKey(
                name: "FK_Buses_Drivers_AssistantDriverId",
                table: "Buses",
                column: "AssistantDriverId",
                principalTable: "Drivers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Students_Buses_BusId",
                table: "Students",
                column: "BusId",
                principalTable: "Buses",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Buses_Drivers_AssistantDriverId",
                table: "Buses");

            migrationBuilder.DropForeignKey(
                name: "FK_Students_Buses_BusId",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_Students_BusId",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_Buses_AssistantDriverId",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "BusId",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "AssistantDriverId",
                table: "Buses");

            migrationBuilder.AlterColumn<string>(
                name: "Model",
                table: "Buses",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);
        }
    }
}
