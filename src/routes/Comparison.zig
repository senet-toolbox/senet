const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Custom = @import("../components/Custom.zig");
const CodeEditor = @import("docs/vapor/concepts/:concept/CodeEditor.zig");

// Initialization
var nextjs: CodeEditor = undefined;
var vapor_sample: CodeEditor = undefined;
pub fn init() void {
    nextjs.init(&Vapor.lib.allocator_global, @embedFile("nextjs.js"));
    vapor_sample.init(&Vapor.lib.allocator_global, @embedFile("vapor_sample.zig"));
}

pub fn render() void {
    Static.Row(.{
        .child_gap = 64,
        .direction = .row,
        .width = .percent(80),
        .height = .percent(100),
        // .child_alignment = .{ .x = .between, .y = .start },
    })({
        nextjs.render(0);
        vapor_sample.render(0);
    });
}
