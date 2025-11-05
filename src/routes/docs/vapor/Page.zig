const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Box = Static.Box;
const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const HtmlText = Custom.Chain.HtmlText;
const List = Static.List;
const ListItem = Static.ListItem;
const Graphic = Static.Graphic;
const Mark = Vapor.Mark;
const Vaporize = @import("vaporize");
const Icon = Static.Icon;
const Content = @import("../../../components/Content.zig");

const Pure = Vapor.Pure;
const Page = Vapor.Page;
// const Menu = @import("Menu.zig");
const CodeEditor = @import("../../../components/CodeEditor.zig");
const Custom = @import("../../../components/Custom.zig");
const root = @import("../../../main.zig");
// const Sheet = @import("Sheet.zig").Sheet;
// var sheet: Sheet(void, Menu.render) = undefined;

// Initialization
var code_view_loc: CodeEditor = undefined;
var html_code_editor: CodeEditor = undefined;
var traversal_code_editor: CodeEditor = undefined;
var enum_code_editor: CodeEditor = undefined;
var void_code_editor: CodeEditor = undefined;
var full_code_editor: CodeEditor = undefined;
var sample_code: CodeEditor = undefined;
// var builder_code_editor: CodeEditor = undefined;
var node_code_editor: CodeEditor = undefined;
// var color_text_code_editor: CodeEditor = undefined;
var mark_up: *Vaporize.Node = undefined;
const vapor_page = @embedFile("vapor_page.md");
var content: Content.new(@embedFile("vapor_page.md")) = undefined;
pub fn init() void {
    content.init();
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, vapor_page);
    mark_up = parser.parse() catch unreachable;

    // sheet.init(&Vapor.lib.allocator_global);
    // Vapor.lib.registerLayout("/docs/vapor", layout, .{ .reset = true });
    // code_view_loc.init(&Vapor.lib.allocator_global, @embedFile("10loc.zig"));
    node_code_editor.init(&Vapor.lib.allocator_global, @embedFile("10loc.zig"));
    // sample_code.init(&Vapor.lib.allocator_global, @embedFile("sample.zig"));
    // builder_code_editor.init(&Vapor.lib.allocator_global, @embedFile("builder.zig"));
    // color_text_code_editor.init(&Vapor.lib.allocator_global, @embedFile("sample_color_text.zig"));
    // html_code_editor.init(&Vapor.lib.allocator_global, @embedFile("html_text_sample.zig"));
    // traversal_code_editor.init(&Vapor.lib.allocator_global, @embedFile("traversal_sample.js"));
    // enum_code_editor.init(&Vapor.lib.allocator_global, @embedFile("enum.zig"));
    // void_code_editor.init(&Vapor.lib.allocator_global, @embedFile("void_sample.zig"));
    // full_code_editor.init(&Vapor.lib.allocator_global, @embedFile("full_sample.zig"));

    Page(.{ .src = @src() }, render, null);
}

// Deinitialization
pub fn deinit() void {}

var copied: bool = false;
fn toggleIcon(_: void) void {
    copied = false;
    Vapor.cycle();
}

fn copy() void {
    Vapor.Clipboard.copy(vapor_page);
    copied = true;
    Vapor.cycle();
    Vapor.registerCtxTimeout(1000, toggleIcon, .{{}});
}

// Render
const description =
    \\Vapor is a universal tree renderer that takes styled component hierarchies and renders them natively across
    \\platforms—from web browsers to iOS and macOS apps. Unlike black-box solutions, Vapor gives you direct access to the 
    \\rendering pipeline, so you can customize and optimize the engine for your exact use case.
;

const Route = struct {
    title: []const u8,
    path: []const u8,
};

const routes = [_]Route{
    .{ .title = "Introduction", .path = "/docs/vapor/concepts/introduction" },
    .{ .title = "Basics", .path = "/docs/vapor/concepts/basics" },
    .{ .title = "Project Structure", .path = "/docs/vapor/concepts/routing" },
    .{ .title = "Routing", .path = "/docs/vapor/concepts/routing" },
    .{ .title = "Reactivity", .path = "/docs/vapor/concepts/reactivity" },
    .{ .title = "Styling", .path = "/docs/vapor/concepts/styling" },
    .{ .title = "Kit", .path = "/docs/vapor/concepts/kit" },
    .{ .title = "Events & Handlers", .path = "/docs/vapor/concepts/events" },
    .{ .title = "Lifecycle Hooks", .path = "/docs/vapor/concepts/hooks" },
    .{ .title = "JS Libs", .path = "/docs/vapor/concepts/jslibs" },
    .{ .title = "Wasm Bridge", .path = "/docs/vapor/concepts/wasm-bridge" },
    .{ .title = "KeyStone", .path = "/docs/vapor/concepts/keystone" },
    .{ .title = "Gotchas", .path = "/docs/vapor/concepts/gotchas" },
    .{ .title = "Tutorials", .path = "/docs/vapor/concepts/tutorials" },
    .{ .title = "Metal", .path = "/docs/vapor/concepts/metal" },
};

var last_time: i64 = 0;
pub fn throttle() bool {
    const current_time = std.time.milliTimestamp();
    if (current_time - last_time < 60) {
        return true;
    }
    last_time = current_time;
    return false;
}

var menu: bool = false;
fn openMenu() void {
    // if (!throttle()) {
    //     menu = !menu;
    //     Vapor.cycle();
    // }
    // sheet.toggle();
}

// fn code_snippet(text: []const u8) void {
//     Static.Box(.{
//         .height = .percent(100),
//         .background = .hex("#282a36"),
//         .border_radius = .all(8),
//         .padding = .all(8),
//         .width = .percent(100),
//         .direction = .column,
//     })({
//         Box.style(&.{
//             .layout = .end_center,
//             .width = .percent(100),
//             .padding = .horizontal(12),
//         })({
//             Static.Box(.{
//                 .width = .px(22),
//                 .height = .px(22),
//                 .border_radius = .all(4),
//                 .layout = .center,
//                 .cursor = .pointer,
//                 .transition = .{ .duration = 300 },
//                 .hover = .{ .background = .hex("#2D303E") },
//             })({
//                 Pure.Icon("bi bi-clipboard", .{
//                     .font_size = 16,
//                     .text_color = .hex("#cccccc"),
//                     .transition = .{ .duration = 300 },
//                     .hover = .{ .text_color = .hex("#ffffff") },
//                 });
//             });
//         });
//         Text(text).style(&.{
//             .font_size = 16,
//             .text_color = .hex("#ffffff"),
//         });
//     });
// }

fn component() void {
    Vaporize.traverse(mark_up, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color),
        .heading_color = .palette(.text_color),
    }, void, null) catch unreachable;
}

pub fn render() void {
    Box.style(&.{
        .layout = .x_between,
        .direction = .column,
        .size = .square_percent(100),
    })({
        Box.style(&.{
            .padding = .horizontal(12),
            .direction = .row,
            .size = .w(.percent(100)),
        })({
            Box.style(&.{
                .layout = .center,
                .size = .w(.percent(100)),
                .padding = .{ .top = 60, .bottom = 120 },
                .direction = .column,
            })({
                Box.style(&.{
                    .size = .w(.mobile_desktop_percent(100, 50)),
                    // .width = .mobile_desktop_percent(100, 64),
                    // .size = .w(.percent(100)),
                    .child_gap = 32,
                    .direction = .column,
                    .padding = .{ .bottom = 80 },
                    .margin = .tb(32, 32),
                })({
                    content.content(component);
                });
            });
        });
    });
    // Box.style(&.{
    //     .padding = .horizontal(12),
    //     .direction = if (!Vapor.isMobile()) .row else .column,
    //     .size = .hw(.percent(100), .percent(100)),
    // })({
    //     Box.style(&.{
    //         .size = .hw(.percent(100), .percent(100)),
    //         .layout = .top_center,
    //     })({
    //         Box.style(&.{
    //             .size = .w(.mobile_desktop_percent(100, 48)),
    //             .child_gap = 16,
    //             .direction = .column,
    //             .layout = .{ .x = .start, .y = .start },
    //             .padding = .tb(80, 80),
    //         })({
    //             Button(.{ .on_press = copy }).style(&.{
    //                 .visual = .{ .background = .transparent, .cursor = .pointer },
    //                 .size = .w(.percent(100)),
    //                 .child_gap = 12,
    //                 .padding = .tb(8, 8),
    //                 .layout = .right_center,
    //             })({
    //                 if (copied) {
    //                     Icon(.check).style(&.{
    //                         .visual = .{ .font_size = 16 },
    //                     });
    //                 } else {
    //                     Icon(.clipboard).style(&.{
    //                         .visual = .{ .font_size = 16 },
    //                     });
    //                 }
    //             });
    //             Custom.Virtualize(&.{
    //                 .size = .hw(.percent(100), .percent(100)),
    //                 .child_gap = 32,
    //                 .layout = .{},
    //                 .direction = .column,
    //             })({
    //                 Box.style(&.{
    //                     .child_gap = 4,
    //                     .direction = .column,
    //                     .size = .hw(.percent(100), .percent(100)),
    //                     .layout = .{},
    //                 })({
    //                     Text("Getting Started").style(&.{
    //                         .visual = .font(16, 600, null),
    //                         .font_family = "IBM Plex Sans",
    //                     });
    // Vaporize.traverse(mark_up, .{
    //     .code_color = .palette(.tint),
    //     .text_color = .palette(.text_color),
    //     .heading_color = .palette(.text_color),
    // }, void, null) catch unreachable;
    //                 });
    //             });
    //         });
    //     });
    // });
}
