const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Page = Vapor.Page;
const ViewCode = @import("../ViewCode.zig");
const Custom = @import("../../../../../../components/Custom.zig");
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const List = Static.List;
const ListItem = Static.ListItem;
const Stack = Static.Stack;
const Heading = Static.Heading;
const Icon = Pure.Icon;
const Counter = @import("instance_sample.zig");
const Content = @import("../../../../../../components/Content.zig");
const Compiler = @import("../../../../../../main.zig");
const Comptime = @import("Comptime.zig");
const global = @import("global_sample.zig");
var mark_up: *Vaporize.Node = undefined;
var counter: Counter = undefined;
var counter2: Counter = undefined;

const i32_counter = Comptime.Counter(i32, -1);
const u32_counter = Comptime.Counter(u32, 1);

// Initialization
var content: Content.new("") = undefined;
const components = .{
    .{ .tag = "global_sample", .function = global.render },
    .{ .tag = "instance_sample", .function = Counter.render, .args = &counter },
    .{ .tag = "instance_sample2", .function = Counter.render, .args = &counter2 },
    .{ .tag = "i32_sample", .function = i32_counter.render },
    .{ .tag = "u32_sample", .function = u32_counter.render },
};
var markdown: Compiler.vaporize.MarkDown(components) = .{};
var markdown_loaded: bool = false;
var page: []const u8 = "";
pub fn init() void {
    Vapor.Kit.fetch("/documents/components_page.md", handlePage, .{ .method = .GET });
    content.init();
    counter.init();
    counter2.init();
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

// Global state
var count: i32 = -1;
fn increment() void {
    count += 1;
}

fn decrement() void {
    count -= 1;
}

var count2: u32 = 1;
fn increment2() void {
    count2 += 1;
}

fn decrement2() void {
    if (count2 == 0) {
        Vapor.alert("You can't go negative! On a u32");
        return;
    }
    count2 -= 1;
}

fn component() void {
    if (!markdown_loaded) return;
    markdown.render() catch unreachable;
}

// Render
pub fn render() void {
    content.content(component);
}
