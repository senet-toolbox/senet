const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Box = Vapor.Box;
const Text = Vapor.Text;
const RedirectLink = Vapor.RedirectLink;
const Image = Vapor.Image;
const Svg = Vapor.Svg;
const Button = Vapor.Button;
const Custom = @import("../../../../../../components/Custom.zig");
const HtmlText = Custom.Chain.HtmlText;
const CtxButton = Vapor.CtxButton;
const List = Vapor.List;
const ListItem = Vapor.ListItem;
const Graphic = Vapor.Graphic;
const Icon = Vapor.Icon;
const Page = Vapor.Page;
const code_snippet = @import("../../../../../../components/Custom.zig").code_snippet_single;

// Initialization
pub fn init() void {
    // wasi_js_code_editor.init(&Vapor.lib.allocator_global, @embedFile("chart.js"));
    // chart_code_editor.init(&Vapor.lib.allocator_global, @embedFile("chart_sample.zig"));
    // chart_use_code_editor.init(&Vapor.lib.allocator_global, @embedFile("chart_use_case_sample.zig"));
    // sample_inst_events.init(&Vapor.lib.allocator_global, @embedFile("inst_even_sample.zig"));
}

var copied: bool = false;
var copied_text: []const u8 = "";
fn copy(text: []const u8) void {
    Vapor.Clipboard.copy(text);
    copied = true;
    copied_text = text;
    Vapor.println("Hello", .{}).end();
    Vapor.cycle();
    Vapor.registerCtxTimeout(500, toggleIcon, .{}).end();
}

fn toggleIcon() void {
    copied = false;
    copied_text = "";
    Vapor.cycle();
}

fn code_snippet_single(text: []const u8) void {
    // Box().style(&.{
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
            },
            .padding = .all(8),
            .size = .square_percent(100),
            .direction = .column,
            .layout = .flex,
            .interactive = .{
                .hover = .{ .text_color = .palette(.tint), .border = .{ .color = .palette(.tint) } },
            },
            .position = .relative,
        }).children({
            Box().style(&.{
                .position = .{ .type = .absolute, .right = .px(8), .top = .px(8) },
                .size = .square_px(22),
                .transition = .{ .duration = 100 },
                .visual = .{
                    .border_radius = .all(4),
                    .background = .transparent,
                    .cursor = .pointer,
                },
                .layout = .center,
            }).children({
                if (copied and std.mem.eql(u8, text, copied_text)) {
                    Icon(.check).style(&.{
                        .visual = .{ .font_size = 18 },
                    }).end();
                } else {
                    Icon(.clipboard).style(&.{
                        .visual = .{ .font_size = 18 },
                    }).end();
                }
            }).end();
            HtmlText(text).style(&.{
                .visual = .{ .font_size = 16 },
                .font_family = "Azeret Mono, monospace",
            }).end();
        }).end();
}

pub fn Txt(text: []const u8) void {
    Text(text).style(&.{
        .visual = .font(18, null, null),
    }).end();
}

pub fn render() void {
    Box().style(&.{
        .child_gap = 24,
        .direction = .column,
        .size = .hw(.percent(100), .percent(100)),
    }).children({
        Text("Just let me build!!!").style(&.{
            .visual = .font(32, 700, .palette(.text_color)),
            .font_family = "IBM Plex Mono,monospace",
        }).end();
        Text("Linux, BSD, MacOS, *nix").font(18, 700, .palette(.text_color)).end();
        RedirectLink(.{ .url = "https://www.zvm.app/guides/install-zvm/", .aria_label = "zvm github page" })
            .textDecoration(.none)
            .children({
            Text("https://www.zvm.app/guides/install-zvm/").font(16, 500, .palette(.tint)).end();
        });
        code_snippet("curl https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash");

        Text("Install Zig & ZLS via ZVM").font(18, 700, .palette(.text_color)).end();

        code_snippet("zvm i --zls master");

        Text("Or install Zig, ZLS, ZVM, with Metal").font(18, 700, .palette(.text_color)).end();

        Text("Metal Install").font(18, 700, .palette(.text_color)).end();
        code_snippet("curl -sSL https://raw.githubusercontent.com/senet-toolbox/metal/main/install.sh | bash");
        code_snippet("metal create vapor myapp");
        code_snippet("cd my-app && metal vapor run");
    });
}
