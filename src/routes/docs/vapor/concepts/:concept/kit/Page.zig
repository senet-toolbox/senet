const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Page = Vapor.Page;
const CodeEditor = @import("../CodeEditor.zig");
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Content = @import("../../../../../../components/Content.zig");

// Initialization
var sample_fetch: CodeEditor = undefined;
var kit_page: *Vaporize.Node = undefined;
var content: Content.new(@embedFile("kit_page.md")) = undefined;
pub fn init() void {
    content.init();
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("kit_page.md"));
    kit_page = parser.parse() catch unreachable;
}

fn component() void {
    Vaporize.traverse(kit_page, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color),
        .heading_color = .palette(.text_color),
    }, void, null) catch unreachable;
}

pub fn render() void {
    content.content(component);
}
