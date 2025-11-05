const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Page = Vapor.Page;
const ViewCode = @import("../ViewCode.zig");
const CodeEditor = @import("../../../../../../components/CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const Center = Static.Center;
const List = Static.List;
const ListItem = Static.ListItem;
const Stack = Static.Stack;
const Heading = Static.Heading;
const Icon = Pure.Icon;
const Counter = @import("instance_sample.zig");
const Content = @import("../../../../../../components/Content.zig");
var basics_page: *Vaporize.Node = undefined;
var counter: Counter = undefined;
var counter2: Counter = undefined;
// Initialization
var content: Content.new(@embedFile("basics_page.md")) = undefined;
pub fn init() void {
    content.init();
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("basics_page.md"));
    basics_page = parser.parse() catch unreachable;
    counter.init();
    counter2.init();

    // code_editor.init(&Vapor.lib.allocator_global, @embedFile("main_sample.zig"));
    // code_editor_component.init(&Vapor.lib.allocator_global, @embedFile("Component.zig"));
    // code_editor_lifecycle.init(&Vapor.lib.allocator_global, @embedFile("LifeCycle_sample.zig"));
    // code_editor_global.init(&Vapor.lib.allocator_global, @embedFile("global_sample.zig"));
    // code_editor_instance.init(&Vapor.lib.allocator_global, @embedFile("instance_sample.zig"));
    // code_editor_comptime.init(&Vapor.lib.allocator_global, @embedFile("comptime_sample.zig"));
}

// Deinitialization
pub fn deinit() void {}

var copied: bool = false;
fn copy() void {
    Vapor.Clipboard.copy(@embedFile("basics_page.md"));
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

const global = @import("global_sample.zig");

fn component() void {
    Vaporize.traverse(basics_page, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color),
        .heading_color = .palette(.text_color),
    }, *anyopaque, &[_]Vaporize.TaggedFunction(*anyopaque){
        Vaporize.TaggedFunction(*anyopaque){ .tag = "global_sample.zig", .function = global.render, .args = undefined },
        Vaporize.TaggedFunction(*anyopaque){ .tag = "instance_sample.zig", .function = Counter.render, .args = @ptrCast(&counter) },
        Vaporize.TaggedFunction(*anyopaque){ .tag = "instance_sample2.zig", .function = Counter.render, .args = @ptrCast(&counter2) },
    }) catch unreachable;

    Static.Box.layout(.center).spacing(16).padding(.all(20)).body()({
        Static.Button(.{ .on_press = decrement })
            .padding(.all(8))
            .border(.simple(.palette(.border_color_light)))
            .cursor(.pointer)
            .body()({
            Static.Text("-").font(18, null, .palette(.text_color)).close();
        });

        Static.TextFmt("Comptime Local State: {d}", .{count}).font(24, 700, .palette(.text_color)).close();

        Static.Button(.{ .on_press = increment })
            .padding(.all(8))
            .border(.simple(.palette(.border_color_light)))
            .cursor(.pointer)
            .body()({
            Static.Text("+").font(18, null, .palette(.text_color)).close();
        });
    });
}

// Render
pub fn render() void {
    content.content(component);
}
