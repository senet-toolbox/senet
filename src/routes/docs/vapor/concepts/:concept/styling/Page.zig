const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const CodeEditor = @import("../../../../../../components/CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");
const Content = @import("../../../../../../components/Content.zig");
const HtmlText = Custom.Chain.HtmlText;
const Box = Static.Box;
const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const Center = Static.Center;
const List = Static.List;
const ListItem = Static.ListItem;
const Stack = Static.Stack;
const Vaporize = @import("vaporize");

// Initialization
var sample_events: CodeEditor = undefined;
var styling_sample_code_editor: CodeEditor = undefined;
var styling_page: Vaporize.Parser = undefined;
var mark_up: *Vaporize.Node = undefined;
var content: Content.new(@embedFile("styling_page.md")) = undefined;
pub fn init() void {
    content = .{};
    content.init();
    // content.init(@embedFile("styling_page.md"));
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("styling_page.md"));
    mark_up = parser.parse() catch unreachable;
    // styling_sample_code_editor.init(&Vapor.lib.allocator_global, @embedFile("styling_sample.zig"));
}

pub fn Txt(text: []const u8) void {
    Text(text).style(&.{ .visual = .font(18, null, null) });
}

pub fn component() void {
    Vaporize.traverse(mark_up, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color),
        .heading_color = .palette(.text_color),
    }, void, null) catch unreachable;
}

pub fn render() void {
    content.content(component);
    //
    // const text_style: *const Vapor.Style = &.{
    //     .visual = .{
    //         .font_size = 24,
    //         .font_weight = 700,
    //         .text_color = .red,
    //     },
    // };
    //
    // Box.style(text_style)({
    //     Text("Hello there!").style(&.{
    //         .visual = .{
    //             .font_size = 24,
    //             .font_weight = 700,
    //             .text_color = .blue,
    //         },
    //     });
    //     Text("...").style(&.{
    //         .visual = .{
    //             .font_size = 18,
    //             .font_weight = 700,
    //             .text_color = .black,
    //         },
    //     });
    //     Text("General Kenobi").style(text_style);
    // });

    // Box.layout(.center).spacing(16).padding(.all(20)).body()({
    //     Text("Hello there!")
    //         .font(24, 700, .blue)
    //         .close();
    //     Text("...")
    //         .font(18, 700, .black)
    //         .close();
    //     Text("General Kenobi")
    //         .font(24, 700, .red)
    //         .close();
    // });
}

const METHODS = [_][]const u8{
    "<p><i>visual</i> = .<code style=\"color: rgb(var(--tint))\">font</code>(size: u32, weight: ?u32, color: ?Color)</p>",
    "<p><i>visual</i> = .<code style=\"color: rgb(var(--tint))\">pill</code>(color: Color)</p>",
    "<p><i>visual</i> = .<code style=\"color: rgb(var(--tint))\">when</code>(condition: bool, visual_true: Visual, visual_false: Visual)</p>",
    "<p><i>visual</i> = .<code style=\"color: rgb(var(--tint))\">bg</code>(color: Color)</p>",
    "<p><i>interactive</i>  = .<code style=\"color: rgb(var(--tint))\">hover_scale</code>()</p>",
    "<p><i>style</i> = .<code style=\"color: rgb(var(--tint))\">extend</code>(base: *Style, extension: Style)</p>",
    "<p><i>style </i> = .<code style=\"color: rgb(var(--tint))\">merge</code>(base: *const Style, extension: Style)</p>",
    "<p><i>padding</i> = .<code style=\"color: rgb(var(--tint))\">tblr</code>(top: u32, bottom: u32, left: u32, right: u32)</p>",
    "<p><i>size</i> = .<code style=\"color: rgb(var(--tint))\">hw</code>(height: Sizing, width: Sizing)</p>",
    "<p><i>size</i> = .<code style=\"color: rgb(var(--tint))\">square_percent</code>(size: f32)</p>",
    "<p><i>width</i> = .<code style=\"color: rgb(var(--tint))\">mobile_desktop_percent</code>(mobile: f32, desktop: f32)</p>",
    "<p><i>background</i> = .<code style=\"color: rgb(var(--tint))\">grid</code>(size: f32, thickness: i32, color: Color)</p>",
    "<p><i>background</i> = .<code style=\"color: rgb(var(--tint))\">hex</code>(hex_str: []const u8)</p>",
    "<p><i>background</i> = .<code style=\"color: rgb(var(--tint))\">linear_gradient</code>(start: Color, end: Color)</p>",
    "<p><i>border</i> = .<code style=\"color: rgb(var(--tint))\">simple</code>(color: Color)</p>",
    "<p><i>border</i> = .<code style=\"color: rgb(var(--tint))\">round</code>(color: Color)</p>",
    "<p><i>border</i> = .<code style=\"color: rgb(var(--tint))\">solid</code>(color: Color, thickness: i32)</p>",
    "<p><i>border</i> = .<code style=\"color: rgb(var(--tint))\">dashed</code>(color: Color, thickness: i32)</p>",
    "<p>and much more...</p>",
};

const LABELS = [_][]const u8{
    "layout: .<code style=\"color: rgb(var(--tint))\">center</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">left_center</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">right_center</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">top_left</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">top_right</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">bottom_left</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">bottom_right</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">top_center</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">bottom_center</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">x_even_center</code>",
    "layout: .<code style=\"color: rgb(var(--tint))\">y_between</code>",
    "and much more...",
};

const DEFAULT_TEXT_STYLE = Vapor.Style{
    .visual = .font(18, null, null),
};
