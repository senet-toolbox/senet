const std = @import("std");
const Vapor = @import("vapor");
const Compiler = @import("../../../../../../main.zig");
const Fetch = Vapor.Fetch.Fetch;
const Loader = @import("components").Loader;
const Error = @import("components").Error;
const Content = @import("../../../../../../components/Content.zig");
const reinit = @import("../../../../../../components/DocNavbar.zig").reinit;
const Vaporize = @import("vaporize");
const Stack = Vapor.Stack;
const Text = Vapor.Text;

var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var page: []const u8 = "";
var f: ?*Fetch = null;
var content: Content.new("") = undefined;

var generated_markdown: Compiler.vaporize.MarkDown(.{}) = .{};

pub fn init() void {
    f = Fetch.fetch("/documents/animations_page.md", .{ .method = .GET });
    f.?.handle(handlePage, .{});
    content.init();
}

fn handlePage(resp: Vapor.Fetch.Result) void {
    switch (resp) {
        .ok => |data| {
            content.content_text = data.body;
            page = data.body;
            markdown.compile(page) catch |err| {
                std.log.err("Failed to compile markdown: {any}", .{err});
                return;
            };
        },
        .err => |err| {
            std.log.err("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.onLayout(reinit, .{});
}

fn component() void {
    markdown.render() catch unreachable;
}

// Render
pub fn render() void {
    if (f) |h| {
        switch (h.state()) {
            .idle => {},
            .loading => {
                Loader.render();
            },
            .ok => {
                content.content(component);
            },
            .err => {
                Error.render();
            },
        }
    }
}
