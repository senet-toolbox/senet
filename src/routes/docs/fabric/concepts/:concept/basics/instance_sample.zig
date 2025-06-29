const std = @import("std");
const Fabric = @import("fabric");
const Allocator = std.mem.Allocator;
const Signal = Fabric.Signal;
const Static = Fabric.Static;
const Pure = Fabric.Pure;

/// Counter component
const Counter = @This();

initial_value: i32 = 0,
_count: *Signal(i32) = undefined,
_local_allocator: *Allocator = undefined,

fn increment(counter: *Counter) void {
    counter._count.set(counter._count.get() + 1);
}

fn decrement(counter: *Counter) void {
    counter._count.set(counter._count.get() - 1);
}

/// The init function instantiates the local allocator and component signals for the counter
/// The counter.initial_value field is used as the starting value
pub fn init(counter: *Counter, allocator: *Allocator) void {
    counter._count = Signal(i32).init(counter.initial_value, allocator);
    counter._local_allocator = allocator;
}

pub fn deinit(counter: *Counter) void {
    counter._count.deinit();
    counter._local_allocator = undefined;
}

pub fn render(counter: *Counter) void {
    Static.FlexBox(.{
        .child_alignment = .{ .x = .center, .y = .center },
        .child_gap = 16,
        .padding = .all(20),
    })({
        Pure.CtxButton(decrement, .{counter}, .{
            .padding = .{ .top = 8, .bottom = 8, .left = 16, .right = 16 },
            .border_radius = .all(4),
            .background = .{ 0.2, 0.5, 0.8, 1.0 },
        })({
            Static.Text("-", .{
                .font_size = 18,
                .text_color = .{ 1.0, 1.0, 1.0, 1.0 },
            });
        });

        Pure.AllocText("{d}", .{counter._count.get()}, .{
            .font_size = 24,
            .font_weight = .bold,
        });

        Pure.CtxButton(increment, .{counter}, .{
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

// Usage example:
// var counter = Counter{ .initial_value = 5 };
// counter.init(&allocator);
// defer counter.deinit();
// counter.render();
