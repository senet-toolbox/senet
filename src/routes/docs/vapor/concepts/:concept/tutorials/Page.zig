const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Page = Vapor.Page;
const Custom = @import("../../../../../../components/Custom.zig");
const Kit = Vapor.Kit;
const CodeEditor = @import("../CodeEditor.zig");
const Content = @import("../../../../../../components/Content.zig");
const Vaporize = @import("vaporize");
const Compiler = @import("../../../../../../main.zig");

// Initialization
var content: Content.new("") = undefined;
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var page: []const u8 = "";
var markdown_loaded: bool = false;
pub fn init() void {
    Vapor.Kit.fetch("/documents/tutorial_page.md", handlePage, .{ .method = .GET });
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
    if (!markdown_loaded) return;
    content.content(component);
}
