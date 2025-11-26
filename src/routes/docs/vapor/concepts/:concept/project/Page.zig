const std = @import("std");
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");
const Content = @import("../../../../../../components/Content.zig");
const Compiler = @import("../../../../../../main.zig");

// Initialization
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var content: Content.new(@embedFile("project_page.md")) = .{};
pub fn init() void {
    content.init();
    markdown.compile(@embedFile("project_page.md")) catch unreachable;
}

fn component() void {
    markdown.render() catch unreachable;
}

pub fn render() void {
    content.content(component);
}
