const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Content = @import("../../../../../../components/Content.zig");
var content: Content.new(@embedFile("project_page.md")) = .{};

// Initialization
var sample_events: CodeEditor = undefined;
var sample_inst_events: CodeEditor = undefined;
var project_page: *Vaporize.Node = undefined;
pub fn init() void {
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("project_page.md"));
    project_page = parser.parse() catch unreachable;
}

fn component() void {
    Vaporize.traverse(project_page, .{
        .code_style = .{ .visual = .{ .text_color = .palette(.tint) } },
        .text_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
        .heading_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
    }, void, null) catch unreachable;
}

pub fn render() void {
    content.content(component);
}
