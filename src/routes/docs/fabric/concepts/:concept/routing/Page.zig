const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const ViewCode = @import("../ViewCode.zig");
const CodeEditor = @import("../CodeEditor.zig");

var view_code: ViewCode = undefined;
var code_editor: CodeEditor = undefined;
var dyanmic_code_editor: CodeEditor = undefined;
const items: []const []const u8 = &.{
    "Compiles to WASM and sent down the wire, resulting in client side rendering.",
    "Browser parse WASM 10x-20x faster than JS",
    "WASM is 1.5x-4x faster during runtime",
    "Embed your favorite JS Libraries",
    "Construct or modify GLUE the WASM Bridge",
    "Fabric only allocates at start up, no memory is allocated during runtime.",
    "Only Zig no html, js, ts, tsx, rsx, jsx",
};
// Initialization
pub fn init() void {
    code_editor.init(&Fabric.lib.allocator_global, @embedFile("page_sample.zig"));
    dyanmic_code_editor.init(&Fabric.lib.allocator_global, @embedFile("dynamic_sample.zig"));
}

// Deinitialization
pub fn deinit() void {}

// Render
pub fn render() void {
    // Page Header
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
    })({
        Static.Text("Routing", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text("Page(SourceLocation, *const fn () void, *const fn () void, Style)", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Static.Text("Pages create routes where components can be rendered. They take a source location, whom path resides in the routes directory.", .{
            .font_size = 16,
            .margin = .{ .top = 8 },
        });
        Static.Svg(@embedFile("routes.svg"), .{
            .width = .percent(55),
            .height = .percent(55),
        });
    });
    Static.Block(.{
        .width = .percent(100),
    })({
        code_editor.render(0);
    });

    Static.Text("Dynamic Routes", .{
        .font_size = 48,
        .font_weight = 700,
        .text_color = .hex("#1a1a1a"),
    });
    Static.Text("If a route directory is marked with a :.../ for example :concept/ or :id/ or :slug/, then this becomes a dynamic route. The Page function within :slug/ will automatically be replaced by the route given", .{
        .font_size = 16,
        .margin = .{ .top = 8 },
    });
    Static.Svg(@embedFile("dynamic.svg"), .{
        .width = .percent(60),
        .height = .percent(60),
    });
    Static.Block(.{
        .width = .percent(100),
    })({
        dyanmic_code_editor.render(0);
    });
}
