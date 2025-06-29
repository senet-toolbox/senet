const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Navbar = @import("../../components/Navbar.zig");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Style = Fabric.Style;
pub fn init() void {
    Fabric.Page(@src(), render, null, .{});
}

pub fn render() void {
    Navbar.render();
    Static.FlexBox(.{
        .height = .percent(100),
        .width = .percent(100),
        .padding = .{ .top = 120 },
    })({
        Static.FlexBox(.{
            .width = .percent(62),
            .height = .percent(100),
            .child_gap = 16,
            .direction = .column,
            .child_alignment = .{ .x = .start, .y = .start },
        })({
            Static.Text("Fabric", .{
                .font_size = 56,
                .font_weight = 700,
            });
            Static.Text("Documentation for Fabric", .{
                .font_size = 18,
                .text_color = .hex("#666666"),
            });
            Static.Text("Tether", .{
                .font_size = 56,
                .font_weight = 700,
            });
            Static.Text("Treehouse", .{
                .font_size = 56,
                .font_weight = 700,
            });
        });
    });
}
