const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Page = Fabric.Page;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");

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
        Static.Text("curl -sSL https://raw.githubusercontent.com/vic-Rokx/fabric-cli/main/install.sh | bash", .{
            .font_size = 16,
            .font_family = "Azeret Mono, monospace",
        });
        Static.Text("fabric create myapp", .{
            .font_size = 18,
            .font_family = "Azeret Mono, monospace",
        });
        Static.Text("fabric create run", .{
            .font_size = 18,
            .font_family = "Azeret Mono, monospace",
        });
    });
}
