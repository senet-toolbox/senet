const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;

// Global state
var count: i32 = 0;

pub fn init() void {
    // Initialize with starting value
    count = 0;
}

fn increment() void {
    count += 1;
}

fn decrement() void {
    count -= 1;
}

pub fn render() void {
    Static.FlexBox(.{
        .child_alignment = .{ .x = .center, .y = .center },
        .child_gap = 16,
        .padding = .all(20),
    })({
        Pure.Button(decrement, .{
            .padding = .{ .top = 8, .bottom = 8, .left = 16, .right = 16 },
            .border_radius = .all(4),
            .background = .{ 0.2, 0.5, 0.8, 1.0 },
        })({
            Static.Text("-", .{
                .font_size = 18,
                .text_color = .{ 1.0, 1.0, 1.0, 1.0 },
            });
        });

        Pure.AllocText("{d}", .{count}, .{
            .font_size = 24,
            .font_weight = .bold,
        });

        Pure.Button(increment, .{
            .padding = .{ .top = 8, .bottom = 8, .left = 16, .right = 16 },
            .border_radius = .all(4),
            .background = .{ 0.2, 0.5, 0.8, 1.0 },
        })({
            Static.Text("+", .{
                .font_size = 18,
                .text_color = .{ 1.0, 1.0, 1.0, 1.0 },
            });
        });
    });
}

// Usage:
// Call init() once to set initial value
// Then call render() to display the counter
