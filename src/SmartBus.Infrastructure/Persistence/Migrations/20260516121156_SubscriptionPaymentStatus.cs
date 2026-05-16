using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartBus.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class SubscriptionPaymentStatus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Three-phase migration so existing rows preserve their payment
            // state instead of resetting to 0 (Unpaid):
            //   1. Add the new int column with a default of 0.
            //   2. Backfill from the old bool — true → 2 (Paid), false → 0 (Unpaid).
            //   3. Drop the old IsPaid column.
            migrationBuilder.AddColumn<int>(
                name: "PaymentStatus",
                table: "Subscriptions",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.Sql(@"
                UPDATE ""Subscriptions""
                SET ""PaymentStatus"" = CASE WHEN ""IsPaid"" THEN 2 ELSE 0 END;
            ");

            migrationBuilder.DropColumn(
                name: "IsPaid",
                table: "Subscriptions");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Reverse: re-add IsPaid, set it from PaymentStatus (Paid → true,
            // anything else → false — Partial collapses back to false on
            // downgrade since the old schema can't represent it), drop the
            // PaymentStatus column.
            migrationBuilder.AddColumn<bool>(
                name: "IsPaid",
                table: "Subscriptions",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.Sql(@"
                UPDATE ""Subscriptions""
                SET ""IsPaid"" = (""PaymentStatus"" = 2);
            ");

            migrationBuilder.DropColumn(
                name: "PaymentStatus",
                table: "Subscriptions");
        }
    }
}
