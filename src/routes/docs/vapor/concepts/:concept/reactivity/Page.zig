const std = @import("std");
const Vapor = @import("vapor");
const Page = Vapor.Page;
const Vaporize = @import("vaporize");
const Compiler = @import("../../../../../../main.zig");
const Content = @import("../../../../../../components/Content.zig");
const Box = Vapor.Box;
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
var content: Content.new("") = .{};
var markdown_loaded: bool = false;

var count: i32 = 0;
fn increment() void {
    count += 1;
}

var text: []const u8 = "Increment";
var count2: u32 = 0;
fn increment_cycle() void {
    text = "Increment Again";
    count2 += 1;
}

fn graphics() void {
    Box().style(&.{
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

fn counter() void {
    Box().margin(.tb(12, 32)).spacing(48).width(.percent(100)).layout(.center).children({
        Button(increment)
            .shadow(.card(color))
            .padding(.all(8))
            .border(.simple(color))
            .background(.palette(.background))
            .duration(100)
            .hoverScale()
            .onHover(changeColors)
            .onLeave(changeColors)
            .width(.percent(20))
            .cursor(.pointer)
            .children({
            Text("Increment")
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
        Button(increment_cycle)
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
    Vapor.Kit.fetch("/documents/reactivity_page.md", handlePage, .{ .method = .GET });
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

// Render
pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}
