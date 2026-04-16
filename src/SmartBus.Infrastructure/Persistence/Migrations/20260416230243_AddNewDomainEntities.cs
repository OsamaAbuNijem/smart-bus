using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddNewDomainEntities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_BusLocations_BusId",
                table: "BusLocations");

            migrationBuilder.AddColumn<string>(
                name: "Name",
                table: "Trips",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<byte>(
                name: "RepeatDays",
                table: "Trips",
                type: "tinyint",
                nullable: false,
                defaultValue: (byte)0);

            migrationBuilder.AddColumn<int>(
                name: "Type",
                table: "Trips",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AlterColumn<Guid>(
                name: "PickupStopId",
                table: "Students",
                type: "uniqueidentifier",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "Students",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Class",
                table: "Students",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "DateOfBirth",
                table: "Students",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ParentId",
                table: "Students",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "Drivers",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<Guid>(
                name: "AssistantId",
                table: "Buses",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "LastLocationId",
                table: "Buses",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "LastMaintenanceDate",
                table: "Buses",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ManufacturingYear",
                table: "Buses",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "AbsenceRequests",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    StudentId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Date = table.Column<DateOnly>(type: "date", nullable: false),
                    TripType = table.Column<int>(type: "int", nullable: false),
                    Reason = table.Column<int>(type: "int", nullable: false),
                    PickupPersonName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PickupPersonRelation = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DriverNote = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    NotifyDriver = table.Column<bool>(type: "bit", nullable: false),
                    NotifySchool = table.Column<bool>(type: "bit", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AbsenceRequests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AbsenceRequests_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Alerts",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Message = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Severity = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    RelatedBusId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    RelatedTripId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    RelatedStudentId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Alerts", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Assistants",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    BusId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Assistants", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Attendances",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    StudentId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    TripId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Date = table.Column<DateOnly>(type: "date", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    BoardingTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DropoffTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Attendances", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Attendances_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Attendances_Trips_TripId",
                        column: x => x.TripId,
                        principalTable: "Trips",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "EmergencyContacts",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    StudentId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Relation = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EmergencyContacts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EmergencyContacts_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Parents",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Parents", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "StudentAllergies",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    StudentId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Condition = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StudentAllergies", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StudentAllergies_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "StudentTrips",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    StudentId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    TripId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    BoardingStatus = table.Column<int>(type: "int", nullable: false),
                    BoardingTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DropoffTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StudentTrips", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StudentTrips_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_StudentTrips_Trips_TripId",
                        column: x => x.TripId,
                        principalTable: "Trips",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Students_ParentId",
                table: "Students",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_Students_PickupStopId",
                table: "Students",
                column: "PickupStopId");

            migrationBuilder.CreateIndex(
                name: "IX_BusLocations_BusId",
                table: "BusLocations",
                column: "BusId");

            migrationBuilder.CreateIndex(
                name: "IX_Buses_AssistantId",
                table: "Buses",
                column: "AssistantId",
                unique: true,
                filter: "[AssistantId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Buses_LastLocationId",
                table: "Buses",
                column: "LastLocationId");

            migrationBuilder.CreateIndex(
                name: "IX_AbsenceRequests_StudentId",
                table: "AbsenceRequests",
                column: "StudentId");

            migrationBuilder.CreateIndex(
                name: "IX_Attendances_StudentId_TripId_Date",
                table: "Attendances",
                columns: new[] { "StudentId", "TripId", "Date" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Attendances_TripId",
                table: "Attendances",
                column: "TripId");

            migrationBuilder.CreateIndex(
                name: "IX_EmergencyContacts_StudentId",
                table: "EmergencyContacts",
                column: "StudentId");

            migrationBuilder.CreateIndex(
                name: "IX_StudentAllergies_StudentId",
                table: "StudentAllergies",
                column: "StudentId");

            migrationBuilder.CreateIndex(
                name: "IX_StudentTrips_StudentId_TripId",
                table: "StudentTrips",
                columns: new[] { "StudentId", "TripId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StudentTrips_TripId",
                table: "StudentTrips",
                column: "TripId");

            migrationBuilder.AddForeignKey(
                name: "FK_Buses_Assistants_AssistantId",
                table: "Buses",
                column: "AssistantId",
                principalTable: "Assistants",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Buses_BusLocations_LastLocationId",
                table: "Buses",
                column: "LastLocationId",
                principalTable: "BusLocations",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Students_Parents_ParentId",
                table: "Students",
                column: "ParentId",
                principalTable: "Parents",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Students_Stops_PickupStopId",
                table: "Students",
                column: "PickupStopId",
                principalTable: "Stops",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Buses_Assistants_AssistantId",
                table: "Buses");

            migrationBuilder.DropForeignKey(
                name: "FK_Buses_BusLocations_LastLocationId",
                table: "Buses");

            migrationBuilder.DropForeignKey(
                name: "FK_Students_Parents_ParentId",
                table: "Students");

            migrationBuilder.DropForeignKey(
                name: "FK_Students_Stops_PickupStopId",
                table: "Students");

            migrationBuilder.DropTable(
                name: "AbsenceRequests");

            migrationBuilder.DropTable(
                name: "Alerts");

            migrationBuilder.DropTable(
                name: "Assistants");

            migrationBuilder.DropTable(
                name: "Attendances");

            migrationBuilder.DropTable(
                name: "EmergencyContacts");

            migrationBuilder.DropTable(
                name: "Parents");

            migrationBuilder.DropTable(
                name: "StudentAllergies");

            migrationBuilder.DropTable(
                name: "StudentTrips");

            migrationBuilder.DropIndex(
                name: "IX_Students_ParentId",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_Students_PickupStopId",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_BusLocations_BusId",
                table: "BusLocations");

            migrationBuilder.DropIndex(
                name: "IX_Buses_AssistantId",
                table: "Buses");

            migrationBuilder.DropIndex(
                name: "IX_Buses_LastLocationId",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "Name",
                table: "Trips");

            migrationBuilder.DropColumn(
                name: "RepeatDays",
                table: "Trips");

            migrationBuilder.DropColumn(
                name: "Type",
                table: "Trips");

            migrationBuilder.DropColumn(
                name: "Address",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "Class",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "DateOfBirth",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "ParentId",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "Drivers");

            migrationBuilder.DropColumn(
                name: "AssistantId",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "LastLocationId",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "LastMaintenanceDate",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "ManufacturingYear",
                table: "Buses");

            migrationBuilder.AlterColumn<string>(
                name: "PickupStopId",
                table: "Students",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier",
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_BusLocations_BusId",
                table: "BusLocations",
                column: "BusId",
                unique: true);
        }
    }
}
