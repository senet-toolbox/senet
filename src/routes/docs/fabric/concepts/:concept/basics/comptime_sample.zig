const std = @import("std");
const Fabric = @import("fabric");
const Element = Fabric.Element;
const Signal = Fabric.Signal;
const Static = Fabric.Static;
const Pure = Fabric.Pure;

pub fn Counter(comptime T: type, initial_value: T) type {
    return struct {
        const Self = @This();

        var count: Signal(T) = undefined;

        pub fn init() void {
            count.init(initial_value);
        }

        pub fn deinit() void {
            count.deinit();
        }

        fn increment() void {
            count.set(count.get() + 1);
        }

        fn decrement() void {
            count.set(count.get() - 1);
        }

        pub fn render() void {
            Static.Box(.{
                .child_alignment = .{ .x = .center, .y = .center },
                .child_gap = 16,
                .padding = .all(20),
            })({
                Pure.Button(.{ .onPress = decrement, .aria_label = "decrement" }, .{
                    .padding = .{ .top = 8, .bottom = 8, .left = 16, .right = 16 },
                    .border_radius = .all(4),
                    .background = .{ 0.2, 0.5, 0.8, 1.0 },
                })({
                    Static.Text("-", .{
                        .font_size = 18,
                        .text_color = .{ 1.0, 1.0, 1.0, 1.0 },
                    });
                });

                Pure.AllocText("{d}", .{count.get()}, .{
                    .font_size = 24,
                    .font_weight = .bold,
                });

                Pure.Button(.{ .onPress = increment, .aria_label = "increment" }, .{
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
