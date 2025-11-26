const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Button = Static.Button;
const Text = Static.Text;
const TextFmt = Static.TextFmt;
const TextField = Static.TextField;

// Initialize Vapor
export fn init() void {
    Vapor.init(.{});
    Vapor.Page(.{ .route = "/" }, Counter, null);
}

var counter: u32 = 0;
fn increment() void {
    counter += 1;
}

fn logText(evt: *Vapor.Event) void {
    Vapor.print("From Text: {s}", .{evt.text()});
}

fn Counter() void {
    TextField(.string).onChange(logText).end();
    Button(.{ .on_press = increment }).children({
        Text("Increment").end();
    });
    TextFmt("{d}", .{counter}).end();
}
