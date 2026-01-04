const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Box = Static.Box;
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
const Icon = Pure.Icon;
const Vaporize = @import("vaporize");
const Compiler = @import("../../../../../../main.zig");

const Page = Vapor.Page;
const CodeEditor = @import("../../../../../../components/CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");
const HtmlText = Custom.Chain.HtmlText;

const Content = @import("../../../../../../components/Content.zig");
var content: Content.new("") = undefined;

var page_sample: CodeEditor = undefined;
var dyanmic_code_editor: CodeEditor = undefined;
var app_example: CodeEditor = undefined;
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
var markdown_loaded: bool = false;

pub fn init() void {
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/routing/routing_page.md", handlePage, .{ .method = .GET });
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
