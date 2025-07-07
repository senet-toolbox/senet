const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

// Initialization
var sample_hooks: CodeEditor = undefined;
pub fn init() void {
    sample_hooks.init(&Fabric.lib.allocator_global, @embedFile("sample_hooks.zig"));
}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

// Render
pub fn render() void {
    // Page Header
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("LifeCycle Hooks", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });

        Static.Text("onCreate()", .{
            .font_size = 32,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });

        Custom.HtmlText(
            \\onCreate, which is akin to mount of onMount, schedules a function to run as soon as the component has been created and added to the DOM.
            \\onCreate will only run once. onCreate, also only runs when all its children have been added to the DOM. This ensures that,
            \\if the children components depend on the parent, they will first be created, thus. Attempting to manipulate them in the onCreate function will work.
        , .{ .font_size = 18 });

        sample_hooks.render(0);

        Custom.HtmlText(
            \\One major benefit of the Hooks Components, is that we can add multiple Hooks in one file. Unlike many other Frameworks.
            \\We can therefore, create cascade effects, where parent and children can have multiple Hooks calls to interact with each other.
        , .{ .font_size = 18 });
    });
}
