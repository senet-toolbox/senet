const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

var code_editor: CodeEditor = undefined;
// Initialization
pub fn init() void {
    // code_editor.init(&Fabric.lib.allocator_global, @embedFile("main_sample.zig"));
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
    })({
        Static.Text("Introduction", .{
            .font_size = 42,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text(
            \\Create backend web servers with Reverb. Reverb is a web server framework for Tether, built for extreme performance.
        , .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Static.Center(.{
            .width = .percent(100),
            .margin = .{ .bottom = 32 },
        })({
            Static.Image("/assets/reverb.webp", .{
                .width = .percent(40),
                .height = .percent(100),
            });
        });

        Static.Text("Installation", .{
            .font_size = 24,
            .font_weight = 700,
            .margin = .{ .top = 8 },
        });
        Static.Center(.{
            .id = "curl-install",
            .border_radius = .all(8),
            .border_color = .hex("#bfbfbf"),
            .border_thickness = .all(1),
            .padding = .all(12),
            .width = .percent(100),
        })({
            Static.Text("curl -sSL https://raw.githubusercontent.com/vic-Rokx/metal/main/install.sh | bash", .{
                .font_size = 16,
                .font_family = "Azeret Mono, monospace",
            });
        });
    });
}
