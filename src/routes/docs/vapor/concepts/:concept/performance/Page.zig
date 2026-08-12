const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Vaporize = @import("vaporize");
const Row = Static.Row;
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
    f = Fetch.fetch("/documents/performance_page.md", .{ .method = .GET });
    f.?.handle(handlePage, .{});
    content.init();

    list = std.array_list.Managed(Item).init(Vapor.lib.allocator_global);
    for (0..buffer.len) |i| {
        buffer[i] = .{ .value = i, .id = std.fmt.allocPrint(Vapor.lib.allocator_global, "{d}", .{i}) catch unreachable };
    }
    list.appendSlice(&buffer) catch |err| Vapor.lib.printlnErr("Error appending {any}", .{err});
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

const Item = struct { id: []const u8, value: usize };
var buffer: [100]Item = undefined;
var list: std.array_list.Managed(Item) = undefined;

fn remove() void {
    if (list.items.len == 0) return;
    const item = list.orderedRemove(0);
    Vapor.println("Removed {s}", .{item.id});
    Vapor.cycle();
}

fn component() void {
    markdown.render() catch unreachable;
    // snippet("metal create fullstack myapp");
    // Button(.{ .on_press = remove })
    //     .size(.{ .width = .fit, .height = .fit })
    //     .background(.transparent)
    //     .cursor(.pointer)
    //     .border(.simple(.palette(.border_color_light)))
    //     .children({
    //     TextFmt("Remove first Item", .{}).font(18, 500, .palette(.text_color)).layout(.center).end();
    // });
    // Row().layout(.flex)
    //     .wrap(.wrap)
    //     .children({
    //     for (list.items) |i| {
    //         TextFmt("{d},", .{i.value}).font(18, 500, .palette(.text_color)).layout(.center).end();
    //     }
    // });
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
    // Row().style(&.{
    //     .child_gap = 8,
    //     .direction = .column,
    //     .margin = .{ .bottom = 32 },
    //     .size = .w(.percent(100)),
    // })({
    //     Vaporize.traverse(performance_page, .{
    //         .code_color = .palette(.tint),
    //         .text_color = .palette(.text_color),
    //         .heading_color = .palette(.text_color),
    //     }, void, null) catch unreachable;
    //     snippet("metal create fullstack myapp");
    //     Button(.{ .on_press = remove })
    //         .size(.{ .width = .fit, .height = .fit })
    //         .background(.transparent)
    //         .cursor(.pointer)
    //         .border(.simple(.palette(.border_color_light)))
    //         .children({
    //         TextFmt("Remove first Item", .{}).font(18, 500, .palette(.text_color)).layout(.center).end();
    //     });
    //     Row().layout(.flex)
    //         .wrap(.wrap)
    //         .children({
    //         for (list.items) |i| {
    //             TextFmt("{d},", .{i.value}).font(18, 500, .palette(.text_color)).layout(.center).end();
    //         }
    //     });
    // });
}
