const std = @import("std");
const Fabric = @import("fabric");
const NavBar = @import("../../components/Navbar.zig");
const Custom = @import("../../components/Custom.zig");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Chain = Fabric.Chain;
const ChainClose = Fabric.ChainClose;
const Center = Chain.Center;
const Box = Chain.Box;
const Image = ChainClose.Image;
const Text = ChainClose.Text;
const Page = Fabric.Page;
const Pure = Fabric.Pure;
const HtmlText = Custom.Chain.HtmlText;
const Graphic = Chain.Graphic;
const Icon = ChainClose.Icon;
const Button = Chain.Button;

// Initialization
pub fn init() void {
    Page(@src(), render, null, &.{});
}

const heading = &Style{
    .visual = .{
        .font_size = 48,
        .font_weight = 700,
        .text_color = .palette(.text_color),
    },
};

const subheading = &Style{
    .visual = .{
        .font_size = 32,
        .font_weight = 700,
        .text_color = .palette(.text_color),
    },
};

const body_text = &Style{
    .visual = .{
        .font_size = 24,
        .font_weight = 700,
        .text_color = .palette(.text_color),
    },
};

const muted_text = &Style{
    .visual = .{
        .font_size = 18,
        .text_color = .palette(.text_color),
    },
};

fn copy() void {
    Fabric.Clipboard.copy("curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash");
}

pub fn render() void {
    // NavBar.render();
    Center.style(&.{
        .size = .hw(.percent(100), .percent(100)),
    })({
        Box.style(&.{
            .child_gap = 24,
            .direction = .column,
            .margin = .{ .bottom = 32 },
            .size = .w(.mobile_desktop_percent(100, 70)),
            .padding = .horizontal(12),
        })({
            Text("Install").style(heading);
            HtmlText("Lets first install <strong style=\"color: #f7a41d;\">Z</strong><strong>IG</strong> via zvm <a href=\"https://www.zvm.app/\">ZVM</a>").style(&.{ .visual = .{ .font_size = 20 } });
            Image(.{ .src = "/assets/ZVM.png" }).style(&.{
                .position = .{ .type = .absolute, .top = .percent(10), .right = .percent(20) },
                .size = .w(if (Fabric.isMobile()) .percent(30) else .percent(10)),
            });
            Image(.{ .src = "/assets/ZIG.svg" }).style(&.{
                .position = .{ .type = .absolute, .bottom = .percent(5), .left = .percent(20) },
                .size = .hw(.percent(30), .mobile_desktop_percent(40, 30)),
            });
            Text("Now Lets install the Metal CLI, paste the following into your terminal...").style(muted_text);
            Box.style(&.{
                .visual = .{ .border = .solid(.all(1), .palette(.border_color), .all(8)) },
                .padding = .all(12),
                .size = .hw(.px(64), .percent(100)),
                .layout = .x_between_center,
            })({
                Text("curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash").style(&.{
                    .visual = .{ .font_size = 18 },
                    .font_family = "Azeret Mono, monospace",
                    .layout = .center,
                    .size = .w(.grow),
                });
                Button(.{ .on_press = copy }).style(&.{
                    .visual = .bg(.transparent),
                })({
                    Icon("bi bi-clipboard").style(&.{
                        .visual = .{ .font_size = 20, .text_color = .palette(.text_color) },
                        .interactive = .hover_text(.palette(.tint)),
                    });
                });
            });
        });
    });
}
