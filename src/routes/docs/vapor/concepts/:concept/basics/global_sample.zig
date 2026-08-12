const std = @import("std");
const Vapor = @import("vapor");
const Row = Vapor.Row;
const Button = Vapor.Button;
const Text = Vapor.Text;
const TextFmt = Vapor.TextFmt;

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
    Row().layout(.center).spacing(16).padding(.all(20)).children({
        Button(decrement, .{})
            .shadow(.card(.palette(.text_color)))
            .padding(.all(8))
            .border(.simple(.palette(.text_color)))
            .background(.palette(.background))
            .duration(100)
            .hoverScale()
            .width(.percent(20))
            .cursor(.pointer)
            .children({
            Text("-").font(18, null, .palette(.text_color)).end();
        });

        TextFmt("Global State: {d}", .{count}).font(24, 700, .palette(.text_color)).end();

        Button(increment, .{})
            .shadow(.card(.palette(.text_color)))
            .padding(.all(8))
            .border(.simple(.palette(.text_color)))
            .background(.palette(.background))
            .duration(100)
            .hoverScale()
            .width(.percent(20))
            .cursor(.pointer)
            .children({
            Text("+").font(18, null, .palette(.text_color)).end();
        });
    });
}
