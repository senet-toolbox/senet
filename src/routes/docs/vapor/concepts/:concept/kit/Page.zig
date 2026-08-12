const std = @import("std");
const Vapor = @import("vapor");
const Content = @import("../../../../../../components/Content.zig");
const reinit = @import("../../../../../../components/DocNavbar.zig").reinit;
const Compiler = @import("../../../../../../main.zig");
const Fetch = Vapor.Fetch.Fetch;
const Loader = @import("components").Loader;
const Error = @import("components").Error;

// Initialization
var content: Content.new("") = undefined;
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var page: []const u8 = "";
const fetch = Vapor.Kit.Fetch.fetch;
var f: ?*Fetch = null;
pub fn init() void {
    f = Fetch.fetch("/documents/kit_page.md", .{ .method = .GET });
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
            Vapor.onLayout(reinit, .{});
        },
        .err => |err| {
            std.log.err("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
}

pub fn component() void {
    markdown.render() catch unreachable;
}

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
