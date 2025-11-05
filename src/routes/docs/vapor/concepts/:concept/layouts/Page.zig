const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Button = Static.Button;
const Text = Static.Text;
const Icon = Pure.Icon;
const Content = @import("../../../../../../components/Content.zig");

// Initialization
var layout_page: *Vaporize.Node = undefined;
var content: Content.new(@embedFile("layout_page.md")) = undefined;
pub fn init() void {
    content.init();
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("layout_page.md"));
    layout_page = parser.parse() catch unreachable;
}
var copied: bool = false;
fn copy() void {
    Vapor.Clipboard.copy(@embedFile("layout_page.md"));
    copied = true;
    Vapor.cycle();
    Vapor.registerCtxTimeout(500, toggleIcon, .{});
}

fn toggleIcon() void {
    copied = false;
    Vapor.cycle();
}

// Global state
var count: i32 = 0;
fn increment() void {
    count += 1;
    Vapor.cycle();
}

fn decrement() void {
    count -= 1;
    Vapor.cycle();
}

fn component() void {
    Vaporize.traverse(layout_page, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color),
        .heading_color = .palette(.text_color),
    }, void, null) catch unreachable;
}

// Render
pub fn render() void {
    content.content(component);
}
