const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const Menu = @import("Menu.zig");
const CodeEditor = @import("concepts/:concept/CodeEditor.zig");
const Custom = @import("../../../components/Custom.zig");
const root = @import("../../../main.zig");
const OnThisPage = @import("OnThisPage.zig");

// Initialization
var code_view_loc: CodeEditor = undefined;
var html_code_editor: CodeEditor = undefined;
var traversal_code_editor: CodeEditor = undefined;
var enum_code_editor: CodeEditor = undefined;
pub fn init() void {
    Fabric.lib.registerLayout("/docs/fabric", layout);
    code_view_loc.init(&Fabric.lib.allocator_global, @embedFile("10loc.zig"));
    html_code_editor.init(&Fabric.lib.allocator_global, @embedFile("html_text_sample.zig"));
    traversal_code_editor.init(&Fabric.lib.allocator_global, @embedFile("traversal_sample.js"));
    enum_code_editor.init(&Fabric.lib.allocator_global, @embedFile("enum.zig"));

    Page(@src(), render, null, .{});
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
    if (!throttle()) {
        menu = !menu;
        Fabric.cycle();
    }
}

fn code_snippet(text: []const u8) void {
    Static.Box(.{
        .height = .percent(100),
        .background = .hex("#282a36"),
        .border_radius = .all(8),
        .padding = .all(8),
        .width = .percent(100),
        .direction = .column,
    })({
        Static.FlexBox(.{
            .child_alignment = .end_center,
            .width = .percent(100),
            .padding = .horizontal(12),
        })({
            Static.Box(.{
                .width = .px(22),
                .height = .px(22),
                .border_radius = .all(4),
                .display = .Center,
                .cursor = .pointer,
                .transition = .{ .duration = 300 },
                .hover = .{ .background = .hex("#2D303E") },
            })({
                Pure.Icon("bi bi-clipboard", .{
                    .font_size = 16,
                    .text_color = .hex("#cccccc"),
                    .transition = .{ .duration = 300 },
                    .hover = .{ .text_color = .hex("#ffffff") },
                });
            });
        });
        Static.Text(text, .{
            .font_size = 16,
            .text_color = .hex("#ffffff"),
        });
    });
}

pub fn render() void {
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .padding = .horizontal(12),
        .direction = if (!Fabric.isMobile()) .row else .column,
        .width = .percent(100),
        .height = .percent(100),
    })({
        // Fabric.Layout(@src(), .{})({
        if (!Fabric.isMobile()) {} else {
            Static.FlexBox(.{
                .child_alignment = .{ .x = .between, .y = .center },
                .child_gap = 8,
                .padding = .horizontal(12),
                .height = .px(50),
                .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
                .width = .percent(100),
                .z_index = 999,
                .background = root.theme.getAttribute("background"),
                .border_color = root.theme.getAttribute("border_color"),
                .border_thickness = .{ .bottom = 1 },
            })({
                Static.FlexBox(.{ .child_alignment = .x_between_center, .child_gap = 12, .width = .percent(100) })({
                    Static.Link(.{ .url = "/", .aria_label = "home page of tether" }, .{
                        .text_decoration = .none,
                        .height = .px(36),
                        .display = .Center,
                    })({
                        Static.Image("/assets/circlelogo.webp", .{
                            .display = .Flex,
                            .child_alignment = .{ .x = .center, .y = .center },
                            .width = .px(42),
                            .height = .px(42),
                        });
                    });
                });
            });
        }
        Static.FlexBox(.{
            .height = .percent(100),
            .width = .percent(100),
            .child_alignment = .{ .y = .start, .x = .center },
            .padding = .{ .top = 60 },
        })({
            Static.FlexBox(.{
                .width = .clamp_percent(62, 786, 100),
                .child_gap = 16,
                .direction = .column,
                .child_alignment = .{ .x = .start, .y = .start },
            })({
                // Static.Text("Fabric", .{
                //     .font_size = 64,
                //     .font_family = "Mrs Sheppards",
                // });
                Static.Svg(@embedFile("fabric_text.svg"), .{
                    .margin = .{ .top = 16 },
                    .width = .percent(20),
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
                Custom.Intersection(.{
                    .id = "what-is-fabric",
                })({
                    Static.Text("What is Fabric?", .{
                        // .margin = .{ .top = 32 },
                        .font_size = 32,
                        .font_weight = 700,
                    });
                    Static.Text(
                        \\Fabric is toolkit-first, framework-second. We believe developers should control their tools, not
                        \\the other way around. Every API is explicitly exposed, every internal is accessible, and every component can
                        \\be customized. No black boxes, no hidden magic—just transparent, controllable architecture that puts you in the
                        \\driver's seat.
                    , .{
                        .font_size = 18,
                        .width = .percent(100),
                        .height = .fit,
                    });
                    Static.Text(
                        \\Fabric should be treated and seen as a set of tools, which can be used to adapt the core framework, it's
                        \\purpose is to be unopinionated, and modular.
                    , .{
                        .font_size = 18,
                    });
                });
                Custom.Intersection(.{
                    .id = "fabric-is-simple",
                })({
                    Static.Text("Fabric is simple by nature", .{
                        // .margin = .{ .top = 32 },
                        .font_size = 32,
                        .font_weight = 700,
                    });
                    Static.List(.{
                        .direction = .column,
                    })({
                        Static.ListItem(.{})({
                            Static.Text("To rerender just call Fabric.cycle()", .{
                                .font_size = 18,
                            });
                        });
                        Static.ListItem(.{})({
                            Static.Text("You can add any custom native HTML or embed directly into Fabric.", .{
                                .font_size = 18,
                            });
                        });
                        Static.ListItem(.{})({
                            Static.Text("No runtime allocations", .{
                                .font_size = 18,
                            });
                        });
                        Static.ListItem(.{})({
                            Static.Text("Minimal memory management", .{
                                .font_size = 18,
                            });
                        });
                        Static.ListItem(.{})({
                            Static.Text("Native performance", .{
                                .font_size = 18,
                            });
                        });
                    });
                });

                Custom.Intersection(.{
                    .id = "opinions-opinions-opinions",
                })({
                    Static.Text("Opinions, Opinions, Opinions!", .{
                        .margin = .{ .top = 32 },
                        .font_size = 28,
                        .font_weight = 900,
                    });
                    Static.Text(
                        \\While the ideology of opinionated frameworks sounds greate in theory, unfortunatley in practice there are many
                        \\cases where this causes the frameworks themselves to support legacy codebases, and for systems to become static,
                        \\and inflexible.
                    , .{
                        .font_size = 18,
                    });
                    Custom.HtmlText(
                        \\React: <strong>"Use Class Components!"</strong> Then: <strong>"Actually, use functions as Components!"</strong>
                        \\Svelte: <strong>"Everything is state!"</strong> Then: <strong>"Actually, use runes!"</strong> Every framework
                        \\eventually pivots, leaving developers with broken code and migration headaches.
                    , .{
                        .font_size = 18,
                    });

                    Custom.HtmlText(
                        \\Fabric's approach is fundamentally different. By exposing all internals within a compact 8K-line codebase
                        \\and providing direct engine access, we eliminate framework lock-in. Developers retain full control over
                        \\their architecture while benefiting from a lightweight foundation where <a href="/docs/fabric/concepts/ui-nodes">
                        \\UI nodes</a> require just 10 lines of code.
                    , .{
                        .font_size = 18,
                    });
                });
                Custom.Intersection(.{
                    .id = "what-is-a-ui-node",
                })({
                    Static.Text("A UI Node", .{
                        .font_size = 24,
                        .font_weight = 700,
                    });
                    Static.Text(
                        \\A UI Node is a generalized element which represents all UI primitives, such as UIView, div, ect...
                        \\In Fabric, we use UI Nodes since the renderer is agnostic, this means that we construct a tree of UI Nodes, to 
                        \\represent the UI, and then we pass this tree to the renderer, which decides what type of primitive to render.
                    , .{
                        .font_size = 18,
                    });
                    Custom.HtmlText(
                        \\<strong style="color: #8B5CF6;"><i>pub inline fn Box(style: Style) fn (void) void</i></strong>
                    , .{
                        .font_size = 18,
                    });
                    Custom.HtmlText(
                        \\<strong>Function Purpose:</strong>
                        \\Creates a Box element with the provided styling and returns a closure function to 
                        \\properly close/cleanup the element.
                    , .{
                        .font_size = 18,
                    });

                    Custom.HtmlText(
                        \\<i>fn (void) void void</i> ??? This is a function that takes void ({}) as an argument, and returns void.
                        \\This pattern is used to create what is called a Closure, which is a function that can be called later on.
                        \\In this case, the function Box returns a closure, which is a function that takes no arguments and returns nothing.
                        \\We can therefore run any code within the closure. <code><i>Box(Style{}) => return closure = fn (void) void</i>, we can now call the closure like so
                        \\ <i>Box(Style{})({});</i> and within the void argument "{}", we can add a print statment => <i>({ Fabric.println("Hello World!"); })</i></code>
                        \\ This is a very powerful pattern, and is used in many languages, including JavaScript, Python, and Rust.
                        \\The final result would look something like this: <code><i>Box(Style{})({ Fabric.println("Hello World!"); })</i></code>
                    , .{
                        .font_size = 18,
                    });
                    Static.List(.{
                        .list_style = .decimal,
                    })({
                        Static.ListItem(.{})({
                            Custom.HtmlText(
                                \\<strong>Takes a Style parameter</strong> - accepts styling configuration for the flexbox
                            , .{
                                .font_size = 18,
                            });
                        });
                        Static.ListItem(.{})({
                            Custom.HtmlText(
                                \\<strong>Creates an ElementDecl</strong> struct with:
                            , .{
                                .font_size = 18,
                            });
                            Static.List(.{})({
                                Static.ListItem(.{})({
                                    Static.Text(
                                        \\The provided style
                                    , .{
                                        .font_size = 18,
                                    });
                                });
                            });
                            Static.List(.{})({
                                Static.ListItem(.{})({
                                    Static.Text(
                                        \\Static behavior (not dynamically updated)
                                    , .{
                                        .font_size = 18,
                                    });
                                });
                            });
                            Static.List(.{})({
                                Static.ListItem(.{})({
                                    Static.Text(
                                        \\Box as the element type
                                    , .{
                                        .font_size = 18,
                                    });
                                });
                            });
                        });
                        Static.ListItem(.{})({
                            Custom.HtmlText(
                                \\<strong>Lifecycle management</strong> - calls three lifecycle methods:
                            , .{
                                .font_size = 18,
                            });
                            Static.List(.{})({
                                Static.ListItem(.{})({
                                    Static.Text(
                                        \\LifeCycle.open() - initializes/opens the element
                                    , .{
                                        .font_size = 18,
                                    });
                                });
                            });
                            Static.List(.{})({
                                Static.ListItem(.{})({
                                    Static.Text(
                                        \\LifeCycle.configure() - applies configuration/styling
                                    , .{
                                        .font_size = 18,
                                    });
                                });
                            });
                            Static.List(.{})({
                                Static.ListItem(.{})({
                                    Static.Text(
                                        \\Returns LifeCycle.close - provides a function to close/cleanup the element
                                    , .{
                                        .font_size = 18,
                                    });
                                });
                            });
                        });
                    });
                });
                Custom.HtmlText(
                    \\<strong>Usage pattern:</strong>
                    \\This follows a common pattern where you'd call Box(style) to create the container, 
                    \\add child elements, then call the returned function to properly close the box container. 
                , .{
                    .font_size = 18,
                });

                code_view_loc.render(0);
                Static.Text("That's it!", .{
                    .margin = .{ .top = 16 },
                    .font_size = 32,
                    .font_weight = 900,
                });
                Static.Text(
                    \\That's literally the entirety of Fabric at its core. It takes a bunch of UI nodes, constructs a tree,
                    \\and outputs it to any renderer you want to use or build.
                , .{
                    .font_size = 18,
                });
                Static.Text("And since Fabric is a toolkit, not a framework...", .{
                    .font_size = 24,
                    .font_weight = 700,
                });
                html_code_editor.render(0);
                Static.Text(
                    \\We can create our own custom UI node's which hooks into the Fabric's engine. The example above, is used in this
                    \\very website, since we only ever render to web, we can make use of a custom UI node.
                , .{
                    .font_size = 18,
                });
                Static.Text("Then in the config.zig file we just add our enum UI Node type", .{
                    .font_size = 18,
                });
                enum_code_editor.render(0);
                Static.Text("Then in the traversal.js file we just add out custom UI node type", .{
                    .font_size = 18,
                });
                traversal_code_editor.render(0);
                Static.Text(
                    \\This is a very powerful pattern, since it allows us to create our own native UI elements, which means the distinction,
                    \\ between rendering to ios or web or even nintendo switch is on the renderer level, and not within our code semantics.
                    \\Thus if a developer were to create a renderer for the nintendo switch we could just plug in the renderer, and everything 
                    \\would work as expected. No need to rebuild or configure or install an entire browser engine (Electron) into our application.
                , .{
                    .font_size = 18,
                });
                Static.Text("But what about state management?", .{
                    .font_size = 24,
                });
                Static.Block(.{
                    .position = .{ .type = .relative },
                })({
                    Static.List(.{
                        .margin = .{ .top = 16, .bottom = 16 },
                        .padding = .{ .left = 32 },
                        .display = .Flex,
                        .child_gap = 32,
                        .direction = .column,
                        .child_alignment = .{ .x = .start, .y = .start },
                    })({
                        Static.ListItem(.{})({
                            Custom.HtmlText(
                                \\State management? Just one global boolean: <code>global_rerender</code>. Run <code>Fabric.cycle()</code> 
                                \\to signal Fabric to update the UI.
                                \\You could even create an interval that calls Fabric.cycle() every tick and never worry about signals
                                \\or state management again. Don't worry Fabric handles all the reconciliation for you.
                            , .{
                                .font_size = 18,
                            });
                        });
                        Static.ListItem(.{})({
                            Custom.HtmlText(
                                \\Don't like the UI node syntax? Want to create custom UI nodes with your own styling? Go for it.
                                \\Just call <code>LifeCycle.open()</code>, <code>LifeCycle.configure()</code>, and <code>LifeCycle.close()</code> to add it to the tree hierarchy.
                            , .{
                                .font_size = 18,
                            });
                        });
                        Static.ListItem(.{})({
                            Static.Text("Want to use your own renderers, your own conventions, your own ideas! Now you can!", .{
                                .font_size = 18,
                            });
                        });
                    });
                });
                Static.Text("No surprises, no magic, no migrations—just code that works the way you expect it to.", .{
                    .font_size = 22,
                    .font_weight = 700,
                });
                Custom.Intersection(.{
                    .id = "fabric-documentation",
                })({
                    Static.Text("Documentation", .{
                        .margin = .{ .top = 32 },
                        .font_size = 32,
                        .font_weight = 700,
                    });
                    Static.Text("This is the documenation of Fabric, a frontend toolkit for building UI. Fabric is one of 3 components of Tether.", .{
                        .font_size = 20,
                        .text_color = .hex("#666666"),
                    });
                    Static.Text("Fabric concepts:", .{
                        .font_size = 24,
                    });

                    Static.List(.{
                        .display = .Flex,
                        .child_gap = 8,
                        .direction = .column,
                        .child_alignment = .{ .x = .start, .y = .start },
                        .padding = .{ .left = 32 },
                    })({
                        for (routes) |route| {
                            Static.ListItem(.{
                                // .width = .percent(100),
                            })({
                                Static.Link(.{ .url = route.path, .aria_label = route.title }, .{
                                    .text_decoration = .none,
                                    // .width = .percent(100),
                                    .display = .Flex,
                                    .child_alignment = .{ .x = .start, .y = .center },
                                    .child_gap = 12,
                                    .padding = .{ .top = 4, .bottom = 4 },
                                    .cursor = .pointer,
                                    .border_thickness = .{ .bottom = 1 },
                                    .hover = .{ .border_thickness = .{ .bottom = 1 }, .border_color = .rgb(0, 0, 0) },
                                })({
                                    Static.Text(route.title, .{});
                                });
                            });
                        }
                    });
                });
            });
        });
    });
}

fn layout(page: *const fn () void) void {
    Fabric.Remember(.{
        .file = "/routes/docs/fabric",
        .module = "",
        .column = 0,
        .fn_name = "",
        .line = 0,
    })({
        Menu.render({});
    });
    @call(.auto, page, .{});
}
