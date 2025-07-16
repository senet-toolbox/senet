const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Page = Fabric.Page;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");
const Grain = Fabric.Grain;

// Initialization
var wasi_js_code_editor: CodeEditor = undefined;
var chart_code_editor: CodeEditor = undefined;
var chart_use_code_editor: CodeEditor = undefined;
pub fn init() void {
    // wasi_js_code_editor.init(&Fabric.lib.allocator_global, @embedFile("chart.js"));
    // chart_code_editor.init(&Fabric.lib.allocator_global, @embedFile("chart_sample.zig"));
    // chart_use_code_editor.init(&Fabric.lib.allocator_global, @embedFile("chart_use_case_sample.zig"));
    // sample_inst_events.init(&Fabric.lib.allocator_global, @embedFile("inst_even_sample.zig"));
}

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
    Static.Box(.{
        .height = .percent(100),
        .background = .hex("#282a36"),
        .border_radius = .all(8),
        .padding = .all(8),
        .width = .percent(100),
        .direction = .column,
        .position = .{ .type = .relative },
    })({
        Static.CtxButton(copy, .{text}, .{
            .width = .px(22),
            .height = .px(22),
            .border_radius = .all(4),
            .display = .Center,
            .cursor = .pointer,
            .transition = .{ .duration = 300 },
            .hover = .{ .background = .hex("#2D303E") },
            .position = .{ .type = .absolute, .right = .px(8), .top = .px(8) },
        })({

            if (copied and std.mem.eql(u8, text, copied_text)) {
                Pure.Icon("bi bi-check", .{
                    .font_size = 16,
                    .text_color = .hex("#cccccc"),
                    .transition = .{ .duration = 300 },
                    .hover = .{ .text_color = .hex("#ffffff") },
                });
            } else {
                Pure.Icon("bi bi-clipboard", .{
                    .font_size = 16,
                    .text_color = .hex("#cccccc"),
                    .transition = .{ .duration = 300 },
                    .hover = .{ .text_color = .hex("#ffffff") },
                });
            }
        });
        Custom.HtmlText(text, .{
            .font_size = 16,
            .text_color = .hex("#ffffff"),
        });
    });
}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

pub fn render() void {
    Static.FlexBox(.{
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Just let me build!!!", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        code_snippet_single("curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash");
        code_snippet_single("metal create myapp");
        code_snippet_single("metal fabric run");
    });
}
