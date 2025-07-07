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

// Initialization
var code_view_loc: CodeEditor = undefined;
var html_code_editor: CodeEditor = undefined;
var traversal_code_editor: CodeEditor = undefined;
pub fn init() void {
    code_view_loc.init(&Fabric.lib.allocator_global, @embedFile("10loc.zig"));
    html_code_editor.init(&Fabric.lib.allocator_global, @embedFile("html_text_sample.zig"));
    traversal_code_editor.init(&Fabric.lib.allocator_global, @embedFile("traversal_sample.js"));

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
    .{ .title = "Static, Pure, Dynamic, Grain", .path = "/docs/fabric/concepts/reactivity" },
    .{ .title = "Routing", .path = "/docs/fabric/concepts/routing" },
    .{ .title = "Reactivity", .path = "/docs/fabric/concepts/reactivity-signals" },
    .{ .title = "Styling", .path = "/docs/fabric/concepts/styling" },
    .{ .title = "Kit", .path = "/docs/fabric/concepts/kit" },
    .{ .title = "Event Handlers", .path = "/docs/fabric/concepts/events" },
    .{ .title = "LifeCycle Hooks", .path = "/docs/fabric/concepts/hooks" },
    .{ .title = "Event Handlers", .path = "/docs/fabric/concepts/events" },
    .{ .title = "Using JS Libraries", .path = "/docs/fabric/concepts/jslibs" },
    .{ .title = "Wasm Bridge", .path = "/docs/fabric/concepts/wasm-bridge" },
    .{ .title = "KeyStone", .path = "/docs/fabric/concepts/keystone" },
    .{ .title = "Gotchas", .path = "/docs/fabric/concepts/gotchas" },
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
    if (!throttle()) {
        menu = !menu;
        Fabric.cycle();
    }
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
        if (!Fabric.isMobile()) {
            Static.Block(.{
                .position = .{ .top = .px(0), .type = .fixed },
                .width = .percent(14),
                .margin = .{ .right = 32, .top = 60 },
                .padding = .{ .bottom = 128 },
                .z_index = 999,
                .height = .percent(100),
            })({
                Menu.render({});
            });
        } else {
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
                Static.FlexBox(.{ .child_alignment = .between_center, .child_gap = 12, .width = .percent(100) })({
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

                Static.Text("Opinions, Opinions, Opinions!", .{
                    .margin = .{ .top = 32 },
                    .font_size = 28,
                    .font_weight = 900,
                });
                Static.Text(
                    \\While the ideology of opinionated frameworks sounds greate in theory, unfortunatley in practice there are many
                    \\cases where this causes the frameworks themselves to support legacy codebases, and for system to become static,
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
                Static.Text("A UI Node", .{
                    .font_size = 24,
                    .font_weight = 700,
                });
                Static.Text(
                    \\This is a Zig function that creates a flexbox container element in what appears to be a UI framework.
                , .{
                    .font_size = 18,
                });
                Custom.HtmlText(
                    \\<strong>Function Purpose:</strong>
                    \\Creates a flexbox layout container with the provided styling and returns a closure function to 
                    \\properly close/cleanup the element.
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
                                    \\Static dynamic behavior (not dynamically updated)
                                , .{
                                    .font_size = 18,
                                });
                            });
                        });
                        Static.List(.{})({
                            Static.ListItem(.{})({
                                Static.Text(
                                    \\FlexBox as the element type
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
                Custom.HtmlText(
                    \\<strong>Usage pattern:</strong>
                    \\This follows a common pattern where you'd call FlexBox(style) to create the container, 
                    \\add child elements, then call the returned function to properly close the flexbox container. 
                    \\The inline nature suggests it's designed for performance-critical UI code.
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
                    \\We can create our own custom UI node's which hook into the Fabric's engine. The example above, is used in this
                    \\very website, since we only ever render to web, we can make use of a custom UI node.
                , .{
                    .font_size = 18,
                });
                Static.Text("Then in the traversal.js file we just add out custom UI node type", .{
                    .font_size = 18,
                });
                traversal_code_editor.render(0);

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
                            Static.Text(
                                \\State management? Just one global boolean: 'global_rerender'. Run Fabric.cycle() and the UI updates.
                                \\You could even create an interval that calls Fabric.cycle() every tick and never worry about signals
                                \\or state management again.
                            , .{
                                .font_size = 18,
                            });
                        });
                        Static.ListItem(.{})({
                            Static.Text(
                                \\Don't like the UI node syntax? Want to create custom UI nodes with your own styling? Go for it.
                                \\Just call LifeCycle.open(), LifeCycle.configure(), and LifeCycle.close() to add it to the tree hierarchy.
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
}
