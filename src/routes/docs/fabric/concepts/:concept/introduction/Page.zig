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
const pros_items: []const []const u8 = &.{
    "Shipped with no dependencies, Version stability",
    "Explicit in design, simple in nature",
    "No breaking changes or forced migrations",
    "Direct system access",
    "Browsers parse WASM 10x-20x faster than JS",
    "WASM is 1.5x-4x faster during runtime",
    "No runtime (node.js, deno, ...)",
    "Embed your favorite JS Libraries",
    "Construct or modify GLUE the WASM Bridge",
    "Fabric only allocates at start up, no memory is allocated during runtime.",
    "Only Zig no html, js, ts, tsx, rsx, jsx",
    "Can interop with objc, c, c++",
    "Built for long term projects",
    "Vast internal ecosystem of tooling and functionality, maintained by Tether Group.",
    "No Docker, just one binary file.",
    "Can run on any platform.",
    "Compiles to WASM and sent down the wire, resulting in client side rendering.",
    "Memory safety",
};
const cons_items: []const []const u8 = &.{
    "Zig learning curve overhead. If Rust is a 9 in difficulty, Zig is a 6 and JS is a 3.",
    "Zig is new, and has smaller ecosystem, and documentation.",
    "Another Shiny new Tool.",
    "Learning Fabric overhead. However, if you know Zig its pretty easy!",
    "Hiring challenges",
    "Debugging tools",
};
// Initialization
pub fn init() void {
    code_editor.init(&Fabric.lib.allocator_global, @embedFile("sample.zig"));
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
    })({
        Static.Text("Introduction", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text("Fabric, build UIs with Zig!", .{
            .font_size = 36,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text("Create Components with Fabric Nodes, and render to the dom, or utilise another renderer to render to anything else.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Static.Text("Installation", .{
            .font_size = 24,
            .font_weight = 700,
            .margin = .{ .top = 8 },
        });
        Static.Center(.{
            .border_radius = .all(8),
            .border_color = .hex("#bfbfbf"),
            .border_thickness = .all(1),
            .padding = .all(12),
            .width = .percent(100),
            .height = .fixed(64),
        })({
            Static.Text("curl -sSL https://raw.githubusercontent.com/vic-Rokx/fabric-cli/main/install.sh | bash", .{
                .font_size = 16,
                .font_family = "Azeret Mono, monospace",
            });
        });
    });

    Static.Text("Fabric Component Example", .{
        .font_size = 24,
        .font_weight = 700,
        .margin = .{ .top = 8 },
    });

    Static.Block(.{
        .width = .percent(100),
    })({
        code_editor.render(0);
    });
    Static.Block(.{
        .padding = .{ .left = 32 },
    })({
        Static.ListItem(.{})({
            Static.Text("[]const u8 is just a string, ie an array '[]' of constant bytes 'u8' a u8, so 'c' = u8, or 'v' = u8, and thus [6]const u8 = &.{'F', 'a', 'b', 'r', 'i', 'c'}, or more consciley []const u8 = \"Fabric\".", .{
                .font_size = 14,
                .text_color = .hex("#666666"),
                .margin = .{ .bottom = 4 },
            });
        });
        Static.ListItem(.{})({
            Static.Text("u32 is a number type, just like i32 or u16, or f32, except u32 cannot be negative, i32 can, and f32 are floating point numbers.", .{
                .font_size = 14,
                .text_color = .hex("#666666"),
                .margin = .{ .bottom = 4 },
            });
        });
        Static.ListItem(.{})({
            Static.Text("a struct is just a object on a high level, we define fields and there type.", .{
                .font_size = 14,
                .text_color = .hex("#666666"),
                .margin = .{ .bottom = 4 },
            });
        });
        Static.ListItem(.{})({
            Static.Text("AllocText is a UINode that takes a formatted string, and the arguments to insert into said string, allocates underneatch the hood.", .{
                .font_size = 14,
                .text_color = .hex("#666666"),
                .margin = .{ .bottom = 4 },
            });
        });
    });

    Static.Text("Pros", .{
        .font_size = 24,
        .font_weight = 700,
        .margin = .{ .top = 8 },
    });
    // Core Functions Section
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 16,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.List(.{
            .display = .Flex,
            .child_alignment = .{ .x = .start, .y = .start },
            .direction = .column,
            .padding = .{ .left = 16 },
            .child_gap = 12,
        })({
            for (pros_items) |item| {
                Static.ListItem(.{})({
                    Static.Text(item, .{
                        .font_size = 18,
                        .text_color = .hex("#2a2a2a"),
                    });
                });
            }
        });
    });

    Static.Text("Cons", .{
        .font_size = 24,
        .font_weight = 700,
        .margin = .{ .top = 8 },
    });
    // Core Functions Section
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 16,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.List(.{
            .display = .Flex,
            .child_alignment = .{ .x = .start, .y = .start },
            .direction = .column,
            .padding = .{ .left = 16 },
            .child_gap = 12,
        })({
            for (cons_items) |item| {
                Static.ListItem(.{})({
                    Static.Text(item, .{
                        .font_size = 18,
                        .text_color = .hex("#2a2a2a"),
                    });
                });
            }
        });
    });
}
