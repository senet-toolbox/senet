const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Chain = Static.Chain;
const ChainClose = Static.ChainClose;
const Box = Chain.Box;
const Text = ChainClose.Text;
const Link = Chain.Link;
const Image = ChainClose.Image;
const Svg = ChainClose.Svg;
const Button = Chain.Button;
const HtmlText = Custom.Chain.HtmlText;
const List = Chain.List;
const ListItem = Chain.ListItem;

const Pure = Fabric.Pure;
const Page = Fabric.Page;
// const Menu = @import("Menu.zig");
const CodeEditor = @import("concepts/:concept/CodeEditor.zig");
const Custom = @import("../../../components/Custom.zig");
const root = @import("../../../main.zig");
const OnThisPage = @import("OnThisPage.zig");
// const Sheet = @import("Sheet.zig").Sheet;
// var sheet: Sheet(void, Menu.render) = undefined;

// Initialization
var code_view_loc: CodeEditor = undefined;
var html_code_editor: CodeEditor = undefined;
var traversal_code_editor: CodeEditor = undefined;
var enum_code_editor: CodeEditor = undefined;
var void_code_editor: CodeEditor = undefined;
var full_code_editor: CodeEditor = undefined;
pub fn init() void {
    // sheet.init(&Fabric.lib.allocator_global);
    // Fabric.lib.registerLayout("/docs/fabric", layout, .{ .reset = true });
    code_view_loc.init(&Fabric.lib.allocator_global, @embedFile("10loc.zig"));
    // html_code_editor.init(&Fabric.lib.allocator_global, @embedFile("html_text_sample.zig"));
    // traversal_code_editor.init(&Fabric.lib.allocator_global, @embedFile("traversal_sample.js"));
    // enum_code_editor.init(&Fabric.lib.allocator_global, @embedFile("enum.zig"));
    // void_code_editor.init(&Fabric.lib.allocator_global, @embedFile("void_sample.zig"));
    // full_code_editor.init(&Fabric.lib.allocator_global, @embedFile("full_sample.zig"));

    Page(@src(), render, null, &.{
        .size = .hw(.percent(100), .percent(100)),
    });
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

const onthispage_items: []const OnThisPage.Link = &.{
    .{ .title = "What is Fabric", .link = "#what-is-fabric", .id = "whatisfabric" },
    .{ .title = "Fabric is simple", .link = "#fabric-is-simple", .id = "fabricissimple" },
    .{ .title = "Opinions, Opinions, Opinions!", .link = "#opinions-opinions-opinions", .id = "opinionsopinionsopinions" },
    .{ .title = "What is a UI Node?", .link = "#what-is-a-ui-node", .id = "whatisauinode" },
    .{ .title = "Documentation", .link = "#fabric-documentation", .id = "fabricdocumentation" },
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
        // Fabric.Layout(@src(), .{})({
        // if (!Fabric.isMobile()) {} else {
        //     Box.style(&.{
        //         .layout = .{ .x = .between, .y = .center },
        //         .child_gap = 8,
        //         .padding = .horizontal(12),
        //         .size = .hw(.px(50), .percent(100)),
        //         .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
        //         .z_index = 999,
        //         .visual = .{
        //             .background = root.theme.getAttribute("background"),
        //             .border = .bottom(root.theme.getAttribute("border_color")),
        //         },
        //     })({
        //         Box.style(&.{ .layout = .x_between_center, .child_gap = 12, .size = .w(.percent(100)) })({
        //             Link(.{ .url = "/", .aria_label = "home page of tether" }).style(&.{
        //                 .text_decoration = .none,
        //                 .size = .h(.px(36)),
        //             })({
        //                 Image(.{ .src = "/assets/circlelogo.webp" }).style(&.{
        //                     .layout = .center,
        //                     .size = .hw(.px(42), .px(42)),
        //                 });
        //             });
        //         });
        //     });
        // }
        Box.style(&.{
            .size = .hw(.percent(100), .percent(100)),
            .layout = .top_center,
            .padding = .t(60),
        })({
            Box.style(&.{
                .size = .w(.mobile_desktop_percent(100, 62)),
                .child_gap = 16,
                .direction = .column,
                .layout = .{ .x = .start, .y = .start },
            })({
                // Static.Text("Fabric", .{
                //     .font_size = 64,
                //     .font_family = "Mrs Sheppards",
                // });
                Svg(.{ .svg = @embedFile("fabric_text.svg") }).style(&.{
                    .margin = .{ .top = 16 },
                    .size = .w(.percent(20)),
                });

                // Static.Text("An Exposed UI Toolkit", .{
                //     .font_size = 32,
                //     .font_weight = 700,
                // });
                // Static.Image("/assets/FabricKit.webp", .{
                //     .width = .percent(100),
                //     .height = .percent(100),
                //     .border_radius = .all(8),
                //     .margin = .{ .bottom = 32 },
                // });
                Custom.Virtualize(&.{
                    .size = .hw(.percent(100), .percent(100)),
                })({
                    Custom.Intersection(&.{
                        .id = "what-is-fabric",
                        .child_gap = 8,
                        .direction = .column,
                        .size = .h(if (Fabric.isMobile()) .min_max_vp(60, 100) else .min_max_vp(30, 100)),
                    })({
                        Text("What is Fabric?").style(&.{ .visual = .font(32, 700, null) });
                        Text("Fabric is the frontend framework of Tether.").style(&.{
                            .size = .w(.percent(100)),
                            .visual = .font(24, null, .hex("#666666")),
                            .margin = .{ .top = 8, .bottom = 8 },
                        });
                        Text(
                            \\We believe developers should control their tools, not
                            \\the other way around. Every API is explicitly exposed, every internal is accessible, and every component can
                            \\be customized. No black boxes, no hidden magic—just transparent, controllable architecture that puts you in the
                            \\driver's seat.
                        ).style(&.{
                            .visual = .font(18, null, null),
                            .size = .w(.percent(100)),
                        });
                        Text(
                            \\Fabric should be treated and seen as a set of tools, which can be used to adapt the core framework, it's
                            \\purpose is to be unopinionated, and modular. However, there are guidelines, and best practices that we follow.
                        ).style(&.{
                            .visual = .font(18, null, null),
                        });
                    });
                    Custom.Intersection(&.{
                        .id = "fabric-is-simple",
                        .size = .h(if (Fabric.isMobile()) .min_max_vp(30, 100) else .min_max_vp(10, 100)),
                    })({
                        Text("Fabric is simple by nature").style(&.{
                            .visual = .font(32, 700, null),
                        });
                        List.style(&.{
                            .direction = .column,
                        })({
                            ListItem.style(&.{})({
                                Text("To update the UI just call Fabric.cycle()").style(&.{ .visual = .font(18, null, null) });
                            });
                            ListItem.style(&.{})({
                                Text("You can embed any custom HTML, JS, CSS").style(&.{ .visual = .font(18, null, null) });
                            });
                            ListItem.style(&.{})({
                                Text("No runtime allocations").style(&.{ .visual = .font(18, null, null) });
                            });
                            ListItem.style(&.{})({
                                Text("Minimal memory management").style(&.{ .visual = .font(18, null, null) });
                            });
                            ListItem.style(&.{})({
                                Text("Native performance").style(&.{ .visual = .font(18, null, null) });
                            });
                        });
                    });

                    Custom.Intersection(&.{
                        .id = "opinions-opinions-opinions",
                        .direction = .column,
                        .child_gap = 8,
                        .size = .h(if (Fabric.isMobile()) .min_max_vp(30, 100) else .min_max_vp(50, 100)),
                    })({
                        Text("Opinions, Opinions, Opinions!").style(&.{
                            .margin = .{ .top = 32 },
                            .visual = .font(28, 900, null),
                        });
                        Text(
                            \\While the ideology of opinionated frameworks sounds great in theory, unfortunatley in practice there are many
                            \\cases where this causes the frameworks themselves to support legacy codebases, and for systems to become static,
                            \\and inflexible.
                        ).style(&.{ .visual = .font(18, null, null) });
                        HtmlText(
                            \\<strong  style="color: #087ea4;">React</strong>: <strong>"Use Class Components!"</strong> Then: <strong>"Actually, use functions as Components!"</strong>
                            \\<strong style="color: #ff3e00;">Svelte</strong>: <strong>"Everything is state!"</strong> Then: <strong>"Actually, use runes!"</strong> Every framework
                            \\eventually pivots, leaving developers with broken code and migration headaches.
                        ).style(&.{ .visual = .font(18, null, null) });

                        HtmlText(
                            \\Now in their own right, React and Svelte are great frameworks, but they are not Fabric. Fabric is a toolkit, not a framework.
                            \\Both React and Svelte have laid the groundwork for Fabric to be where it is today. Moreover, what Rich Harris achieved, is no small feat.
                        ).style(&.{ .visual = .font(18, null, null) });

                        HtmlText(
                            \\Fabric's approach is fundamentally different. By exposing all internals within a compact 8K-line codebase
                            \\and providing direct engine access, we eliminate framework lock-in. Developers retain full control over
                            \\their architecture while benefiting from a lightweight foundation where UI nodes require just 10 lines of code.
                        ).style(&.{ .visual = .font(18, null, null) });
                    });
                    Custom.Intersection(&.{
                        .id = "what-is-a-ui-node",
                        .child_gap = 8,
                        .direction = .column,
                        .size = .h(.min_max_vp(70, 100)),
                    })({
                        Text("A UI Node").style(&.{
                            .visual = .font(24, 700, null),
                        });
                        Text(
                            \\A UI Node is a generalized element which represents all UI primitives, such as UIView, div, ect...
                            \\In Fabric, we use UI Nodes since the renderer is agnostic, this means that we construct a tree of UI Nodes, to
                            \\represent the UI, and then we pass this tree to the renderer, which decides what type of primitive to render.
                        ).style(&.{
                            .visual = .font(18, null, null),
                        });
                        HtmlText(
                            \\<strong style="color: #8B5CF6;"><i>pub inline fn Box(style: Style) fn (void) void</i></strong>
                        ).style(&.{ .visual = .font(18, null, null) });
                        HtmlText(
                            \\<strong>Function Purpose:</strong>
                            \\Creates a Box element with the provided styling and returns a closure function to
                            \\properly close/cleanup the element.
                        ).style(&.{ .visual = .font(18, null, null) });
                        HtmlText(
                            \\<strong style="color: #8B5CF6;"><i>fn (void) void ???</i></strong>
                        ).style(&.{ .visual = .font(18, null, null) });
                        HtmlText(
                            \\<strong><i>void</i></strong> in low level languages, basically means nothing. So when we
                            \\call a function and return void, we are saying that we don't return anything. In Zig void is represented as {}.
                            \\So in a function which takes void as an argument we can pass {}. This is like a code block, where we can run anything inside it.
                        ).style(&.{
                            .visual = .font(18, null, null),
                            .margin = .{ .bottom = 16 },
                        });

                        // void_code_editor.render(0);

                        HtmlText(
                            \\Here is an example using some of Fabric's components. and a print statement.
                        ).style(&.{
                            .visual = .font(22, null, null),
                            .margin = .{ .bottom = 16, .top = 16 },
                        });

                        // full_code_editor.render(0);

                        HtmlText(
                            \\<strong style="color: #8B5CF6;"><i>fn (void) void</i></strong>
                        ).style(&.{
                            .margin = .{ .top = 16 },
                            .visual = .font(18, null, null),
                        });

                        HtmlText(
                            \\This is a function that takes void <strong>({})</strong> as an argument, and returns void.
                            \\This pattern is used to create what is called a Closure, which is a function that can be called later on.
                            \\In this case, the function Box returns a closure, which is a function that takes a void argument and returns nothing.
                            \\We can therefore run any code within the closure. <code><i>Box(Style{}) => return closure = fn (void) void</i>, we can now call the closure like so
                            \\ <i>Box(Style{})({});</i> and within the void argument "{}", we can add a print statment => <i>({ Fabric.println("Hello World!"); })</i></code>
                            \\ This is a very powerful pattern, and is used in many languages, including JavaScript, Python, and Rust.
                            \\The final result would look something like this: <code><i>Box(Style{})({ Fabric.println("Hello World!"); })</i></code>
                        ).style(&.{
                            .visual = .font(18, null, null),
                        });
                        // Static.List(.{
                        //     .list_style = .decimal,
                        // })({
                        //    Static.ListItem(.{.style = &.{}})({
                        //         HtmlText(
                        //             \\<strong>Takes a Style parameter</strong> - accepts styling configuration for the flexbox
                        //         , .{
                        //             .font_size = 18,
                        //         });
                        //     });
                        //    Static.ListItem(.{.style = &.{}})({
                        //         HtmlText(
                        //             \\<strong>Creates an ElementDecl</strong> struct with:
                        //         , .{
                        //             .font_size = 18,
                        //         });
                        //         Static.List(.{})({
                        //            Static.ListItem(.{.style = &.{}})({
                        //                 Text(
                        //                     \\The provided style
                        //                 ).style(&.{
                        //                     .font_size = 18,
                        //                 });
                        //             });
                        //         });
                        //         Static.List(.{})({
                        //            Static.ListItem(.{.style = &.{}})({
                        //                 Text(
                        //                     \\Static behavior (not dynamically updated)
                        //                 ).style(&.{
                        //                     .font_size = 18,
                        //                 });
                        //             });
                        //         });
                        //         Static.List(.{})({
                        //            Static.ListItem(.{.style = &.{}})({
                        //                 Text(
                        //                     \\Box as the element type
                        //                 ).style(&.{
                        //                     .font_size = 18,
                        //                 });
                        //             });
                        //         });
                        //     });
                        //    Static.ListItem(.{.style = &.{}})({
                        //         HtmlText(
                        //             \\<strong>Lifecycle management</strong> - calls three lifecycle methods:
                        //         , .{
                        //             .font_size = 18,
                        //         });
                        //         Static.List(.{})({
                        //            Static.ListItem(.{.style = &.{}})({
                        //                 Text(
                        //                     \\LifeCycle.open() - initializes/opens the element
                        //                 ).style(&.{
                        //                     .font_size = 18,
                        //                 });
                        //             });
                        //         });
                        //         Static.List(.{})({
                        //            Static.ListItem(.{.style = &.{}})({
                        //                 Text(
                        //                     \\LifeCycle.configure() - applies configuration/styling
                        //                 ).style(&.{
                        //                     .font_size = 18,
                        //                 });
                        //             });
                        //         });
                        //         Static.List(.{})({
                        //            Static.ListItem(.{.style = &.{}})({
                        //                 Text(
                        //                     \\Returns LifeCycle.close - provides a function to close/cleanup the element
                        //                 ).style(&.{
                        //                     .font_size = 18,
                        //                 });
                        //             });
                        //         });
                        //     });
                        // });
                    });
                    // Custom.Intersection(.{
                    //     .id = "usage-pattern",
                    //     .size = .h(.min_max_vp(50, 100)),
                    // })({
                    //     HtmlText(
                    //         \\<strong>Usage pattern:</strong>
                    //         \\This follows a common pattern where you'd call Box(style) to create the container,
                    //         \\add child elements, then call the returned function to properly close the box container.
                    //     , .{
                    //         .font_size = 18,
                    //     });
                    //
                    //     code_view_loc.render(0);
                    //     Text("That's it!").style(&.{
                    //         .margin = .{ .top = 16 },
                    //         .font_size = 32,
                    //         .font_weight = 900,
                    //     });
                    //     Text(
                    //         \\That's literally the entirety of Fabric at its core. It takes a bunch of UI nodes, constructs a tree,
                    //         \\and outputs it to any renderer you want to use or build.
                    //     ).style(&.{
                    //         .font_size = 18,
                    //     });
                    //     Text("And since Fabric is a toolkit, not a framework...").style(&.{
                    //         .font_size = 24,
                    //         .font_weight = 700,
                    //     });
                    //     html_code_editor.render(0);
                    //     Text(
                    //         \\We can create our own custom UI node's which hooks into the Fabric's engine. The example above, is used in this
                    //         \\very website, since we only ever render to web, we can make use of a custom UI node.
                    //     ).style(&.{
                    //         .font_size = 18,
                    //     });
                    //     Text("Then in the config.zig file we just add our enum UI Node type").style(&.{
                    //         .font_size = 18,
                    //     });
                    //     enum_code_editor.render(0);
                    //     Text("Then in the traversal.js file we just add out custom UI node type").style(&.{
                    //         .font_size = 18,
                    //     });
                    //     traversal_code_editor.render(0);
                    //     Text(
                    //         \\This is a very powerful pattern, since it allows us to create our own native UI elements, which means the distinction,
                    //         \\ between rendering to ios or web or even nintendo switch is on the renderer level, and not within our code semantics.
                    //         \\Thus if a developer were to create a renderer for the nintendo switch we could just plug in the renderer, and everything
                    //         \\would work as expected. No need to rebuild or configure or install an entire browser engine (Electron) into our application.
                    //     ).style(&.{
                    //         .font_size = 18,
                    //     });
                    //     Text("But what about state management?").style(&.{
                    //         .font_size = 24,
                    //     });
                    //     Static.Block(.{
                    //         .position = .{ .type = .relative },
                    //     })({
                    //         Static.List(.{
                    //             .margin = .{ .top = 16, .bottom = 16 },
                    //             .padding = .{ .left = 32 },
                    //             .child_gap = 32,
                    //             .direction = .column,
                    //             .layout = .{ .x = .start, .y = .start },
                    //         })({
                    //            Static.ListItem(.{.style = &.{}})({
                    //                 HtmlText(
                    //                     \\State management? Just one global boolean: <code>global_rerender</code>. Run <code>Fabric.cycle()</code>
                    //                     \\to signal Fabric to update the UI.
                    //                     \\You could even create an interval that calls Fabric.cycle() every tick and never worry about signals
                    //                     \\or state management again. Don't worry Fabric handles all the reconciliation for you.
                    //                 , .{
                    //                     .font_size = 18,
                    //                 });
                    //             });
                    //            Static.ListItem(.{.style = &.{}})({
                    //                 HtmlText(
                    //                     \\Don't like the UI node syntax? Want to create custom UI nodes with your own styling? Go for it.
                    //                     \\Just call <code>LifeCycle.open()</code>, <code>LifeCycle.configure()</code>, and <code>LifeCycle.close()</code> to add it to the tree hierarchy.
                    //                 , .{
                    //                     .font_size = 18,
                    //                 });
                    //             });
                    //            Static.ListItem(.{.style = &.{}})({
                    //                 Text("Want to use your own renderers, your own conventions, your own ideas! Now you can!", .{
                    //                     .font_size = 18,
                    //                 });
                    //             });
                    //         });
                    //     });
                    //     Text("No surprises, no magic, no migrations—just code that works the way you expect it to.", .{
                    //         .font_size = 22,
                    //         .font_weight = 700,
                    //     });
                    // });
                    // Custom.Intersection(.{
                    //     .id = "fabric-documentation",
                    //     .height = .min_max_vp(30, 100),
                    // })({
                    //     Text("Documentation", .{
                    //         .margin = .{ .top = 32 },
                    //         .font_size = 32,
                    //         .font_weight = 700,
                    //     });
                    //     Static.Text("This is the documenation of Fabric, a frontend toolkit for building UI. Fabric is one of 3 components of Tether.", .{
                    //         .font_size = 20,
                    //         .text_color = .hex("#666666"),
                    //     });
                    //     Static.Text("Fabric concepts:", .{
                    //         .font_size = 24,
                    //     });
                    //
                    //     Static.List(.{
                    //         .child_gap = 8,
                    //         .direction = .column,
                    //         .layout = .{ .x = .start, .y = .start },
                    //         .padding = .{ .left = 32 },
                    //     })({
                    //         for (routes) |route| {
                    //             Static.ListItem(.{
                    //                 // .width = .percent(100),
                    //             })({
                    //                 Link(.{ .url = route.path, .aria_label = route.title }).style(&.{
                    //                     .text_decoration = .none,
                    //                     // .width = .percent(100),
                    //                     .layout = .{ .x = .start, .y = .center },
                    //                     .child_gap = 12,
                    //                     .padding = .{ .top = 4, .bottom = 4 },
                    //                     .cursor = .pointer,
                    //                     .border_thickness = .{ .bottom = 1 },
                    //                     .hover = .{ .border_thickness = .{ .bottom = 1 }, .border_color = .rgb(0, 0, 0) },
                    //                 })({
                    //                     Static.Text(route.title, .{});
                    //                 });
                    //             });
                    //         }
                    //     });
                    // });
                });
            });
        });
    });
}

fn layout(page: *const fn () void) void {
    if (Fabric.isMobile()) {
        // Box.style(&.{
        //     .layout = .{ .x = .between, .y = .center },
        //     .child_gap = 8,
        //     .padding = .horizontal(12),
        //     .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
        //     .size = .hw(.px(50), .percent(100)),
        //     .z_index = 999,
        //     .visual = .bg(.hex("#ffffff")),
        // })({
        //     Box.style(&.{ .layout = .x_between_center, .child_gap = 12, .width = .percent(100) })({
        //         Link(.{ .url = "/", .aria_label = "home page of tether" }).style(&.{
        //             .text_decoration = .none,
        //             .size = .h(.px(36)),
        //             .layout = .center,
        //         })({
        //             Image("/assets/circlelogo.webp").style(&.{
        //                 .layout = .{ .x = .center, .y = .center },
        //                 .size = .hw(.px(42), .px(42)),
        //             });
        //         });
        //         Button(.{ .on_press = openMenu }).style(&.{ .size = .hw(.px(36), .px(36)) })({
        //             if (menu) {
        //                 Pure.Icon("bi bi-x-lg", .{
        //                     .font_size = 24,
        //                 });
        //             } else {
        //                 Pure.Icon("bi bi-list", .{
        //                     .font_size = 24,
        //                 });
        //             }
        //         });
        //     });
        // });
        // sheet.render({});
        @call(.auto, page, .{});
    } else {
        // Fabric.Remember(.{
        //     .file = "/routes/docs/fabric",
        //     .module = "",
        //     .column = 0,
        //     .fn_name = "",
        //     .line = 0,
        // })({
        //     // Menu.render({});
        // });
        @call(.auto, page, .{});
    }
}
