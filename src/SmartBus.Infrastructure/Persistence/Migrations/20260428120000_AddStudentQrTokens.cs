using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddStudentQrTokens : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "StudentQrTokens",
                columns: table => new
                {
                    Id           = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Token        = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                    SchoolId     = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    IsRegistered = table.Column<bool>(type: "bit", nullable: false),
                    RegisteredAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    StudentId    = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    CreatedAt    = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt    = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted    = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StudentQrTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StudentQrTokens_Schools_SchoolId",
                        column: x => x.SchoolId,
                        principalTable: "Schools",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_StudentQrTokens_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateIndex(
                name: "IX_StudentQrTokens_Token",
                table: "StudentQrTokens",
                column: "Token",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_StudentQrTokens_SchoolId_IsRegistered",
                table: "StudentQrTokens",
                columns: new[] { "SchoolId", "IsRegistered" });

            migrationBuilder.CreateIndex(
                name: "IX_StudentQrTokens_StudentId",
                table: "StudentQrTokens",
                column: "StudentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "StudentQrTokens");
        }
    }
}
