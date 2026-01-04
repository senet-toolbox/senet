const std = @import("std");
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");
const Content = @import("../../../../../../components/Content.zig");
const Compiler = @import("../../../../../../main.zig");

// Initialization
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var content: Content.new("") = .{};
var markdown_loaded: bool = false;
var page: []const u8 = "";
pub fn init() void {
    content.init();
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/todo/todo_page.md", handlePage, .{ .method = .GET });
}

fn handlePage(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .ok => |data| {
            content.content_text = data.body;
            page = data.body;
            markdown.compile(data.body) catch |err| {
                Vapor.printErr("Failed to compile markdown: {any}", .{err});
                return;
            };
            markdown_loaded = true;
        },
        .err => |err| {
            Vapor.printErr("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
}

fn component() void {
    markdown.render() catch unreachable;
}

pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}
