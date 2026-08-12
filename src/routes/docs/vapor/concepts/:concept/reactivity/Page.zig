const std = @import("std");
const Vapor = @import("vapor");
const Page = Vapor.Page;
const Vaporize = @import("vaporize");
const Compiler = @import("../../../../../../main.zig");
const Fetch = Vapor.Fetch.Fetch;
const Loader = @import("components").Loader;
const Error = @import("components").Error;
const Content = @import("../../../../../../components/Content.zig");
const reinit = @import("../../../../../../components/DocNavbar.zig").reinit;
const Row = Vapor.Row;
const Text = Vapor.Text;
const Button = Vapor.Button;
const TextFmt = Vapor.TextFmt;
const Stack = Vapor.Stack;

// Initialization
var markdown: Compiler.vaporize.MarkDown(.{
    .{ .tag = "counter", .function = counter },
    .{ .tag = "cycle_example", .function = cycleExample },
    .{ .tag = "graphics", .function = graphics },
}) = .{};
var page: []const u8 = "";
var f: ?*Fetch = null;
var content: Content.new("") = .{};

var count: i32 = 0;
fn increment() void {
    count += 1;
    text = "Increment Again";
}

var text: []const u8 = "Increment";
var count2: u32 = 0;
fn increment_cycle() void {
    count2 += 1;
}

fn graphics() void {
    Row().style(&.{
        .size = .{ .width = .percent(100), .height = .percent(100) },
        .padding = .tb(48, 48),
        .layout = .center,
    }).children({
        Vapor.Graphic(.{ .src = "/assets/event_state_diagram.svg" })
            .fill(.palette(.text_color))
            .stroke(.palette(.text_color))
            .layout(.center)
            .width(.percent(70))
            .height(.percent(70))
            .aspectRatio(.landscape)
            .end();
    });
}

var color: Vapor.Types.Color = .palette(.text_color);
var changed_color: bool = false;
fn changeColors(_: *Vapor.Event) void {
    changed_color = !changed_color;
    if (changed_color) {
        color = .palette(.tint);
    } else {
        color = .palette(.text_color);
    }
}

fn onHover(_: *Vapor.Event) void {
    color = .palette(.tint);
}
fn onLeave(_: *Vapor.Event) void {
    color = .palette(.text_color);
}

fn counter() void {
    Row().margin(.tb(12, 32)).spacing(48).width(.percent(100)).layout(.center).children({
        Button(increment, .{})
            .padding(.all(8))
            .background(.palette(.background))
            .duration(100)
            .onHover(onHover, .{})
            .onLeave(onLeave, .{})
            .border(.simple(.palette(.text_color)))
            .shadow(.card(.palette(.text_color)))
            .hover(.{
                .transform = .scale(),
                .border = .simple(.palette(.tint)),
                .new_shadow = .card(.palette(.tint)),
            })
            .width(.percent(20))
            .responsive(.mobile, .{ .size = .{ .width = .percent(60) } })
            .cursor(.pointer)
            .children({
            Text(text)
                .fontFamily("IBM Plex Mono,monospace")
                .font(22, 700, color)
                .end();
        });
        Text(count)
            .fontFamily("IBM Plex Mono,monospace")
            .width(.px(100)).font(48, 700, color).end();
    });
}

fn cycleExample() void {
    Stack().margin(.tb(12, 32)).spacing(48).width(.percent(100)).layout(.center).children({
        Button(increment_cycle, .{})
            .shadow(.card(color))
            .padding(.all(8))
            .border(.simple(color))
            .background(.palette(.background))
            .duration(100)
            .hoverScale()
            .width(.percent(30))
            .cursor(.pointer)
            .children({
            Text(text)
                .fontFamily("IBM Plex Mono,monospace")
                .font(22, 700, color)
                .end();
        });
        TextFmt("I am a counter: {d}", .{count2})
            .fontFamily("IBM Plex Mono,monospace")
            .width(.fit).font(24, 700, color).end();
    });
}

pub fn init() void {
    content.init();
    f = Fetch.fetch("/documents/reactivity_page.md", .{ .method = .GET });
    f.?.handle(handlePage, .{});
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
