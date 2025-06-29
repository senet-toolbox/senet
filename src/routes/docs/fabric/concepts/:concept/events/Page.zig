const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");

// Initialization
var sample_events: CodeEditor = undefined;
var sample_inst_events: CodeEditor = undefined;
pub fn init() void {
    sample_events.init(&Fabric.lib.allocator_global, @embedFile("events_sample.zig"));
    sample_inst_events.init(&Fabric.lib.allocator_global, @embedFile("inst_even_sample.zig"));
}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

pub fn render() void {
    Static.FlexBox(.{
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Events and Handlers", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt("Events and Handlers in Fabric use a very similar approach to fetching. We pass a callback which is called when an event is triggered.");
        Static.Svg(@embedFile("event.svg"), .{
            .width = .percent(100),
            .height = .percent(100),
        });
        Txt("There are element event listeners and global event lisenters. Each takes a callback function and returns the callback id, which can then be used to unMount the listener.");
        sample_events.render(0);
        Static.Text("addListener(*Element, EventType, *const fn (event: *Fabric.Event) void)", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Txt("We take and Element, an event type and callback. This Callback is ran when an event is triggered.");
        Static.Text("addInstListener(*Element, EventType, anytype, anytype)", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Txt("We take and Element, an event type, and then any set of of arguments, as well as a callback that includes the Event. This Callback is ran when an event is triggered.");
        Txt("We can now pass a argument along with the Event to the Callback, and use the event to change fields or alter the additional arguments passed.");

        sample_inst_events.render(0);
    });
}
