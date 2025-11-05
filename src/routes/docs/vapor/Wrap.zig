const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Menu = @import("Menu.zig");

// Initialization
pub fn init() void {
    Fabric.registerLayout("/docs/fabric", layout);
}

pub fn layout(page: fn () void) void {
    Static.Box(.{
        .direction = .column,
    })({
        Menu.render({});
        page();
        Static.Text("Wrap", .{
            .font_size = 18,
        });
    });
}

// pub fn render() void {
//     Fabric.useLayout(@src(), );
//     Static.Box(.{})({
//         Static.Text("Page", .{
//             .font_size = 18,
//         });
//     });
// }
