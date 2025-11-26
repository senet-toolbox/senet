const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;

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

pub fn render() void {
    Static.Box().layout(.center).spacing(16).padding(.all(20)).children({
        Static.Button(.{ .on_press = decrement })
            .padding(.all(8))
            .border(.simple(.palette(.border_color_light)))
            .cursor(.pointer)
            .children({
            Static.Text("-").font(18, null, .palette(.text_color)).end();
        });

        Static.TextFmt("Global State: {d}", .{count}).font(24, 700, .palette(.text_color)).end();

        Static.Button(.{ .on_press = increment })
            .padding(.all(8))
            .border(.simple(.palette(.border_color_light)))
            .cursor(.pointer)
            .children({
            Static.Text("+").font(18, null, .palette(.text_color)).end();
        });
    });
}

