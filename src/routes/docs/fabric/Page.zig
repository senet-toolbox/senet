const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
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
const Mark = Fabric.Mark;
const Vaporize = @import("vaporize");

const Pure = Fabric.Pure;
const Page = Fabric.Page;
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
pub fn init() void {
    var parser = Vaporize.Parser.init(Fabric.lib.allocator_global, @embedFile("fabric_page.md"));
    mark_up = parser.parse() catch unreachable;

    // sheet.init(&Fabric.lib.allocator_global);
    // Fabric.lib.registerLayout("/docs/fabric", layout, .{ .reset = true });
    // code_view_loc.init(&Fabric.lib.allocator_global, @embedFile("10loc.zig"));
    node_code_editor.init(&Fabric.lib.allocator_global, @embedFile("10loc.zig"));
    // sample_code.init(&Fabric.lib.allocator_global, @embedFile("sample.zig"));
    // builder_code_editor.init(&Fabric.lib.allocator_global, @embedFile("builder.zig"));
    // color_text_code_editor.init(&Fabric.lib.allocator_global, @embedFile("sample_color_text.zig"));
    // html_code_editor.init(&Fabric.lib.allocator_global, @embedFile("html_text_sample.zig"));
    // traversal_code_editor.init(&Fabric.lib.allocator_global, @embedFile("traversal_sample.js"));
    // enum_code_editor.init(&Fabric.lib.allocator_global, @embedFile("enum.zig"));
    // void_code_editor.init(&Fabric.lib.allocator_global, @embedFile("void_sample.zig"));
    // full_code_editor.init(&Fabric.lib.allocator_global, @embedFile("full_sample.zig"));

    Page(@src(), render, null);
}

// Deinitialization
pub fn deinit() void {}

// Render
const description =
    \\Fabric is a universal tree renderer that takes styled component hierarchies and renders them natively across
    \\platforms—from web browsers to iOS and macOS apps. Unlike black-box solutions, Fabric gives you direct access to the 
    \\rendering pipeline, so you can customize and optimize the engine for your exact use case.
;

const Route = struct {
    title: []const u8,
    path: []const u8,
};

const routes = [_]Route{
    .{ .title = "Introduction", .path = "/docs/fabric/concepts/introduction" },
    .{ .title = "Basics", .path = "/docs/fabric/concepts/basics" },
    .{ .title = "Project Structure", .path = "/docs/fabric/concepts/routing" },
    .{ .title = "Routing", .path = "/docs/fabric/concepts/routing" },
    .{ .title = "Reactivity", .path = "/docs/fabric/concepts/reactivity" },
    .{ .title = "Styling", .path = "/docs/fabric/concepts/styling" },
    .{ .title = "Kit", .path = "/docs/fabric/concepts/kit" },
    .{ .title = "Events & Handlers", .path = "/docs/fabric/concepts/events" },
    .{ .title = "Lifecycle Hooks", .path = "/docs/fabric/concepts/hooks" },
    .{ .title = "JS Libs", .path = "/docs/fabric/concepts/jslibs" },
    .{ .title = "Wasm Bridge", .path = "/docs/fabric/concepts/wasm-bridge" },
    .{ .title = "KeyStone", .path = "/docs/fabric/concepts/keystone" },
    .{ .title = "Gotchas", .path = "/docs/fabric/concepts/gotchas" },
    .{ .title = "Tutorials", .path = "/docs/fabric/concepts/tutorials" },
    .{ .title = "Metal", .path = "/docs/fabric/concepts/metal" },
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
    //     Fabric.cycle();
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

pub fn render() void {
    Box.style(&.{
        .padding = .horizontal(12),
        .direction = if (!Fabric.isMobile()) .row else .column,
        .size = .hw(.percent(100), .percent(100)),
    })({
        Box.style(&.{
            .size = .hw(.percent(100), .percent(100)),
            .layout = .top_center,
        })({
            Box.style(&.{
                .size = .w(.mobile_desktop_percent(100, 48)),
                .child_gap = 16,
                .direction = .column,
                .layout = .{ .x = .start, .y = .start },
                .padding = .tb(80, 80),
            })({
                Custom.Virtualize(&.{
                    .size = .hw(.percent(100), .percent(100)),
                    .child_gap = 32,
                    .layout = .{},
                    .direction = .column,
                })({
                    Box.style(&.{
                        .child_gap = 4,
                        .direction = .column,
                        .size = .hw(.percent(100), .percent(100)),
                        // .size = .h(if (Fabric.isMobile()) .min_max_vp(60, 100) else .min_max_vp(30, 100)),
                        .layout = .{},
                    })({
                        Text("Getting Started").style(&.{
                            .visual = .font(16, 600, null),
                            .font_family = "IBM Plex Sans",
                        });
                        Vaporize.traverse(mark_up, .{
                            .code_color = .palette(.tint),
                            .text_color = .palette(.text_color),
                            .heading_color = .palette(.text_color),
                        }) catch unreachable;
                        // Text("What is Fabric?").style(&.{
                        //     .visual = .font(32, 500, null),
                        //     .font_family = "IBM Plex Sans",
                        // });
                        // Text("Fabric is the frontend framework of Tether.").style(&.{
                        //     .size = .w(.percent(100)),
                        //     .visual = .font(24, null, .hex("#666666")),
                        //     .margin = .{ .top = 8, .bottom = 8 },
                        // });
                        // Text(
                        //     \\We believe developers should control their tools, not
                        //     \\the other way around. Every API is explicitly exposed, every internal is accessible, and every component can
                        //     \\be customized. No black boxes, no hidden magic—just transparent, controllable architecture that puts you in the
                        //     \\driver's seat.
                        // ).style(&.{
                        //     .visual = .font(18, null, null),
                        //     .size = .w(.percent(100)),
                        // });
                        // Text(
                        //     \\Fabric should be treated and seen as a set of tools, which can be used to adapt the core framework, it's
                        //     \\purpose is to be unopinionated, and modular. However, there are guidelines, and best practices that we follow.
                        // ).style(&.{
                        //     .visual = .font(18, null, null),
                        // });
                    });
                    // Custom.Intersection(&.{
                    //     .id = "fabric-is-simple",
                    //     // .size = .h(if (Fabric.isMobile()) .min_max_vp(30, 100) else .min_max_vp(10, 100)),
                    //     .size = .hw(.percent(100), .percent(100)),
                    //     .layout = .{},
                    //     .child_gap = 8,
                    //     .direction = .column,
                    // })({
                    //     Text("Fabric is simple by nature").style(&.{
                    //         .font_family = "IBM Plex Sans",
                    //         .visual = .font(20, 600, null),
                    //     });
                    //     List.style(&.{
                    //         .direction = .column,
                    //         .child_gap = 8,
                    //         .layout = .flex,
                    //     })({
                    //         ListItem.style(&.{})({
                    //             Text("Only write Zig").style(&.{ .visual = .font(18, null, null) });
                    //         });
                    //         ListItem.style(&.{})({
                    //             Text("To update the UI just call Fabric.cycle()").style(&.{ .visual = .font(18, null, null) });
                    //         });
                    //         ListItem.style(&.{})({
                    //             Text("You can embed any custom HTML, JS, CSS").style(&.{ .visual = .font(18, null, null) });
                    //         });
                    //         ListItem.style(&.{})({
                    //             Text("Powerful Styling").style(&.{ .visual = .font(18, null, null) });
                    //         });
                    //         ListItem.style(&.{})({
                    //             Text("Minimal memory management").style(&.{ .visual = .font(18, null, null) });
                    //         });
                    //         ListItem.style(&.{})({
                    //             Text("Native performance").style(&.{ .visual = .font(18, null, null) });
                    //         });
                    //     });
                    // });

                    // Custom.Intersection(&.{
                    //     .id = "making-a-button",
                    //     .child_gap = 16,
                    //     .direction = .column,
                    //     .size = .hw(.percent(100), .percent(100)),
                    //     .layout = .{},
                    // })({
                    //     Text("Making a button!").style(&.{
                    //         .visual = .font(20, 600, null),
                    //         .font_family = "IBM Plex Sans",
                    //     });
                    //
                    //     HtmlText(
                    //         \\We will jump into depth with styling, in the next section. For now though, we will make a button.
                    //         \\The <code>Button</code> component is part of the Static and Pure Structs.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //
                    //     HtmlText(
                    //         \\Every Component follows the builder pattern. We start by creating a <code>Button</code> struct, and then we call the <code>style</code> function.
                    //         \\We can now pass any styling to said component. There are many more functions that can be used.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //
                    //     HtmlText(
                    //         \\We attach a <code>on_press</code> handler to the button, and pass the increment function to it.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //     sample_code.render(0);
                    //     HtmlText(
                    //         \\Within the <code>increment</code> function, we call <code>Fabric.cycle()</code> to trigger the UI to update.
                    //         \\There is no need to use signals or state management in Fabric, it is all reactive. It is also fine grained,
                    //         \\only the content that you define to be updated will be updated. No more useMemo, or state definitions, just pure functions.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //
                    //     HtmlText(
                    //         \\Fabric does expose a few signals, types, if you truly want explicity over your code. However, they are no more performant
                    //         \\ than calling <code>Fabric.cycle()</code>.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //
                    //     HtmlText(
                    //         \\Finally, <code>Fabric.cycle()</code> only needs to called once, not for every variable change. Thus updating
                    //         \\ the color of the button and it's counter, only requires one call to <code>Fabric.cycle()</code>.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //
                    //     color_text_code_editor.render(0);
                    // });

                    // Custom.Intersection(&.{
                    //     .id = "what-is-a-ui-node",
                    //     .child_gap = 16,
                    //     .direction = .column,
                    //     .size = .hw(.percent(100), .percent(100)),
                    //     .layout = .{},
                    // })({
                    //     Text("A glimpse under the hood").style(&.{
                    //         .visual = .font(24, 600, null),
                    //         .font_family = "IBM Plex Sans",
                    //     });
                    //
                    //     HtmlText(
                    //         \\The following is a base explanation of how Fabric works at it's core. <strong>It is not neccesary for writing Fabric components.</strong>
                    //         \\However, it is useful to understand the basics of how Fabric works. If you ever want to use it to it's full potential,
                    //         \\or understand how frontend frameworks work, this is a great place to start.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //
                    //     Text("A UI Node").style(&.{
                    //         .visual = .font(20, 600, null),
                    //         .font_family = "IBM Plex Sans",
                    //     });
                    //     Text(
                    //         \\A UI Node is a generalized element which represents all UI primitives. Think of it as the boxes or text on your screen.
                    //         \\Each Box is generalized to a UI Node. In Web these are divs, spans, p tags, links.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //     Text(
                    //         \\In Fabric, eveything is a UI Node, during rendering, we build a tree of UI Nodes, each with a element type and style.
                    //         \\This tree is then rendered to the DOM. Since Fabric is renderer agnostic, we can use the same UI tree and just swap the renderer.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //
                    //     Box.style(&.{
                    //         .size = .{ .width = .percent(100), .height = .percent(100) },
                    //         .padding = .tb(32, 32),
                    //         .layout = .center,
                    //     })({
                    //         Graphic(.{ .src = "/src/assets/tree.svg" }).style(&.{
                    //             .size = .square_percent(70),
                    //         });
                    //     });
                    //
                    //     Text("Code Version").style(&.{
                    //         .visual = .font(20, 600, null),
                    //         .font_family = "IBM Plex Sans",
                    //     });
                    // node_code_editor.render(0);
                    //
                    //     HtmlText(
                    //         \\<code>LifeCycle</code> is a struct that handles configuring Nodes, and adding them to the UI tree.
                    //         \\<code><i style="color: var(--tint);">.open</i></code> adds the node to the tree and sets it as the current open node
                    //         \\or parent node.
                    //         \\We return <code><i style="color: var(--tint);">.body</i></code> which is a function that allows
                    //         \\for child nodes to be added to the current node.
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    //
                    //     HtmlText(
                    //         \\This is all abstracted away, it is up to the developer to decided whether they want to create their
                    //         \\own custom UI Node types
                    //     ).style(&.{ .visual = .font(18, null, null) });
                    // });
                });
            });
        });
    });
}
