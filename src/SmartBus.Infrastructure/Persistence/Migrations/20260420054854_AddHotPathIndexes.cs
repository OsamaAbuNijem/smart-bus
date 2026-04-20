using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddHotPathIndexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Students_BusId",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_BusLocations_BusId",
                table: "BusLocations");

            migrationBuilder.CreateIndex(
                name: "IX_Trips_IsDeleted_ScheduledDeparture",
                table: "Trips",
                columns: new[] { "IsDeleted", "ScheduledDeparture" });

            migrationBuilder.CreateIndex(
                name: "IX_Trips_Status_ScheduledDeparture",
                table: "Trips",
                columns: new[] { "Status", "ScheduledDeparture" });

            migrationBuilder.CreateIndex(
                name: "IX_Students_BusId_IsDeleted",
                table: "Students",
                columns: new[] { "BusId", "IsDeleted" });

            migrationBuilder.CreateIndex(
                name: "IX_Students_IsDeleted_CreatedAt",
                table: "Students",
                columns: new[] { "IsDeleted", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_Drivers_DriverType_IsDeleted",
                table: "Drivers",
                columns: new[] { "DriverType", "IsDeleted" });

            migrationBuilder.CreateIndex(
                name: "IX_Drivers_IsDeleted_CreatedAt",
                table: "Drivers",
                columns: new[] { "IsDeleted", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_BusLocations_BusId_Timestamp",
                table: "BusLocations",
                columns: new[] { "BusId", "Timestamp" });

            migrationBuilder.CreateIndex(
                name: "IX_Buses_IsDeleted_CreatedAt",
                table: "Buses",
                columns: new[] { "IsDeleted", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_Alerts_IsDeleted_CreatedAt",
                table: "Alerts",
                columns: new[] { "IsDeleted", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_Alerts_Status_CreatedAt",
                table: "Alerts",
                columns: new[] { "Status", "CreatedAt" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Trips_IsDeleted_ScheduledDeparture",
                table: "Trips");

            migrationBuilder.DropIndex(
                name: "IX_Trips_Status_ScheduledDeparture",
                table: "Trips");

            migrationBuilder.DropIndex(
                name: "IX_Students_BusId_IsDeleted",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_Students_IsDeleted_CreatedAt",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_Drivers_DriverType_IsDeleted",
                table: "Drivers");

            migrationBuilder.DropIndex(
                name: "IX_Drivers_IsDeleted_CreatedAt",
                table: "Drivers");

            migrationBuilder.DropIndex(
                name: "IX_BusLocations_BusId_Timestamp",
                table: "BusLocations");

            migrationBuilder.DropIndex(
                name: "IX_Buses_IsDeleted_CreatedAt",
                table: "Buses");

            migrationBuilder.DropIndex(
                name: "IX_Alerts_IsDeleted_CreatedAt",
                table: "Alerts");

            migrationBuilder.DropIndex(
                name: "IX_Alerts_Status_CreatedAt",
                table: "Alerts");

            migrationBuilder.CreateIndex(
                name: "IX_Students_BusId",
                table: "Students",
                column: "BusId");

            migrationBuilder.CreateIndex(
                name: "IX_BusLocations_BusId",
                table: "BusLocations",
                column: "BusId");
        }
    }
}
