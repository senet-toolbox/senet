const std = @import("std");
const Vapor = @import("vapor");
const Page = Vapor.Page;
const Custom = @import("../../../../../../components/Custom.zig");
const Kit = Vapor.Kit;
const Content = @import("../../../../../../components/Content.zig");
const Vaporize = @import("vaporize");
const Compiler = @import("../../../../../../main.zig");

// Initialization
var content: Content.new("") = undefined;
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var page: []const u8 = "";
var markdown_loaded: bool = false;
var vaporizer: Vaporize.Compiler = undefined;

pub fn init() void {
    Vapor.Kit.fetch("/documents/common_patterns_page.md", handlePage, .{ .method = .GET });
}

fn handlePage(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .Ok => |data| {
            content.content_text = data.body;
            page = data.body;
            markdown.compile(page) catch |err| {
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
    if (!markdown_loaded) return;
    markdown.render() catch unreachable;
}

pub fn render() void {
    content.content(component);
}
