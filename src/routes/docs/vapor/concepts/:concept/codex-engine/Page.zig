const std = @import("std");
const Vapor = @import("vapor");
const Style = Vapor.Style;
const Vaporize = @import("vaporize");
const Row = Vapor.Row;
const Graphic = Vapor.Graphic;
const Content = @import("../../../../../../components/Content.zig");
const reinit = @import("../../../../../../components/DocNavbar.zig").reinit;
const Compiler = @import("../../../../../../main.zig");
const Fetch = Vapor.Fetch.Fetch;
const Loader = @import("components").Loader;
const Error = @import("components").Error;
const Button = Vapor.Button;

// Initialization

var content: Content.new("") = .{};
var markdown: Compiler.vaporize.MarkDown(.{
    .{ .tag = "compiler_image", .function = compiler_image },
}) = .{};
var page: []const u8 = "";
var f: ?*Fetch = null;
pub fn init() void {
    f = Fetch.fetch("/documents/codex_page.md", .{ .method = .GET });
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

var pos_type: Vapor.Types.PositionType = .relative;
var background: Vapor.Types.Color = .transparent;
pub fn zoom() void {
    pos_type = if (pos_type == .fixed) .relative else .fixed;
    background = if (pos_type == .fixed) .palette(.background) else .transparent;
}

pub fn compiler_image() void {
    Button(zoom, .{})
        .pos(.{ .type = pos_type, .left = .percent(0), .top = .percent(0) })
        .layout(.center)
        .zIndex(999)
        .size(.square_percent(100))
        .background(background)
        .layer(.dot(0.5, 4, .palette(.text_color)))
        .children({
        Graphic(.{ .src = "/src/assets/compiler.svg" }).style(&.{
            .size = .{ .width = .percent(90), .height = .auto },
        }).end();
    });
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
            },
            .err => {
                Error.render();
            },
        }
    }
}
