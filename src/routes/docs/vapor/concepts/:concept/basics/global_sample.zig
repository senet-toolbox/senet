const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Pure = Vapor.Pure;

// Global state
var count: i32 = 0;
fn increment() void {
    count += 1;
    Vapor.cycle();
}

fn decrement() void {
    count -= 1;
    Vapor.cycle();
}

pub fn render(_: *anyopaque) void {
    Static.Box.layout(.center).spacing(16).padding(.all(20)).body()({
        Static.Button(.{ .on_press = decrement })
            .padding(.all(8))
            .border(.simple(.palette(.border_color_light)))
            .cursor(.pointer)
            .body()({
            Static.Text("-").font(18, null, .palette(.text_color)).close();
        });

        Static.TextFmt("Global State: {d}", .{count}).font(24, 700, .palette(.text_color)).close();

        Static.Button(.{ .on_press = increment })
            .padding(.all(8))
            .border(.simple(.palette(.border_color_light)))
            .cursor(.pointer)
            .body()({
            Static.Text("+").font(18, null, .palette(.text_color)).close();
        });
    });
}

