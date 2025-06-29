const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const Menu = @import("Menu.zig");
const CodeEditor = @import("concepts/:concept/CodeEditor.zig");

// Initialization
var code_view_loc: CodeEditor = undefined;
pub fn init() void {
    code_view_loc.init(&Fabric.lib.allocator_global, @embedFile("10loc.zig"));

    Page(@src(), render, null, .{});
}

// Deinitialization
pub fn deinit() void {}

// Render
const description =
    \\ Fabric is a universal tree renderer that takes styled component hierarchies and renders them natively across platforms—from web browsers to iOS and macOS apps. Unlike black-box solutions, Fabric gives you direct access to the rendering pipeline, so you can customize and optimize the engine for your exact use case.
;

const Route = struct {
    title: []const u8,
    path: []const u8,
};

const routes = [_]Route{
    .{ .title = "Introduction", .path = "/docs/fabric/concepts/introduction" },
    .{ .title = "Fabric Basics", .path = "/docs/fabric/concepts/basics" },
    .{ .title = "Static, Pure, Dynamic, Grain", .path = "/docs/fabric/concepts/reactivity" },
    .{ .title = "Routing", .path = "/docs/fabric/concepts/routing" },
    .{ .title = "Theme and Style", .path = "/docs/fabric/concepts/theme-and-style" },
    .{ .title = "Reactivity & Signals", .path = "/docs/fabric/concepts/reactivity-signals" },
    .{ .title = "Kit", .path = "/docs/fabric/concepts/kit" },
    .{ .title = "Icons and Svgs", .path = "/docs/fabric/concepts/icons-and-svgs" },
    .{ .title = "Authentication", .path = "/docs/fabric/concepts/authentication" },
    .{ .title = "Using JS Libraries", .path = "/docs/fabric/concepts/using-js-libraries" },
    .{ .title = "Wasm Bridge", .path = "/docs/fabric/concepts/wasm-bridge" },
    .{ .title = "Custom Components", .path = "/docs/fabric/concepts/custom-components" },
    .{ .title = "Renderers & UI-Tree", .path = "/docs/fabric/concepts/renderers-ui-tree" },
    .{ .title = "Building a UI Layout Algorithmn", .path = "/docs/fabric/concepts/building-ui-layout-algorithm" },
    .{ .title = "Building a Reconciler", .path = "/docs/fabric/concepts/building-reconciler" },
    .{ .title = "Building a Renderer", .path = "/docs/fabric/concepts/building-renderer" },
};

pub fn render() void {
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .padding = .horizontal(12),
        .direction = .row,
        .width = .percent(100),
        .height = .percent(100),
    })({
        Fabric.Layout(@src(), .{})({
            Static.Block(.{
                .width = .percent(12),
                .margin = .{ .right = 32 },
            })({
                Menu.render();
            });
        });
        Static.FlexBox(.{
            .height = .percent(100),
            .width = .grow,
            .child_alignment = .{ .y = .start, .x = .center },
            .padding = .{ .top = 60 },
        })({
            Static.FlexBox(.{
                .width = .percent(62),
                .child_gap = 16,
                .direction = .column,
                .child_alignment = .{ .x = .start, .y = .start },
            })({
                Static.Text("Fabric", .{
                    .font_size = 56,
                    .font_weight = 700,
                });
                Static.Text("An Exposed UI Toolkit", .{
                    .font_size = 32,
                    .font_weight = 700,
                });
                Static.Image("/assets/FabricKit.png", .{
                    .width = .percent(100),
                    .border_radius = .all(8),
                    .margin = .{ .bottom = 32 },
                });
                Static.Text("What is Fabric?", .{
                    .margin = .{ .top = 32 },
                    .font_size = 32,
                    .font_weight = 700,
                });
                Static.Text("Fabric is toolkit-first, framework-second. We believe developers should control their tools, not the other way around. Every API is explicitly exposed, every internal is accessible, and every component can be customized. No black boxes, no hidden magic—just transparent, controllable architecture that puts you in the driver's seat.", .{
                    .font_size = 18,
                });
                Static.Text("Opinions, Opinions, Opinions!", .{
                    .margin = .{ .top = 32 },
                    .font_size = 28,
                    .font_weight = 900,
                });
                Static.Text("Frameworks love to tell you how to think. React: \"Use classes!\" Then: \"Actually, use functions!\" Svelte: \"Everything is state!\" Then: \"Actually, use runes!\" Every framework eventually pivots, leaving developers with broken code and migration headaches.", .{
                    .font_size = 18,
                });
                Static.Text("Fabric's approach is fundamentally different. By exposing all internals within a compact 8K-line codebase and providing direct engine access, we eliminate framework lock-in. Developers retain full control over their architecture while benefiting from a lightweight foundation where <a href=\"/docs/fabric/concepts/ui-nodes\">UI nodes</a> require just 10 lines of code.", .{
                    .font_size = 18,
                });

                code_view_loc.render(0);
                Static.Text("That's it!", .{
                    .margin = .{ .top = 16 },
                    .font_size = 32,
                    .font_weight = 900,
                });
                Static.Text("That's literally the entirety of Fabric at its core. It takes a bunch of UI nodes, constructs a tree, and outputs it to any renderer you want to use or build.", .{
                    .font_size = 18,
                });

                Static.List(.{
                    .margin = .{ .top = 16, .bottom = 16 },
                    .padding = .{ .left = 32 },
                    .display = .Flex,
                    .child_gap = 32,
                    .direction = .column,
                    .child_alignment = .{ .x = .start, .y = .start },
                })({
                    Static.ListItem(.{})({
                        Static.Text("State management? Just one global boolean: 'global_rerender'. Set it to true and the UI updates. You could even create an interval that toggles global_rerender every tick and never worry about signals or state management again.", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("Don't like the UI node syntax? Want to create custom UI nodes with your own styling? Go for it. Just call LifeCycle.open(), LifeCycle.configure(), and LifeCycle.close() to add it to the tree hierarchy.", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("Want to use your own renderers, your own conventions, your own ideas! Now you can!", .{
                            .font_size = 18,
                        });
                    });
                });
                Static.Text("No surprises, no magic, no migrations—just code that works the way you expect it to.", .{
                    .font_size = 22,
                    .font_weight = 700,
                });

                // Static.FlexBox(.{})({
                // Static.Image("/assets/before.png", .{
                //     .width = .percent(50),
                // });
                // Static.Image("/assets/after.png", .{
                //     .width = .percent(50),
                // });
                // });

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
                            Static.Link(route.path, .{
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
