const MyTable = Table(Transaction, &.{
    .{ .title = "Status", .key = "status", .sort = .asc },
    .{ .title = "Email", .key = "email", .sort = .asc },
    .{ .title = "Amount", .key = "amount", .sort = .desc },
}, .{});

var table: MyTable = undefined;

pub fn init() void {
    table.init(data.items);
}

pub fn render() void {
    // Click sort icons to toggle between ascending/descending
    // Supports strings, enums, and numeric types
    Box()
        .width(.percent(100))
        .height(.fit)
        .children({
        table.render();
    });
}
