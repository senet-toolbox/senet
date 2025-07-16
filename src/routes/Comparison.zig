const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Custom = @import("../components/Custom.zig");
const CodeEditor = @import("docs/fabric/concepts/:concept/CodeEditor.zig");

// Initialization
var nextjs: CodeEditor = undefined;
var fabric_sample: CodeEditor = undefined;
pub fn init() void {
    nextjs.init(&Fabric.lib.allocator_global, @embedFile("nextjs.js"));
    fabric_sample.init(&Fabric.lib.allocator_global, @embedFile("fabric_sample.zig"));
}

pub fn render() void {
    Static.Box(.{
        .child_gap = 64,
        .direction = .row,
        .width = .percent(80),
        .height = .percent(100),
        // .child_alignment = .{ .x = .between, .y = .start },
    })({
        nextjs.render(0);
        fabric_sample.render(0);
    });
}
