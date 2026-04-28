using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddEmployeeQrTokens : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "EmployeeQrTokens",
                columns: table => new
                {
                    Id              = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Token           = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                    SchoolId        = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Type            = table.Column<int>(type: "int", nullable: false),
                    IsUsed          = table.Column<bool>(type: "bit", nullable: false),
                    UsedAt          = table.Column<DateTime>(type: "datetime2", nullable: true),
                    UsedDriverId    = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    UsedAssistantId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    CreatedAt       = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt       = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted       = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EmployeeQrTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EmployeeQrTokens_Schools_SchoolId",
                        column: x => x.SchoolId,
                        principalTable: "Schools",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_EmployeeQrTokens_Token",
                table: "EmployeeQrTokens",
                column: "Token",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_EmployeeQrTokens_SchoolId_Type_IsUsed",
                table: "EmployeeQrTokens",
                columns: new[] { "SchoolId", "Type", "IsUsed" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "EmployeeQrTokens");
        }
    }
}
