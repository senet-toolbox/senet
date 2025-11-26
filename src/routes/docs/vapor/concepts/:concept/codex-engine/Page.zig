const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Content = @import("../../../../../../components/Content.zig");
const Compiler = @import("../../../../../../main.zig");
const Button = Vapor.Button;

// Initialization

var content: Content.new("") = .{};
var markdown: Compiler.vaporize.MarkDown(.{
    .{ .tag = "compiler_image", .function = compiler_image },
}) = .{};
var markdown_loaded: bool = false;
var page: []const u8 = "";
pub fn init() void {
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/codex-engine/codex_engine.md", handlePage, .{ .method = .GET });
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

var pos_type: Vapor.Types.PositionType = .relative;
var background: Vapor.Types.Background = .transparent;
pub fn zoom() void {
    pos_type = if (pos_type == .fixed) .relative else .fixed;
    background = if (pos_type == .fixed) .palette(.background) else .transparent;
}

pub fn compiler_image() void {
    Button(.{ .on_press = zoom })
        .pos(.{ .type = pos_type, .left = .percent(0), .top = .percent(0) })
        .layout(.center)
        .zIndex(999)
        .size(.square_percent(100))
        .background(background)
        .layer(.dot(0.5, 4, .palette(.text_color)))
        .children({
        Static.Graphic(.{ .src = "/src/assets/compiler.svg" }).style(&.{
            .size = .{ .width = .percent(90), .height = .auto },
        });
    });
}

fn component() void {
    markdown.render() catch unreachable;
}

pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}
