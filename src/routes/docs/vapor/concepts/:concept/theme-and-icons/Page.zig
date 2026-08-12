const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Vaporize = @import("vaporize");
const Row = Vapor.Row;
const Custom = @import("../../../../../../components/Custom.zig");
const Content = @import("../../../../../../components/Content.zig");
const reinit = @import("../../../../../../components/DocNavbar.zig").reinit;
const snippet = Custom.code_snippet_single;
const Compiler = @import("../../../../../../main.zig");
const Fetch = Vapor.Fetch.Fetch;
const Loader = @import("components").Loader;
const Error = @import("components").Error;

const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const TextFmt = Static.TextFmt;

// Initialization
var content: Content.new("") = undefined;
var page: []const u8 = "";
var f: ?*Fetch = null;
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};

pub fn init() void {
    f = Fetch.fetch("/documents/themes_icons_page.md", .{ .method = .GET });
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

pub fn render() void {
    if (f) |h| {
        switch (h.state()) {
            .idle => {},
            .loading => {
                Loader.render();
            },
            .ok => {
                content.content(component);
                Row()
                    .background(.palette(.background))
                    .border(.simple(.palette(.border_color)))
                    .font(16, 500, .palette(.text_color))
                    .children({
                    //...
                });
            },
            .err => {
                Error.render();
            },
        }
    }
}
