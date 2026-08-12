const std = @import("std");
const Vapor = @import("vapor");
const Allocator = std.mem.Allocator;
const Signal = Vapor.Signal;
const Row = Vapor.Row;
const Button = Vapor.Button;
const Text = Vapor.Text;
const TextFmt = Vapor.TextFmt;

/// Counter component
const Counter = @This();

initial_value: i32 = 0,
count: Signal(i32) = undefined,

fn increment(counter: *Counter) void {
    counter.count.increment();
}

fn decrement(counter: *Counter) void {
    counter.count.decrement();
}

/// The init function instantiates the local allocator and component signals for the counter
/// The counter.initial_value field is used as the starting value
pub fn init(counter: *Counter) void {
    counter.count.init(counter.initial_value);
}

pub fn deinit(counter: *Counter) void {
    counter.count.deinit();
}

pub fn render(counter: *Counter) void {
    Row().layout(.center).spacing(16).padding(.all(20)).children({
        Button(decrement, .{counter})
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

        TextFmt("Instance State: {d}", .{counter.count.get()}).font(24, 700, .palette(.text_color)).end();

        Button(increment, .{counter})
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
