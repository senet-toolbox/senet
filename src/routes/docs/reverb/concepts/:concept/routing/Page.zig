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
            \\Routes are defined using the get, post, ect... functions, which takes a path, handler function, and optional slice of middleware functions.
        , .{
            .font_size = 22,
            .text_color = .hex("#666666"),
        });
    });
    Static.Box(.{
        .width = .percent(100),
        .height = .percent(100),
        .border_radius = .all(8),
        .background = .hex("#282a36"),
        .padding = .all(12),
        .margin = .{ .bottom = 32 },
    })({
        Custom.HtmlText(
            \\<code>server.get("/users", getUsers, &.{})</code>
        , .{ .text_color = .hex("#ffffff") });
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
    Static.Text("Dynamic Routing", .{
        .font_size = 32,
        .font_weight = 700,
        .text_color = .hex("#1a1a1a"),
    });
    Static.Text(
        \\Dynamic routing is a feature of Reverb that allows you to define routes that can be parameterized.
        \\This means that you can define routes that can take parameters, and then use those parameters to determine which route to handle the request.
    , .{
        .font_size = 18,
    });
    Static.Box(.{
        .width = .percent(100),
        .height = .percent(100),
        .border_radius = .all(8),
        .background = .hex("#282a36"),
        .padding = .all(12),
    })({
        Custom.HtmlText(
            \\<code>server.get("/users/:id", getUsers, &.{})</code>
        , .{ .text_color = .hex("#ffffff") });
    });
    Static.Box(.{
        .width = .percent(100),
        .height = .percent(100),
        .border_radius = .all(8),
        .background = .hex("#282a36"),
        .padding = .all(12),
    })({
        Custom.HtmlText(
            \\<code>server.get("/users/:id/:name", getUsers, &.{})</code>
        , .{ .text_color = .hex("#ffffff") });
    });
    Static.Text(
        \\It should be noted that dynamic routes are independent of the name given, ie the two following dynamic routes will both match to the same route, ie the second will overide the former.
    , .{
        .font_size = 18,
    });
    Static.Box(.{
        .width = .percent(100),
        .height = .percent(100),
        .border_radius = .all(8),
        .background = .hex("#282a36"),
        .padding = .all(12),
    })({
        Custom.HtmlText(
            \\<code>server.get("/users/:name", getUsersByName, &.{})</code>
        , .{ .text_color = .hex("#ffffff") });
    });
    Static.Box(.{
        .width = .percent(100),
        .height = .percent(100),
        .border_radius = .all(8),
        .background = .hex("#282a36"),
        .padding = .all(12),
    })({
        Custom.HtmlText(
            \\<code>server.get("/users/:id", getUsersById, &.{})</code>
        , .{ .text_color = .hex("#ffffff") });
    });
    Static.Text(
        \\To solve this issue, use named routes, or within the route handler handle different cases of params passed in.
    , .{
        .font_size = 18,
    });
    Static.Box(.{
        .width = .percent(100),
        .height = .percent(100),
        .border_radius = .all(8),
        .background = .hex("#282a36"),
        .padding = .all(12),
    })({
        Custom.HtmlText(
            \\<code>server.get("/usersbyname", getUsersByName, &.{})</code>
        , .{ .text_color = .hex("#ffffff") });
    });
    Static.Box(.{
        .width = .percent(100),
        .height = .percent(100),
        .border_radius = .all(8),
        .background = .hex("#282a36"),
        .padding = .all(12),
    })({
        Custom.HtmlText(
            \\<code>server.get("/usersbyid", getUsersById, &.{})</code>
        , .{ .text_color = .hex("#ffffff") });
    });
 
}
