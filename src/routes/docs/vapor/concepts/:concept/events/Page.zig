const std = @import("std");
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");
const Content = @import("../../../../../../components/Content.zig");
const Compiler = @import("../../../../../../main.zig");

// Initialization
var content: Content.new("") = undefined;
var page: []const u8 = "";
var markdown_loaded: bool = false;
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
pub fn init() void {
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/events/events_page.md", handlePage, .{ .method = .GET });
    content.init();
}

fn handlePage(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .ok => |data| {
            content.content_text = data.body;
            page = data.body;
            markdown.compile(page) catch |err| {
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
    Vapor.cycle();
}

fn component() void {
    markdown.render() catch unreachable;
}

pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}
