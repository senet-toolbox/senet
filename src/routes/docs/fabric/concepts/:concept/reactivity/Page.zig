const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const ViewCode = @import("../ViewCode.zig");
const CodeEditor = @import("../CodeEditor.zig");

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

var view_code: ViewCode = undefined;
var code_editor: CodeEditor = undefined;
var get_code_editor: CodeEditor = undefined;
var set_code_editor: CodeEditor = undefined;
var append_code_editor: CodeEditor = undefined;
var toggle_code_editor: CodeEditor = undefined;
var increment_code_editor: CodeEditor = undefined;
var decrement_code_editor: CodeEditor = undefined;
var dyanmic_code_editor: CodeEditor = undefined;

var fabric_code_editor: CodeEditor = undefined;
var react_code_editor: CodeEditor = undefined;
var svelte_code_editor: CodeEditor = undefined;
var fabric_style_code_editor: CodeEditor = undefined;

const items: []const []const u8 = &.{
    "set",
    "get",
    "toggle",
    "append",
    "getElement",
    "decrement",
    "increment",
    "compare",
    "force",
    "subscribe",
    "tether",
    "update",
    "derived",
    "effect",
    "startBatch",
    "endBatch",
};
// Initialization
pub fn init() void {
    code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_sample.zig"));
    get_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_get_sample.zig"));
    set_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_set_sample.zig"));
    append_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_append_sample.zig"));
    toggle_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_toggle_sample.zig"));
    increment_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_increment_sample.zig"));
    decrement_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_decrement_sample.zig"));
    fabric_code_editor.init(&Fabric.lib.allocator_global, @embedFile("fabric_sample.zig"));
    react_code_editor.init(&Fabric.lib.allocator_global, @embedFile("react_sample.js"));
    svelte_code_editor.init(&Fabric.lib.allocator_global, @embedFile("svelte_sample.svelte"));
    fabric_style_code_editor.init(&Fabric.lib.allocator_global, @embedFile("fabric_style_sample.zig"));
    // dyanmic_code_editor.init(&Fabric.lib.allocator_global, @embedFile("dynamic_sample.zig"));
}

// Deinitialization
pub fn deinit() void {}

// Render
pub fn render() void {
    // Page Header
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Reactivity", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Block(.{})({
            Static.Text("Reactivity in Fabric is defined and used via ", .{
                .display = .Inline,
                .font_size = 18,
                .text_color = .hex("#666666"),
            });

            Static.Text("Static", .{
                .display = .Inline,
                .font_size = 16,
                .background = .hex("#802bff"),
                .text_color = .hex("#ffffff"),
                .padding = .all(4),
                .border_radius = .all(4),
            });
            Static.Text(", ", .{
                .display = .Inline,
                .font_size = 18,
                .text_color = .hex("#666666"),
            });
            Static.Text("Pure", .{
                .display = .Inline,
                .font_size = 16,
                .background = .hex("#802bff"),
                .text_color = .hex("#ffffff"),
                .padding = .all(4),
                .border_radius = .all(4),
            });
            Static.Text(", ", .{
                .display = .Inline,
                .font_size = 18,
                .text_color = .hex("#666666"),
            });
            Static.Text("Dynamic", .{
                .display = .Inline,
                .font_size = 16,
                .background = .hex("#802bff"),
                .text_color = .hex("#ffffff"),
                .padding = .all(4),
                .border_radius = .all(4),
            });
            Static.Text(", and", .{
                .display = .Inline,
                .font_size = 18,
                .text_color = .hex("#666666"),
            });
            Static.Text("Grain", .{
                .display = .Inline,
                .font_size = 16,
                .background = .hex("#802bff"),
                .text_color = .hex("#ffffff"),
                .padding = .all(4),
                .border_radius = .all(4),
            });
            Static.Text("Components, as well as ", .{
                .display = .Inline,
                .font_size = 18,
                .text_color = .hex("#666666"),
            });
            Static.Text("Signals", .{
                .display = .Inline,
                .font_size = 16,
                .background = .hex("#802bff"),
                .text_color = .hex("#ffffff"),
                .padding = .all(4),
                .border_radius = .all(4),
            });
        });
    });
    Static.Center(.{
        .width = .percent(100),
        .height = .percent(100),
    })({
        Static.Svg(@embedFile("reactivity.svg"), .{
            .width = .percent(70),
            .height = .percent(70),
        });
    });
    Static.Text("Static, Pure, Dynamic, Grain", .{
        .font_size = 32,
        .font_weight = 600,
        .text_color = .hex("#1a1a1a"),
    });
    Txt("The differentiation between Static, Pure, Dynamic, and Grain Components, is due to Fabric's core philosophy of explicit and readable code. Within Fabric and Tether, coding is meant to be more cumbersome than reading code.");
    Txt("For example in a typical React or Svelte App we have this situation the ui layout and syntax is simpler than Fabric");
    Static.Text("React", .{ .font_size = 18, .margin = .{ .top = 8 } });
    Static.Block(.{ .width = .percent(100) })({
        react_code_editor.render(0);
    });

    Static.Text("Svelte", .{ .font_size = 18, .margin = .{ .top = 8 } });
    Static.Block(.{ .width = .percent(100) })({
        svelte_code_editor.render(0);
    });
    Static.Text("Fabric", .{ .font_size = 18, .margin = .{ .top = 8 } });
    Static.Block(.{ .width = .percent(100) })({
        fabric_code_editor.render(0);
    });
    Txt("While Svelte offers clean, intuitive syntax, this simplicity comes with constraints. Svelte's reactive syntax only functions within .svelte files, creating architectural limitations. For instance, if you need to integrate Svelte components with utility classes like a Builder pattern, you must move that logic into the Svelte file itself, breaking separation of concerns.");
    Static.Block(.{})({
        Static.Text("In larger Svelte applications, distinguishing between static and reactive content becomes challenging. Developers must scan through code looking for the ", .{
            .display = .Inline,
            .font_size = 18,
        });
        Static.Text("{{ state }}", .{
            .display = .Inline,
            .font_size = 16,
            .background = .hex("#802bff"),
            .text_color = .hex("#ffffff"),
            .padding = .all(4),
            .border_radius = .all(4),
        });
        Static.Text(" syntax to identify where reactivity occurs. This lack of explicit state declaration can make codebases harder to maintain and debug.", .{
            .display = .Inline,
            .font_size = 18,
        });
    });
    Static.Block(.{})({
        Static.Text("In contrast, Fabric provides a clearer architectural patterns where developers can easily identify ", .{
            .display = .Inline,
            .font_size = 18,
        });
        Static.Text("Pure", .{
            .display = .Inline,
            .font_size = 16,
            .background = .hex("#802bff"),
            .text_color = .hex("#ffffff"),
            .padding = .all(4),
            .border_radius = .all(4),
        });
        Static.Text(" or ", .{
            .display = .Inline,
            .font_size = 20,
        });
        //
        Static.Text("Dynamic", .{
            .display = .Inline,
            .font_size = 16,
            .background = .hex("#802bff"),
            .text_color = .hex("#ffffff"),
            .padding = .all(4),
            .border_radius = .all(4),
        });
        Static.Text(" components through simple lookups, making the codebase more navigable and maintainable.", .{
            .display = .Inline,
            .font_size = 20,
        });
    });

    Txt("Both Svelte and React rely on the integration of three distinct languages: HTML, JavaScript, and CSS. These languages weren't designed to work together seamlessly, requiring various workarounds and \"tricks\" to achieve proper integration.");
    Txt("Consider a common scenario: passing parameters from JavaScript into HTML that CSS can then utilize. This seemingly simple task requires complex coordination between the three languages, often resulting in brittle or verbose solutions.");
    Txt("The HTML-based approach in both frameworks introduces type safety issues, particularly with styling. Inline styles lack compile-time validation, allowing errors like width: 100$; to pass through the build process and cause runtime issues.");
    Static.Block(.{ .width = .percent(100) })({
        fabric_style_code_editor.render(0);
    });
    Txt("Additionally, since styles must be defined as strings, developers lose the powerful programmatic capabilities that structured approaches like Fabric's Style struct provide. Fabric enables programmatic style composition through Style.merge() and Style.override(), compile-time validation of properties, and full IDE support with autocomplete and type checking. In contrast, string-based styling cannot be easily composed, validated, or manipulated as first-class data structures, making Fabric's structured approach significantly more maintainable for complex styling requirements.");
    Txt("Furthermore, since every component in Fabric is a function, this means we can utilise varying patterns to return components based of input arguments, enums, or even comptime types.");
    Txt("This software architecture, becomes even more powerful, when creating your own Style Components Library.");
    Txt("These patterns are used for the Generic button component in Opaque Components Library.");

    Static.Text("Static Components", .{
        .font_size = 24,
        .font_weight = 600,
        .text_color = .hex("#1a1a1a"),
    });
    Txt("Static Components are instantiated and rendered once, thus if there props change or styling or anything else, they will not rerender. However, using the force_all_rerender global variable, will cause the Static Components and all other components to rerender.");
    Txt("Static components are best used for Text or FlexBoxes, or components which are mainly used for layout or static content such as Headers or documentation.");

    Static.Text("Pure Components", .{
        .font_size = 24,
        .font_weight = 600,
        .text_color = .hex("#1a1a1a"),
    });
    Txt("Pure components work just like static components, except during reconciliation there props are checked, between both trees, thus if any of their fields or props, or arguments have changed they will rerender.");

    Static.Text("Dynamic Components", .{
        .font_size = 24,
        .font_weight = 600,
        .text_color = .hex("#1a1a1a"),
    });
    Txt("Dynamic components take a Signal by default, this attaches the signal to the element itself, ie the UI node subscribes to this signal, and will rerender when that Signal is changed.");

    Static.Text("Grain Components", .{
        .font_size = 24,
        .font_weight = 600,
        .text_color = .hex("#1a1a1a"),
    });
    Txt("Grain components take a Signal as well, but are the most surgical component type in Fabric, no reconciliation will occur, no diffing nothing, only this specfic grain component will be rerendered, none of its children or parents. This is best used as the ListItem in a massive List.");

    Static.Text("Recommendation", .{
        .font_size = 24,
        .font_weight = 600,
        .text_color = .hex("#1a1a1a"),
    });
    Txt("Just use Static and Pure components, Grain and Dynamic are overated and very niche use case, the entirety of NightWatch is built with Static and Pure components, and Fabric's reconciliation algo, and rerendering is incredibly fast.");

    Static.Text("Signals", .{
        .font_size = 24,
        .font_weight = 600,
        .text_color = .hex("#1a1a1a"),
    });

    Txt("Signals are used to update the UI nodes in your UI tree.");

    Static.Text("Signal(comptime T: type)", .{
        .font_size = 18,
        .font_weight = 600,
        .text_color = .hex("#802BFF"),
        .font_family = "monospace",
    });
    Static.Svg(@embedFile("signal_diagram.svg"), .{
        .width = .percent(100),
        .height = .percent(100),
    });

    Static.Block(.{
        .width = .percent(100),
    })({
        code_editor.render(0);
    });

    Static.Text("Signal Operations", .{
        .font_size = 48,
        .font_weight = 700,
        .text_color = .hex("#1a1a1a"),
    });
    // Core Functions Section
    Static.Column(.{
        .child_gap = 16,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.List(.{
            .display = .Flex,
            .direction = .column,
            .padding = .{ .left = 16 },
            .child_gap = 12,
        })({
            for (items) |item| {
                Static.ListItem(.{})({
                    Static.Text(item, .{
                        .font_size = 18,
                        .text_color = .hex("#2a2a2a"),
                    });
                });
            }
        });
    });
    Static.Text("Get", .{
        .font_size = 18,
        .font_weight = 700,
    });
    Static.Text("get the current value of the signal", .{
        .font_size = 18,
    });
    Static.Block(.{
        .width = .percent(100),
    })({
        get_code_editor.render(0);
    });
    Static.Text("Set", .{
        .font_size = 18,
        .font_weight = 700,
    });
    Static.Text("set the signal value", .{
        .font_size = 18,
    });
    Static.Block(.{
        .width = .percent(100),
    })({
        set_code_editor.render(0);
    });
    Static.Text("Append", .{
        .font_size = 18,
        .font_weight = 700,
    });
    Static.Text("append a new value only works on type Signal(ArrayList(T))", .{
        .font_size = 18,
    });
    Static.Block(.{
        .width = .percent(100),
    })({
        append_code_editor.render(0);
    });
    Static.Text("Toggle", .{
        .font_size = 18,
        .font_weight = 700,
    });
    Static.Text("toggle the boolean signal value only works on type Signal(bool)", .{
        .font_size = 18,
    });
    Static.Block(.{
        .width = .percent(100),
    })({
        toggle_code_editor.render(0);
    });
    Static.Text("Increment", .{
        .font_size = 18,
        .font_weight = 700,
    });
    Static.Text("increment the current value only works on number types", .{
        .font_size = 18,
    });
    Static.Block(.{
        .width = .percent(100),
    })({
        increment_code_editor.render(0);
    });
    Static.Text("Decrement", .{
        .font_size = 18,
        .font_weight = 700,
    });
    Static.Text("decrement the current value only works on number types", .{
        .font_size = 18,
    });
    Static.Block(.{
        .width = .percent(100),
    })({
        decrement_code_editor.render(0);
    });
}
