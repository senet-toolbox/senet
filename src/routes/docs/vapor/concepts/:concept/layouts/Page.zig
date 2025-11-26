const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Button = Static.Button;
const Text = Static.Text;
const Icon = Pure.Icon;
const Content = @import("../../../../../../components/Content.zig");
const Compiler = @import("../../../../../../main.zig");

// Initialization
var content: Content.new("") = undefined;
var page: []const u8 = "";
var markdown_loaded: bool = false;
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
pub fn init() void {
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/layouts/layout_page.md", handlePage, .{ .method = .GET });
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

// Render
pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}
