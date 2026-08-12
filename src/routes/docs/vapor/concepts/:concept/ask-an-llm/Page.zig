const std = @import("std");
const Vapor = @import("vapor");
const Style = Vapor.Style;
const Vaporize = @import("vaporize");
const Row = Vapor.Row;
const Content = @import("../../../../../../components/Content.zig");
const reinit = @import("../../../../../../components/DocNavbar.zig").reinit;
const Compiler = @import("../../../../../../main.zig");
const Fetch = Vapor.Fetch.Fetch;
const Loader = @import("components").Loader;
const Error = @import("components").Error;
const Button = Vapor.Button;
const Icon = Vapor.Icon;
const Text = Vapor.Text;

// Initialization

var content: Content.new("") = .{};
var markdown: Compiler.vaporize.MarkDown(.{
    .{ .tag = "copy_content", .function = CopyContent },
}) = .{};
var page: []const u8 = "";
var f: ?*Fetch = null;
var llm_f: ?*Fetch = null;
var llm_content: []const u8 = "";
pub fn init() void {
    f = Fetch.fetch("/documents/ask_an_llm.md", .{ .method = .GET });
    f.?.handle(handlePage, .{});
    content.init();
    llm_f = Fetch.fetch("/documents/learn_via_llm.md", .{ .method = .GET });
    llm_f.?.handle(handleLLMPage, .{});
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

fn handleLLMPage(resp: Vapor.Fetch.Result) void {
    switch (resp) {
        .ok => |data| {
            llm_content = Vapor.dupe(data.body, .persist);
        },
        .err => |err| {
            std.log.err("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.onLayout(reinit, .{});
}

var pos_type: Vapor.Types.PositionType = .relative;
var background: Vapor.Types.Background = .transparent;
pub fn zoom() void {
    pos_type = if (pos_type == .fixed) .relative else .fixed;
    background = if (pos_type == .fixed) .palette(.background) else .transparent;
}

var copied: bool = false;
fn copy() void {
    Vapor.Clipboard.copy(llm_content);
    copied = true;
    Vapor.timeout("markdown_copy", 1000, toggleIcon, .{{}});
}

fn toggleIcon(_: void) void {
    copied = false;
}

pub fn CopyContent() void {
    Button(copy, .{})
        .ariaLabel("copy-llm-content")
        .style(&.{
            .visual = .{ .background = .transparent, .cursor = .pointer },
            .size = .w(.fit),
            .child_gap = 12,
            .padding = .tb(8, 8),
            .layout = .right_center,
            .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
        }).children({
        Text("Copy LLM Context File").font(16, 700, null).end();
        if (copied) {
            Icon(.check).style(&.{
                .visual = .{ .font_size = 16 },
            }).end();
        } else {
            Icon(.clipboard).style(&.{
                .visual = .{ .font_size = 16 },
            }).end();
        }
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
