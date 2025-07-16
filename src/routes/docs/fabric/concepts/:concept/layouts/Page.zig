const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Custom = @import("../../../../../../components/Custom.zig");
const CodeEditor = @import("../CodeEditor.zig");

// Initialization
var users_layout: CodeEditor = undefined;
pub fn init() void {
    users_layout.init(&Fabric.lib.allocator_global, @embedFile("user_layout_sample.zig"));
}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

pub fn render() void {
    Static.Box(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 8,
        .direction = .column,
        .margin = .{ .bottom = 32 },
    })({
        Static.Text("Layouts", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .bottom = 16 },
        });

        Static.Text("Layouts are a powerful tool for building complex UIs. They allow you to create a hierarchy of components that can be nested and positioned in a flexible way.", .{
            .font_size = 18,
            .margin = .{ .bottom = 16 },
        });

        Static.Text("Every framework has its own way of defining layouts. Fabric uses a explicit functionaly approach, you can register a layout anywhere in your codebase.", .{
            .font_size = 18,
            .margin = .{ .bottom = 16 },
        });
        Custom.code_snippet_single(
            \\Fabric.lib.registerLayout("/app/users", users_layout);
        );
        users_layout.render(0);
        Static.Text(
            \\We can also created nested layouts:
        , .{
            .font_size = 18,
            .margin = .{ .bottom = 16, .top = 16 },
        });
        Custom.code_snippet_single(
            \\Fabric.lib.registerLayout("/app/users/tables", users_layout);
        );
        Static.Text(
            \\Fabric will handle the nested layouts automatically, they can be treated the same as any other layout.
        , .{
            .font_size = 18,
            .margin = .{ .bottom = 16 },
        });
        Custom.HtmlText(
            \\By default, Fabric will rerender and, mark all nodes as dirty when the route changes.
            \\This is because reloads should cause a full rerender and call to the server. However, if we want to remember the layout state, 
            \\instead of doing a recalculation and inserting the UI nodes again, we can wrap the Component that we wish to remember across
            \\route changes via the <code>Remember(SourceLocation)</code> function.
        , .{
            .font_size = 18,
            .margin = .{ .bottom = 16 },
        });
    });
}
