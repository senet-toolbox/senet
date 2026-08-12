const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Row = Static.Row;
const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const Center = Static.Center;
const List = Static.List;
const ListItem = Static.ListItem;
const Stack = Static.Stack;
const Graphic = Static.Graphic;
const Vaporize = @import("vaporize");
const Compiler = @import("../../../../../../main.zig");
const Fetch = Vapor.Fetch.Fetch;
const Loader = @import("components").Loader;
const Error = @import("components").Error;

const Page = Vapor.Page;
const Custom = @import("../../../../../../components/Custom.zig");
const HtmlText = Custom.Chain.HtmlText;

const Content = @import("../../../../../../components/Content.zig");
const reinit = @import("../../../../../../components/DocNavbar.zig").reinit;
var content: Content.new("") = undefined;

const items: []const []const u8 = &.{
    "Compiles to WASM and sent down the wire, resulting in client side rendering.",
    "Browser parse WASM 10x-20x faster than JS",
    "WASM is 1.5x-4x faster during runtime",
    "Embed your favorite JS Libraries",
    "Construct or modify GLUE the WASM Bridge",
    "Vapor only allocates at start up, no memory is allocated during runtime.",
    "Only Zig no html, js, ts, tsx, rsx, jsx",
};
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var page: []const u8 = "";
var f: ?*Fetch = null;

pub fn init() void {
    f = Fetch.fetch("/documents/routing_page.md", .{ .method = .GET });
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
