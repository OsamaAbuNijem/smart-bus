using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RemoveSchoolCaps : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "Schools");

            migrationBuilder.DropColumn(
                name: "MaxAssistants",
                table: "Schools");

            migrationBuilder.DropColumn(
                name: "MaxBuses",
                table: "Schools");

            migrationBuilder.DropColumn(
                name: "MaxDrivers",
                table: "Schools");

            migrationBuilder.DropColumn(
                name: "MaxStudents",
                table: "Schools");

            migrationBuilder.DropColumn(
                name: "Plan",
                table: "Schools");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "Schools",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "MaxAssistants",
                table: "Schools",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "MaxBuses",
                table: "Schools",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "MaxDrivers",
                table: "Schools",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "MaxStudents",
                table: "Schools",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Plan",
                table: "Schools",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }
    }
}
