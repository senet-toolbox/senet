const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Page = Fabric.Page;
const Pure = Fabric.Pure;

// Initialization
pub fn init() void {
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
        Static.Text("curl -sSL https://raw.githubusercontent.com/senet-toolbox/metal/main/install.sh | bash", .{
            .font_size = 16,
            .font_family = "Azeret Mono, monospace",
        });
        Static.Text("metal reverb create my-reverb-app", .{
            .font_size = 18,
            .font_family = "Azeret Mono, monospace",
        });
        Static.Text("metal reverb run", .{
            .font_size = 18,
            .font_family = "Azeret Mono, monospace",
        });
    });
}
