const std = @import("std");
const Fabric = @import("fabric");
const NavBar = @import("../../components/Navbar.zig");
const Custom = @import("../../components/Custom.zig");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Page = Fabric.Page;
const Pure = Fabric.Pure;

// Initialization
pub fn init() void {
    Page(@src(), render, null, .{});
}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

pub fn render() void {
    NavBar.render();
    Static.Center(.{
        .width = .percent(100),
        .height = .percent(100),
    })({
        Static.FlexBox(.{
            .child_gap = 24,
            .direction = .column,
            .margin = .{ .bottom = 32 },
            .width = .clamp_percent(70, 786, 100),
            .padding = .horizontal(12),
            // .child_alignment = .start_center,
        })({
            Static.Text("Download", .{
                .font_size = 48,
                .font_weight = 700,
                .text_color = .hex("#1a1a1a"),
            });
            Custom.HtmlText("Lets first install <strong style=\"color: #f7a41d;\">Z</strong><strong>IG</strong> via zvm <a href=\"https://www.zvm.app/\">ZVM</a>", .{ .font_size = 20 });
            Static.Image("/assets/ZVM.png", .{
                .position = .{ .type = .absolute, .top = .percent(10), .right = .percent(20) },
                .width = if (Fabric.isMobile()) .percent(30) else .percent(10),
            });
            Static.Image("/assets/ZIG.svg", .{
                .position = .{ .type = .absolute, .bottom = .percent(5), .left = .percent(20) },
                .width = if (Fabric.isMobile()) .percent(40) else .percent(30),
                .height = .percent(30),
            });
            Txt("Now Lets install the Fabric CLI, paste the following into your terminal...");
            Static.Center(.{
                .border_radius = .all(8),
                .border_color = .hex("#bfbfbf"),
                .border_thickness = .all(1),
                .padding = .all(12),
                .width = .percent(100),
                .height = .px(64),
            })({
                Static.Text("curl -sSL https://raw.githubusercontent.com/vic-Rokx/fabric-cli/main/install.sh | bash", .{
                    .font_size = 16,
                    .font_family = "Azeret Mono, monospace",
                });
            });
        });
    });
}
