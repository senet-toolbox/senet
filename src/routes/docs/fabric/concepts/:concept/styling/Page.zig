const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../../../../../../components/CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");
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

// Initialization
var sample_events: CodeEditor = undefined;
var styling_sample_code_editor: CodeEditor = undefined;
pub fn init() void {
    styling_sample_code_editor.init(&Fabric.lib.allocator_global, @embedFile("styling_sample.zig"));
}

pub fn Txt(text: []const u8) void {
    Text(text).style(&.{ .visual = .font(18, null, null) });
}

pub fn render() void {
    Box.style(&.{
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .size = .w(.percent(100)),
    })({
        Text("Styling").style(&.{
            .font_family = "IBM Plex Sans",
            .visual = .font(32, 700, .palette(.text_color)),
        });
        Text("**Quick little rant**").style(&.{
            .visual = .font(20, 700, .palette(.text_color)),
            .font_family = "IBM Plex Sans",
        });
        HtmlText(
            \\In typical web applications, the most common styling is CSS. Over the years CSS has been wrapped and abstracted, to the
            \\end of the Earth. There is <strong>SCSS, Tailwind, Sass, Less, Stylus, and more</strong>. However, all of these abstraction take a thin layer approach
            \\ where the focus is less on the UI layout, and more on the reduction of syntax, ie Tailwind converts <i>margin-top to mt</i>.
            \\This may reduce verbosity, and number of keys to press, but does not reduce the complexity required to center a div. 
        ).style(&.{ .visual = .font(18, null, null) });

        HtmlText(
            \\This is a website about how to <a href="https://thomasstep.com/blog/centering-a-div-with-tailwind-css">CENTER A DIV</a>.
        ).style(&.{ .visual = .font(18, null, null), .layout = .center });

        HtmlText(
            \\Normal CSS: <i style="color: rgb(var(--tint))"><code>style="display: flex; justify-content: center; align-items: center"</code></i>
        ).style(&.{ .visual = .font(18, null, null), .layout = .center });

        HtmlText(
            \\Tailwind CSS: <i style="color: rgb(var(--tint))"><code>class="flex justify-center items-center"</code></i>
        ).style(&.{ .visual = .font(18, null, null), .layout = .center });

        HtmlText(
            \\The question is then, why can't we just do <code>style="center"</code>? I have found that in the few years of working in web development,
            \\<i>"Styling"</i> has caused an enormity of abstraction layers, and more so pushed developers completely away from the frontend.
        ).style(&.{ .visual = .font(18, null, null) });

        Text("**End of little rant**").style(&.{
            .visual = .font(20, 700, .palette(.text_color)),
            .font_family = "IBM Plex Sans",
        });

        Text("const Style = struct { ... }").style(&.{
            .font_family = "IBM Plex Sans",
            .visual = .font(24, 700, .palette(.text_color)),
        });

        HtmlText(
            \\Fabric has taken a completely new approach. In the very early stages of Fabric's creation, an entire UI layout algorithmn
            \\was built from scratch. The aim of this was, to design an ergonmic, and usable simple styling system, for developers to work
            \\with. Today, Fabric does not use this UI algo, due to the benefits of the browser's DOM engine, but still uses the same styling api interface.
        ).style(&.{ .visual = .font(18, null, null) });

        HtmlText(
            \\To center any element in Fabric...
        ).style(&.{ .visual = .font(20, 600, null), .font_family = "IBM Plex Sans" });

        HtmlText(
            \\<code style="color: rgb(var(--tint))">.layout = .center</code>
        ).style(&.{ .visual = .font(18, null, null), .layout = .center });

        HtmlText(
            \\Fabric, even exposes it own Center Component type, <code style="color: rgb(var(--tint))">Center</code> Component, which will Center any child elements within it.
            \\No more <code>justify-content</code>, or <code>align-items</code>, or <code>text-align</code>. Now instead <code>.x = .start</code>, or 
            \\<code>.y = .center</code> or <code>.layout = .top_left</code>.
        ).style(&.{ .visual = .font(18, null, null) });

        HtmlText(
            \\These are also direction independent, adding <code>direction = .row</code>
            \\or <code>direction = .column</code>, will still layout elements in y and x axis, correctly, unlike justify-content, and align-items.
        ).style(&.{ .visual = .font(18, null, null) });

        HtmlText(
            \\Layout:
        ).style(&.{ .visual = .font(20, 600, null), .font_family = "IBM Plex Sans" });

        List.style(&.{
            .layout = .flex,
            .child_gap = 8,
            .direction = .column,
        })({
            for (LABELS) |label| {
                ListItem.style(&.{})({
                    HtmlText(label).style(&DEFAULT_TEXT_STYLE);
                });
            }
        });

        HtmlText(
            \\Taking it even further
        ).style(&.{ .visual = .font(20, 600, null), .font_family = "IBM Plex Sans" });

        HtmlText(
            \\A typical CSS styled Button requires the following styling <div><code style="color: rgb(var(--tint))">style="display: flex; justify-content: center, align-items: center,
            \\border-radius: 8px; border: 1px solid rgb(var(--tint)); background: transparent;"</style></code></div>
        ).style(&.{ .visual = .font(18, null, null) });

        Stack.style(&.{})({
            HtmlText(
                \\While in Fabric we can do the following, <div><code style="color: rgb(var(--tint))">Style{ .layout = .center, .visual = .{ .border = .round(.palette(.tint)) } }</code><div>
            ).style(&.{ .visual = .font(18, null, null) });
            HtmlText(
                \\Or...<div><code style="color: rgb(var(--tint))">Style{ .layout = .center, .visual = .border_round(palette(.tint)) }</code><div>
            ).style(&.{ .visual = .font(18, null, null) });
        });

        HtmlText(
            \\Structs are insanely powerful!
        ).style(&.{ .visual = .font(20, 600, null), .font_family = "IBM Plex Sans" });

        HtmlText(
            \\As you may have noticed, <code>Style</code> is a struct, and has fields, which means it also has methods. 
            \\When we create a new fabric project, we get the following default methods:
        ).style(&.{ .visual = .font(18, null, null) });

        List.style(&.{
            .layout = .flex,
            .child_gap = 8,
            .direction = .column,
        })({
            for (METHODS) |label| {
                ListItem.style(&.{})({
                    HtmlText(label).style(&DEFAULT_TEXT_STYLE);
                });
            }
        });

        styling_sample_code_editor.render(0);
    });
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

const DEFAULT_TEXT_STYLE = Fabric.Style{
    .visual = .font(18, null, null),
};
