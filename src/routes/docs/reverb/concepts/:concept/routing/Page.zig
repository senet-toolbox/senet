const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const ViewCode = @import("../ViewCode.zig");
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

var view_code: ViewCode = undefined;
var code_editor: CodeEditor = undefined;
var route_sample: CodeEditor = undefined;
var simple_route: CodeEditor = undefined;
// Initialization
pub fn init() void {
    code_editor.init(&Fabric.lib.allocator_global, @embedFile("main_sample.zig"));
    route_sample.init(&Fabric.lib.allocator_global, @embedFile("route_definition.zig"));
    simple_route.init(&Fabric.lib.allocator_global, @embedFile("simple_route.zig"));
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
        Static.Text("Routing", .{
            .font_size = 42,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text(
            \\Routing refers to the process of determining which route to handle a request.
            \\Routes are defined using the addRoute function, which takes a path, method, handler function, and optional middleware functions.
        , .{
            .font_size = 22,
            .text_color = .hex("#666666"),
        });
    });
    Static.Text(
        \\Reverb uses a single threaded event-loop known as Loom underneath the hood. Loom handles the reading and writing to 
        \\and from the client.
    , .{
        .font_size = 18,
    });
    Custom.PreImage("/assets/reverb_basics.webp", .{
        .width = .percent(100),
        .height = .percent(100),
    });
    Static.Column(.{
        .width = .percent(100),
    })({
        Static.Text("Route Definition", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .bottom = 16 },
        });
        Custom.Intersection(.{
            .width = .percent(100),
        })({
            route_sample.render(0);
        });
    });

    Static.List(.{})({
        Static.ListItem(.{})({
            Custom.HtmlText(
                \\<code style="background: #cecece; border-radius: 4px; padding: 4px;">server</code> is an instance of the Reverb server
            , .{ .font_size = 18 });
        });
    });
        Custom.Intersection(.{
            .width = .percent(100),
        })({
            simple_route.render(0);
        });
}
