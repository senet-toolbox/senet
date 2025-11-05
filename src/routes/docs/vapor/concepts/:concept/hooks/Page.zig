const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Page = Vapor.Page;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");
const Box = Static.Box;
const Vaporize = @import("vaporize");
const Content = @import("../../../../../../components/Content.zig");

// Initialization
var sample_hooks: CodeEditor = undefined;
var content: Content.new(@embedFile("hooks_page.md")) = undefined;
var hooks_page: *Vaporize.Node = undefined;
pub fn init() void {
    content.init();
    var parser = Vaporize.Parser.init(Vapor.getPersistentAllocator(), @embedFile("hooks_page.md"));
    hooks_page = parser.parse() catch unreachable;
    // sample_hooks.init(&Vapor.lib.allocator_global, @embedFile("sample_hooks.zig"));
}

fn component() void {
    Vaporize.traverse(hooks_page, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color),
        .heading_color = .palette(.text_color),
    }, void, null) catch unreachable;
}

// Render
pub fn render() void {
    content.content(component);
}
