const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Custom = @import("../../../../../../components/Custom.zig");
const Content = @import("../../../../../../components/Content.zig");
const snippet = Custom.code_snippet_single;
const Compiler = @import("../../../../../../main.zig");

const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const TextFmt = Static.TextFmt;

// Initialization
var sample_events: CodeEditor = undefined;
var sample_inst_events: CodeEditor = undefined;
var content: Content.new("") = undefined;
var markdown_loaded: bool = false;
var page: []const u8 = "";
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};

pub fn init() void {
    Vapor.Kit.fetch("/documents/themes_icons_page.md", handlePage, .{ .method = .GET });
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
    markdown.render() catch unreachable;
}

pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
    Box()
        .background(.palette(.background))
        .border(.simple(.palette(.border_color)))
        .font(16, 500, .palette(.text_color))
        .children({
        //...
    });
}
