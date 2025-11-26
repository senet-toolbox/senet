const std = @import("std");
const Vapor = @import("vapor");
const NavBar = @import("../../components/Navbar.zig");
const Custom = @import("../../components/Custom.zig");
const code_snippet = Custom.code_snippet_single;
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
fn copy(text: []const u8) void {
    Vapor.Clipboard.copy(text);
    copied = true;
    Vapor.registerCtxTimeout(500, toggleIcon, .{});
}

fn toggleIcon() void {
    copied = !copied;
}

pub fn render() void {
    // NavBar.render();
    Center().style(&.{
        .size = .hw(.percent(100), .percent(100)),
    })({
        Box().style(&.{
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
            code_snippet("curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash");
            code_snippet("metal create myapp");
            code_snippet("my-app && metal run web");
        });
    });
}
