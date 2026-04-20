using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class DropBusDriverStudentBusRefAddScheduleJoin : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Add the BusSchedule counter column first so the backfill can populate it.
            migrationBuilder.AddColumn<int>(
                name: "StudentCount",
                table: "BusSchedules",
                type: "int",
                nullable: false,
                defaultValue: 0);

            // Create the join table before the drops so we can backfill from Student.BusId.
            migrationBuilder.CreateTable(
                name: "BusScheduleStudents",
                columns: table => new
                {
                    BusScheduleId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    StudentId     = table.Column<Guid>(type: "uniqueidentifier", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BusScheduleStudents", x => new { x.BusScheduleId, x.StudentId });
                    table.ForeignKey(
                        name: "FK_BusScheduleStudents_BusSchedules_BusScheduleId",
                        column: x => x.BusScheduleId,
                        principalTable: "BusSchedules",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_BusScheduleStudents_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_BusScheduleStudents_StudentId",
                table: "BusScheduleStudents",
                column: "StudentId");

            // Backfill step 1: create an empty schedule for every bus that has at least one
            // student assigned but no existing schedule. Default 07:00 / 14:00, no repeat days.
            migrationBuilder.Sql(@"
INSERT INTO BusSchedules (Id, BusId, MorningTime, ReturnTime, RepeatDays, StudentCount, CreatedAt, IsDeleted)
SELECT NEWID(), s.BusId, '07:00:00', '14:00:00', 0, 0, SYSUTCDATETIME(), 0
FROM (SELECT DISTINCT BusId FROM Students WHERE BusId IS NOT NULL AND IsDeleted = 0) s
WHERE NOT EXISTS (SELECT 1 FROM BusSchedules sch WHERE sch.BusId = s.BusId);
");

            // Backfill step 2: copy Student.BusId → BusScheduleStudents.
            migrationBuilder.Sql(@"
INSERT INTO BusScheduleStudents (BusScheduleId, StudentId)
SELECT sch.Id, s.Id
FROM Students s
JOIN BusSchedules sch ON sch.BusId = s.BusId
WHERE s.BusId IS NOT NULL AND s.IsDeleted = 0 AND sch.IsDeleted = 0;
");

            // Backfill step 3: populate the StudentCount counter.
            migrationBuilder.Sql(@"
UPDATE sch
SET StudentCount = (SELECT COUNT(*) FROM BusScheduleStudents j WHERE j.BusScheduleId = sch.Id)
FROM BusSchedules sch;
");

            migrationBuilder.DropForeignKey(
                name: "FK_Buses_Assistants_AssistantId",
                table: "Buses");

            migrationBuilder.DropForeignKey(
                name: "FK_Buses_Drivers_AssistantDriverId",
                table: "Buses");

            migrationBuilder.DropForeignKey(
                name: "FK_Buses_Drivers_DriverId",
                table: "Buses");

            migrationBuilder.DropForeignKey(
                name: "FK_Students_Buses_BusId",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_Students_BusId_IsDeleted",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_Buses_AssistantDriverId",
                table: "Buses");

            migrationBuilder.DropIndex(
                name: "IX_Buses_AssistantId",
                table: "Buses");

            migrationBuilder.DropIndex(
                name: "IX_Buses_DriverId",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "BusId",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "AssistantDriverId",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "AssistantId",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "DriverId",
                table: "Buses");

            migrationBuilder.DropColumn(
                name: "BusId",
                table: "Assistants");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BusScheduleStudents");

            migrationBuilder.DropColumn(
                name: "StudentCount",
                table: "BusSchedules");

            migrationBuilder.AddColumn<Guid>(
                name: "BusId",
                table: "Students",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "AssistantDriverId",
                table: "Buses",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "AssistantId",
                table: "Buses",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "DriverId",
                table: "Buses",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "BusId",
                table: "Assistants",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Students_BusId_IsDeleted",
                table: "Students",
                columns: new[] { "BusId", "IsDeleted" });

            migrationBuilder.CreateIndex(
                name: "IX_Buses_AssistantDriverId",
                table: "Buses",
                column: "AssistantDriverId");

            migrationBuilder.CreateIndex(
                name: "IX_Buses_AssistantId",
                table: "Buses",
                column: "AssistantId",
                unique: true,
                filter: "[AssistantId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Buses_DriverId",
                table: "Buses",
                column: "DriverId");

            migrationBuilder.AddForeignKey(
                name: "FK_Buses_Assistants_AssistantId",
                table: "Buses",
                column: "AssistantId",
                principalTable: "Assistants",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Buses_Drivers_AssistantDriverId",
                table: "Buses",
                column: "AssistantDriverId",
                principalTable: "Drivers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Buses_Drivers_DriverId",
                table: "Buses",
                column: "DriverId",
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
    }
}
