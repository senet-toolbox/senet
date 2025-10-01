const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

var code_editor: CodeEditor = undefined;
// var route_sample: CodeEditor = undefined;
// var simple_route: CodeEditor = undefined;

// Initialization
pub fn init() void {
    code_editor.init(&Fabric.lib.allocator_global, @embedFile("sample_middleware.zig"));
    // route_sample.init(&Fabric.lib.allocator_global, @embedFile("route_definition.zig"));
    // simple_route.init(&Fabric.lib.allocator_global, @embedFile("simple_route.zig"));
}

// Deinitialization
pub fn deinit() void {}

// Render
pub fn render() void {
    // Page Header
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 8,
        .direction = .column,
    })({
        Static.Text("Middleware", .{
            .font_size = 42,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text(
            \\Middleware is a function that is executed before the handler function. 
            \\Middleware functions are called in the order they are passed into the server.
            \\The handler function is called when the route is matched and the request is made.
        , .{
            .font_size = 22,
            .text_color = .hex("#666666"),
        });
    });
    Static.Column(.{
        .width = .percent(100),
    })({
        Static.Text("Middleware Example", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .bottom = 16 },
        });
        Custom.Intersection(.{
            .width = .percent(100),
        })({
            code_editor.render(0);
        });
    });

 
}
