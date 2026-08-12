const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Vaporize = @import("vaporize");
const Row = Static.Row;
const Button = Static.Button;
const Text = Static.Text;
const Icon = Pure.Icon;
const Content = @import("../../../../../../components/Content.zig");

// Initialization
var csr_vs_ssr_page: *Vaporize.Node = undefined;
var content: Content.new(@embedFile("csr_vs_ssr_page.md")) = undefined;
pub fn init() void {
    content.init();
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("csr_vs_ssr_page.md"));
    csr_vs_ssr_page = parser.parse() catch unreachable;
}
var copied: bool = false;
fn copy() void {
    Vapor.Clipboard.copy(@embedFile("csr_vs_ssr_page.md"));
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
    Vaporize.traverse(csr_vs_ssr_page, .{
        .code_style = .{ .visual = .{ .text_color = .palette(.tint) } },
        .text_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
        .heading_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
    }, void, null) catch unreachable;
}

// Render
pub fn render() void {
    content.content(component);
}
