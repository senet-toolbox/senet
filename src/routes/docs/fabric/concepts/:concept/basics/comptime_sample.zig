const std = @import("std");
const Fabric = @import("fabric");
const Element = Fabric.Element;
const Signal = Fabric.Signal;
const Static = Fabric.Static;
const Pure = Fabric.Pure;

pub fn Counter(comptime T: type, initial_value: T) type {
    return struct {
        const Self = @This();

        count: *Signal(T),
        allocator: *std.mem.Allocator,

        pub fn init(counter: *Self, allocator: *std.mem.Allocator) void {
            counter.* = .{
                .count = Signal(T).init(initial_value, allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit(counter: *Self) void {
            counter.count.deinit();
        }

        fn increment(counter: *Self) void {
            counter.count.set(counter.count.get() + 1);
        }

        fn decrement(counter: *Self) void {
            counter.count.set(counter.count.get() - 1);
        }

        pub fn render(counter: *Self) void {
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

                Pure.AllocText("{d}", .{counter.count.get()}, .{
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
    };
}

// Usage examples:
// var int_counter = Counter(i32, 0){};
// var float_counter = Counter(f32, 0.5){};
// var u8_counter = Counter(u8, 10){};
//
// int_counter.init(&allocator);
// defer int_counter.deinit();
// int_counter.render();

