using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TilmezBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddSubscriptions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Subscriptions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SchoolId = table.Column<Guid>(type: "uuid", nullable: false),
                    MaxStudents = table.Column<int>(type: "integer", nullable: false),
                    MaxBuses = table.Column<int>(type: "integer", nullable: false),
                    ActivationDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ExpirationDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    Price = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    IsPaid = table.Column<bool>(type: "boolean", nullable: false),
                    RemainingAmount = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    SubscriptionType = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Subscriptions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Subscriptions_Schools_SchoolId",
                        column: x => x.SchoolId,
                        principalTable: "Schools",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SubscriptionStudents",
                columns: table => new
                {
                    SubscriptionId = table.Column<Guid>(type: "uuid", nullable: false),
                    StudentId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SubscriptionStudents", x => new { x.SubscriptionId, x.StudentId });
                    table.ForeignKey(
                        name: "FK_SubscriptionStudents_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SubscriptionStudents_Subscriptions_SubscriptionId",
                        column: x => x.SubscriptionId,
                        principalTable: "Subscriptions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Subscriptions_SchoolId_IsActive_ActivationDate_ExpirationDa~",
                table: "Subscriptions",
                columns: new[] { "SchoolId", "IsActive", "ActivationDate", "ExpirationDate" });

            migrationBuilder.CreateIndex(
                name: "IX_SubscriptionStudents_StudentId",
                table: "SubscriptionStudents",
                column: "StudentId");

            // ── Legacy backfill ──────────────────────────────────────────
            // Give every existing school one active "Trial" subscription so
            // the admin panel keeps surfacing its students after this migration
            // (queries now filter by SubscriptionStudents → active Subscription).
            // The subscription is valid for one year; super admin can edit it
            // afterward. Then link every non-deleted student to its school's
            // new subscription in a single CTE.
            migrationBuilder.Sql(@"
WITH new_subs AS (
    INSERT INTO ""Subscriptions"" (
        ""Id"", ""SchoolId"", ""MaxStudents"", ""MaxBuses"",
        ""ActivationDate"", ""ExpirationDate"", ""IsActive"",
        ""Price"", ""IsPaid"", ""RemainingAmount"", ""SubscriptionType"",
        ""CreatedAt"", ""IsDeleted""
    )
    SELECT
        gen_random_uuid(),
        s.""Id"",
        s.""MaxStudents"",
        s.""MaxBuses"",
        (now() AT TIME ZONE 'UTC'),
        (now() AT TIME ZONE 'UTC') + INTERVAL '1 year',
        true,
        0::numeric(12,2),
        false,
        0::numeric(12,2),
        0,
        (now() AT TIME ZONE 'UTC'),
        false
    FROM ""Schools"" s
    WHERE s.""IsDeleted"" = false
    RETURNING ""Id"", ""SchoolId""
)
INSERT INTO ""SubscriptionStudents"" (""SubscriptionId"", ""StudentId"", ""CreatedAt"")
SELECT ns.""Id"", st.""Id"", (now() AT TIME ZONE 'UTC')
FROM new_subs ns
JOIN ""Students"" st
  ON st.""SchoolId""::uuid = ns.""SchoolId""
 AND st.""IsDeleted"" = false;
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SubscriptionStudents");

            migrationBuilder.DropTable(
                name: "Subscriptions");
        }
    }
}
