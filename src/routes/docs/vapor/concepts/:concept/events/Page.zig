const std = @import("std");
const Fabric = @import("vapor");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Content = @import("../../../../../../components/Content.zig");

// Initialization
var sample_events: CodeEditor = undefined;
var sample_inst_events: CodeEditor = undefined;
var events_page: *Vaporize.Node = undefined;
var content: Content.new(@embedFile("events_page.md")) = undefined;
pub fn init() void {
    content.init();
    var parser = Vaporize.Parser.init(Fabric.lib.allocator_global, @embedFile("events_page.md"));
    events_page = parser.parse() catch unreachable;
}

fn component() void {
    Vaporize.traverse(events_page, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color),
        .heading_color = .palette(.text_color),
    }, void, null) catch unreachable;
}

pub fn render() void {
    content.content(component);
}
