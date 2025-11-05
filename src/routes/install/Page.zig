const std = @import("std");
const Vapor = @import("vapor");
const NavBar = @import("../../components/Navbar.zig");
const Custom = @import("../../components/Custom.zig");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Center = Static.Center;
const Box = Static.Box;
const Image = Static.Image;
const Text = Static.Text;
const Page = Vapor.Page;
const Pure = Vapor.Pure;
const HtmlText = Custom.Chain.HtmlText;
const Graphic = Static.Graphic;
const Icon = Static.Icon;
const Button = Static.Button;
const CtxButton = Static.CtxButton;

// Initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

const heading = &Style{
    .visual = .{
        .font_size = 32,
        .font_weight = 500,
        .text_color = .palette(.text_color),
    },
    .font_family = "IBM Plex Sans",
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

var copied: bool = false;
var copied_text: []const u8 = "";
fn copy(text: []const u8) void {
    Vapor.Clipboard.copy(text);
    copied = true;
    copied_text = text;
    Vapor.println("Hello", .{});
    Vapor.cycle();
    Vapor.registerCtxTimeout(500, toggleIcon, .{});
}

fn toggleIcon() void {
    copied = false;
    copied_text = "";
    Vapor.cycle();
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
            .cursor = .pointer,
            .background = .transparent,
        },
        .padding = .all(8),
        .size = .square_percent(100),
        .direction = .column,
        .layout = .flex,
        .interactive = .{
            .hover = .{ .text_color = .palette(.tint), .border = .{ .color = .palette(.tint) } },
        },
        .position = .relative,
    })({
        Box.style(&.{
            .position = .{ .type = .absolute, .right = .px(8), .top = .px(8) },
            .size = .square_px(22),
            .transition = .{ .duration = 100 },
            .visual = .{
                .border_radius = .all(4),
                .background = .transparent,
                .cursor = .pointer,
            },
            .layout = .center,
        })({
            if (copied and std.mem.eql(u8, text, copied_text)) {
                Icon(.check).style(&.{
                    .visual = .{ .font_size = 18 },
                });
            } else {
                Icon(.clipboard).style(&.{
                    .visual = .{ .font_size = 18 }, // we need to fix this to make sure it does not repalce the class of the text below
                    // setting it to 16 results in the Text below being overwritten
                });
            }
        });
        Text(text).style(&.{
            .visual = .{ .font_size = 16 },
            .font_family = "Azeret Mono, monospace",
            .layout = .center,
            .size = .w(.grow),
        });
    });
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
            Image(.{ .src = "/assets/ZVM.png" }).style(&.{
                .position = .{ .type = .absolute, .top = .percent(10), .right = .percent(20) },
                .size = .w(if (Vapor.isMobile()) .percent(30) else .percent(10)),
            });
            Image(.{ .src = "/assets/ZIG.svg" }).style(&.{
                .position = .{ .type = .absolute, .bottom = .percent(5), .left = .percent(20) },
                .size = .hw(.percent(30), .mobile_desktop_percent(40, 30)),
            });
            code_snippet_single("curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash");
        });
    });
}
