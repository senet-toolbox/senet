const MyTable = Table(Transaction, &.{
    .{ .title = "Status", .key = "status" },
    .{ .title = "Email", .key = "email" },
    .{ .title = "Amount", .key = "amount" },
}, .{
    .actions = &.{
        .{ .label = "View", .icon = .eye, .on_action = handleView },
        .{ .label = "Edit", .icon = .pencil, .on_action = handleEdit },
        .{ .label = "Delete", .icon = .trash, .on_action = handleDelete },
    },
});

var table: MyTable = undefined;

fn handleView(item: *Transaction) void {
    Vapor.alert("Viewing: {s}", .{item.email});
}

fn handleEdit(item: *Transaction) void {
    Vapor.alert("Editing: {s}", .{item.email});
}

fn handleDelete(item: *Transaction) void {
    Vapor.alert("Deleting: {s}", .{item.email});
}

pub fn init() void {
    table.init(data.items);
}

pub fn render() void {
    Box()
        .width(.percent(100))
        .height(.fit)
        .children({
        table.render();
    });
}
