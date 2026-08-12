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
const Page = Vapor.Page;
const Row = Vapor.Row;

var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var page: []const u8 = "";
var f: ?*Fetch = null;
var content: Content.new("") = undefined;

var generated_markdown: Compiler.vaporize.MarkDown(.{}) = .{};

pub fn init() void {
    Page(.{ .route = "react-to-vapor" }, render, null);

    f = Fetch.fetch("/documents/react_to_vapor_page.md", .{ .method = .GET });
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
                Row().style(&.{
                    .size = .w(.percent(100)),
                    .layout = .top_center,
                    .padding = .tblr(64, 64, 12, 12),
                    .visual = .{
                        .layer = .grid(32, 1, .transparentizeHex(.palette(.grid_color), 0.9)),
                        .border = .{
                            .thickness = .lr(1),
                            .color = .palette(.border_color_light),
                        },
                    },
                    .position = .relative,
                }).children({
                    Row().style(&.{
                        .size = .w(.percent(80)),
                        .child_gap = 16,
                        .direction = .column,
                        .layout = .{ .x = .start, .y = .start },
                    }).children({
                        Row().style(&.{
                            .child_gap = 4,
                            .direction = .column,
                            .size = .hw(.percent(100), .percent(100)),
                            .layout = .{},
                        }).children({
                            component();
                        });
                    });
                });
                // content.content(component);
            },
            .err => {
                Error.render();
            },
        }
    }
}
