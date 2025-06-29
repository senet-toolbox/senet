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
var code_editor_component: CodeEditor = undefined;
var code_editor_lifecycle: CodeEditor = undefined;
var code_editor_global: CodeEditor = undefined;
var code_editor_instance: CodeEditor = undefined;
var code_editor_comptime: CodeEditor = undefined;
// Initialization
pub fn init() void {
    code_editor.init(&Fabric.lib.allocator_global, @embedFile("main_sample.zig"));
    code_editor_component.init(&Fabric.lib.allocator_global, @embedFile("Component.zig"));
    code_editor_lifecycle.init(&Fabric.lib.allocator_global, @embedFile("LifeCycle_sample.zig"));
    code_editor_global.init(&Fabric.lib.allocator_global, @embedFile("global_sample.zig"));
    code_editor_instance.init(&Fabric.lib.allocator_global, @embedFile("instance_sample.zig"));
    code_editor_comptime.init(&Fabric.lib.allocator_global, @embedFile("comptime_sample.zig"));
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
        .margin = .{ .bottom = 32 },
    })({
        Static.Text("main.zig - Application Entry Point", .{
            .font_size = 42,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text("The root entry point for your Fabric application", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
    });

    // Core Functions Section
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 16,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Core Functions", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .bottom = 16 },
        });

        // instantiate function
        Static.FlexBox(.{
            .child_alignment = .{ .x = .start, .y = .start },
            .child_gap = 12,
            .direction = .column,
            .border_radius = .all(8),
            .margin = .{ .bottom = 20 },
        })({
            Static.Text("instantiate(window_width: i32, window_height: i32)", .{
                .font_size = 18,
                .font_weight = 600,
                .text_color = .hex("#802BFF"),
                .font_family = "monospace",
            });
            Static.Text("Initializes the Fabric framework and sets up the application environment.", .{
                .font_size = 18,
                .text_color = .hex("#4a4a4a"),
            });
        });

        // renderUI function
        Static.FlexBox(.{
            .child_alignment = .{ .x = .start, .y = .start },
            .child_gap = 12,
            .direction = .column,
            .border_radius = .all(8),
            .margin = .{ .bottom = 20 },
        })({
            Static.Text("renderUI(route_ptr: [*:0]u8)", .{
                .font_size = 18,
                .font_weight = 600,
                .text_color = .hex("#802BFF"),
                .font_family = "monospace",
            });
            Static.Text("Handles the rendering pipeline for the current route using virtual DOM diffing.", .{
                .font_size = 18,
                .text_color = .hex("#4a4a4a"),
            });
        });
        // renderUI function
        Static.FlexBox(.{
            .child_alignment = .{ .x = .start, .y = .start },
            .child_gap = 12,
            .direction = .column,
            .border_radius = .all(8),
            .margin = .{ .bottom = 20 },
        })({
            Static.Text("export", .{
                .font_size = 18,
                .font_weight = 600,
                .text_color = .hex("#802BFF"),
                .font_family = "monospace",
            });
            Static.Text("The export keyword gives the wasm bridge access to the zig functions", .{
                .font_size = 18,
                .text_color = .hex("#4a4a4a"),
            });
        });
        Static.Svg(@embedFile("client-server.svg"), .{
            .width = .percent(100),
            .height = .percent(100),
        });
    });
    // Virtual DOM Section
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 16,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Virtual DOM & Reconciliation", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .bottom = 16 },
        });

        Static.Text("The rendering system uses a virtual DOM approach with the following features:", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });

        Static.List(.{
            .direction = .column,
            .child_gap = 12,
            .padding = .{ .left = 16 },
            .display = .Flex,
            .child_alignment = .{ .y = .start, .x = .start },
        })({
            Static.ListItem(.{})({
                Static.Text("Tree Construction: Builds a UI tree representation in memory", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            Static.ListItem(.{})({
                Static.Text("Dirty Tracking: Marks nodes that require updates", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            Static.ListItem(.{})({
                Static.Text("Diffing Algorithm: Compares current and new tree states", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            Static.ListItem(.{})({
                Static.Text("Selective Updates: Only updates nodes that have changed", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
        });
        Static.Block(.{
            .width = .percent(80),
        })({
            code_editor.render(0);
        });
    });

    // Virtual DOM Section
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 16,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Basic Concept", .{
            .font_size = 32,
            .font_weight = 600,
            .margin = .{ .bottom = 16 },
        });
        Static.Text("Think of Fabric's UI system like building with blocks. Each UI node (like a FlexBox) is a container that can hold other containers inside it.", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        Static.Svg(@embedFile("tree.svg"), .{ .width = .percent(40), .height = .percent(40) });
        Static.Text("What is a UI Node?", .{
            .font_size = 32,
            .font_weight = 600,
            .margin = .{ .bottom = 16, .top = 16 },
        });
        Static.Text("A UI node represents any visual element in your interface—buttons, text, containers, inputs, and more. Think of them as the building blocks of your UI.", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        Static.List(.{
            .direction = .column,
            .child_gap = 12,
            .padding = .{ .left = 16 },
            .margin = .{ .bottom = 16 },
            .display = .Flex,
            .child_alignment = .{ .y = .start, .x = .start },
        })({
            Static.ListItem(.{})({
                Static.Text("Swift: Text(\"Hello\"), Button(\"Click me\")", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            Static.ListItem(.{})({
                Static.Text("React: <p>Hello</p>, <button>Click me</button>", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            Static.ListItem(.{})({
                Static.Text("Fabric: Static.Text(\"Hello\"), Static.Button(\"Click me\")", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
        });
        Static.Text("UI nodes hold information like their element type, if they need to be rerendered, styling, and more.", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        Static.Text("All UI nodes in Fabric follow a consistent pattern, making them predictable and easy to work with. Whether you're creating a simple text element or a complex interactive component, the underlying structure remains the same—giving you a unified way to build interfaces across any platform.", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        Static.Text("FlexBox(style: Style) => Component, Text(text: []const u8, style: Style) => Component", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Static.Text("Component: *const fn(void) void", .{
            .font_size = 18,
            .font_weight = 600,
        });
        Static.Text("Each UI node takes a style props, and a set of node specific props, and returns a Component, You get back a function that expects void as its argument. This means you can pass anything into it—including other UI nodes:", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        Static.Text("The ({}) syntax is a common Fabric pattern that enables parent-child relationships. The empty braces {} represent the void argument, and everything inside becomes children of that component.", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        Static.Block(.{
            .width = .percent(80),
            .margin = .{ .bottom = 16 },
        })({
            code_editor_component.render(0);
        });
        Static.Text("Constructing the UI Tree using UI Nodes", .{
            .font_size = 32,
            .font_weight = 600,
            .margin = .{ .bottom = 16, .top = 32 },
        });
        Static.FlexBox(.{
            .width = .percent(100),
        })({
            Static.Svg(@embedFile("UI.svg"), .{
                .width = .percent(100),
            });
        });
        Static.Text("LifeCycle Call Structure", .{
            .font_size = 32,
            .font_weight = 600,
            .margin = .{ .bottom = 16 },
        });
        Static.Block(.{
            .width = .percent(80),
            .margin = .{ .bottom = 16 },
        })({
            code_editor_lifecycle.render(0);
        });
        Static.Text("This is how Fabric works under the hood, every UI node gets passed a set of props, we call an internal function called LifeCycle.open, which then open's said UI node to accept children. Then we return a LifeCycle.close function, which takes void as and argument, ie fn (void) void, now anything inside here gets called first and then, once there are no more children and no zig left to call, we exist the function call and we close the UI node.", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        Static.Text("Typical Components structure follows the init() render() pattern. There are three types of components structure conventions typically used.", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        Static.Text("Global Components", .{
            .font_size = 32,
            .font_weight = 600,
            .margin = .{ .bottom = 16, .top = 32 },
        });
        Static.Text("Standard Global components, which take no reference to themselves, and instead just operate on global variables contained in their file. If this Component is rendered in different areas of the codebase they will all use the same global set of variables.", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        code_editor_global.render(0);
        Static.Text("Instance Components", .{
            .font_size = 32,
            .font_weight = 600,
            .margin = .{ .bottom = 16, .top = 32 },
        });
        Static.Text("Instance components, which do reference to themselves, and hence can be instantiated multiple times and use their own set of local variables", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        code_editor_instance.render(0);
        Static.Text("Comptime Components", .{
            .font_size = 32,
            .font_weight = 600,
            .margin = .{ .bottom = 16, .top = 32 },
        });
        Static.Text("Comptime components, which can either reference themselves or use local variables which can exist within the Component instantiation itself. Thus instead of needing to pass the instance ar argument into every function we can operate of the local comptime variables.", .{
            .font_size = 18,
            .text_color = .hex("#4a4a4a"),
            .margin = .{ .bottom = 16 },
        });
        code_editor_comptime.render(0);
    });
}
