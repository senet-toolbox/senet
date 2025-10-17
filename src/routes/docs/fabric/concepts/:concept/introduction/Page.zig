const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const CtxButton = Static.CtxButton;
const Box = Static.Box;
const Center = Static.Center;
const List = Static.List;
const ListItem = Static.ListItem;
const Text = Static.Text;
const Icon = Pure.Icon;
const CodeEditor = @import("../../../../../../components/CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");
const HtmlText = Custom.Chain.HtmlText;

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

var copied: bool = false;
var copied_text: []const u8 = "";
fn copy(text: []const u8) void {
    Fabric.Clipboard.copy(text);
    copied = true;
    copied_text = text;
    Fabric.println("Hello", .{});
    Fabric.cycle();
    Fabric.registerCtxTimeout(500, toggleIcon, .{});
}

fn toggleIcon() void {
    copied = false;
    copied_text = "";
    Fabric.cycle();
}

fn code_snippet_single(text: []const u8) void {
    // Box.style(&.{
    CtxButton(copy, .{text})
    // .tooltip(&.{
    //     .text = "Copy",
    //     .position = .right,
    //     .layout = .center,
    //     .color = .palette(.background),
    //     .background = .palette(.text_color),
    //     .border = .solid(.all(0), .palette(.text_color), .all(4)),
    // })
    .style(&.{
        .visual = .{
            .border = .simple(.palette(.border_color_light)),
            .text_color = .palette(.text_color),
        },
        .padding = .all(8),
        .size = .square_percent(100),
        .direction = .column,
        .layout = .flex,
        .interactive = .{
            .hover = .{ .text_color = .palette(.tint), .border = .{ .color = .palette(.tint) } },
        },
        .position = .relative,
        .cursor = .pointer,
    })({
        Box.style(&.{
            .position = .{ .type = .absolute, .right = .px(8), .top = .px(8) },
            .size = .square_px(22),
            .transition = .{ .duration = 100 },
            .visual = .{
                .border_radius = .all(4),
                .background = .transparent,
            },
            .layout = .center,
            .cursor = .pointer,
        })({
            if (copied and std.mem.eql(u8, text, copied_text)) {
                Icon(.check).style(&.{
                    .visual = .{ .font_size = 16 },
                });
            } else {
                Icon(.clipboard).style(&.{
                    .visual = .{ .font_size = 16 },
                });
            }
        });
        HtmlText(text).style(&.{
            .visual = .{ .font_size = 16 },
            .font_family = "Azeret Mono, monospace",
        });
    });
}

// Render
pub fn render() void {
    // Page Header
    Box.style(&.{
        .layout = .{ .x = .start, .y = .start },
        .child_gap = 16,
        .direction = .column,
    })({
        Text("Introduction").style(&.{
            .visual = .font(32, 700, .palette(.text_color)),
            .font_family = "IBM Plex Sans",
        });
        Text("Fabric, build UIs with Zig!").style(&.{
            .visual = .font(24, 700, .palette(.text_color)),
            .font_family = "IBM Plex Sans",
        });
        Text(
            \\Create Components with Fabric Nodes, and render to the dom, or utilise another renderer to render to anything else.
        ).style(&.{
            .visual = .font(18, null, .palette(.text_color)),
            .margin = .{ .top = 8 },
        });
        Text("Installation").style(&.{
            .visual = .font(24, 700, .palette(.text_color)),
            .margin = .{ .top = 8 },
        });
        code_snippet_single("curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash");
    });

    Text("Fabric Component Example").style(&.{
        .visual = .font(24, 700, .palette(.text_color)),
        .margin = .{ .top = 8 },
    });

    Box.style(&.{ .size = .w(.percent(100)) })({
        code_editor.render(0);
    });
    List.style(&.{})({
        ListItem.style(&.{})({
            Text(
                \\[]const u8 is just a string, ie an array '[]' of constant bytes 'u8' a u8, so 'c' = u8, or 'v' = u8, and 
                \\thus [6]const u8 = &.{'F', 'a', 'b', 'r', 'i', 'c'}, or more consciley []const u8 = "Fabric".
            ).style(&.{
                .visual = .font(14, null, .palette(.text_color)),
                .margin = .{ .bottom = 4 },
            });
        });
        ListItem.style(&.{})({
            Text(
                \\u32 is a number type, just like i32 or u16, or f32, except u32 cannot be negative, i32 can, and f32 are
                \\floating point numbers.
            ).style(&.{
                .visual = .font(14, null, .palette(.text_color)),
                .margin = .{ .bottom = 4 },
            });
        });
        ListItem.style(&.{})({
            Text("a struct is just a object on a high level, we define fields and there type.").style(&.{
                .visual = .font(14, null, .palette(.text_color)),
                .margin = .{ .bottom = 4 },
            });
        });
        ListItem.style(&.{})({
            Text(
                \\AllocText is a UINode that takes a formatted string, and the arguments to insert into said string, allocates 
                \\underneatch the hood.
            ).style(&.{
                .visual = .font(14, null, .palette(.text_color)),
                .margin = .{ .bottom = 4 },
            });
        });
    });

    Text("Pros").style(&.{
        .visual = .font(24, 700, .palette(.text_color)),
        .margin = .{ .top = 8 },
    });
    // Core Functions Section
    Box.style(&.{
        .id = "pros-cons",
        .layout = .{ .x = .start, .y = .start },
        .child_gap = 16,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .size = .w(.percent(100)),
    })({
        List.style(&.{
            .layout = .{ .x = .start, .y = .start },
            .direction = .column,
            .padding = .{ .left = 16 },
            .child_gap = 12,
        })({
            for (pros_items) |item| {
                ListItem.style(&.{})({
                    Text(item).style(&.{
                        .visual = .font(18, null, .palette(.text_color)),
                    });
                });
            }
        });
    });

    Text("Cons").style(&.{
        .visual = .font(24, 700, .palette(.text_color)),
        .margin = .{ .top = 8 },
    });
    // Core Functions Section
    Box.style(&.{
        .layout = .{ .x = .start, .y = .start },
        .child_gap = 16,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .size = .w(.percent(100)),
    })({
        List.style(&.{
            .layout = .{ .x = .start, .y = .start },
            .direction = .column,
            .padding = .{ .left = 16 },
            .child_gap = 12,
        })({
            for (cons_items) |item| {
                ListItem.style(&.{})({
                    Text(item).style(&.{
                        .visual = .font(18, null, .palette(.text_color)),
                    });
                });
            }
        });
    });
}
