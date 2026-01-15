const MyTable = Table(Transaction, &.{
    .{ .title = "Status", .key = "status", .filter = true },  // Enum dropdown filter
    .{ .title = "Email", .key = "email", .search = true },    // Text search
    .{ .title = "Amount", .key = "amount" },
}, .{});

var table: MyTable = undefined;

pub fn init() void {
    table.init(data.items);
}

pub fn render() void {
    // Click the funnel icon to filter by status enum values
    // Click the search icon to search email text
    Box()
        .width(.percent(100))
        .height(.fit)
        .children({
        table.render();
    });
}
