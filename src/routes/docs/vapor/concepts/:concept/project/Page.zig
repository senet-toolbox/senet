const std = @import("std");
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");
const Content = @import("../../../../../../components/Content.zig");
const Compiler = @import("../../../../../../main.zig");

// Initialization
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var markdown_loaded: bool = false;
var page: []const u8 = "";
var content: Content.new("") = .{};
pub fn init() void {
    Vapor.Kit.fetch("/documents/project_structure_page.md", handlePage, .{ .method = .GET });
    content.init();
}

fn handlePage(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .Ok => |data| {
            content.content_text = data.body;
            page = data.body;
            markdown.compile(data.body) catch |err| {
                Vapor.printErr("Failed to compile markdown: {any}", .{err});
                return;
            };
            markdown_loaded = true;
        },
        .Err => |err| {
            Vapor.printErr("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.cycle();
}

fn component() void {
    markdown.render() catch unreachable;
}

pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}
