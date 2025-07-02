const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

// Initialization
var sample_events: CodeEditor = undefined;
var styling_sample_code_editor: CodeEditor = undefined;
pub fn init() void {
    styling_sample_code_editor.init(&Fabric.lib.allocator_global, @embedFile("styling_sample.zig"));
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
        Static.Text("Styling", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Custom.HtmlText(
            \\In typical web applications, the most common styling is CSS. Over the years CSS has been wrapped and abstracted, to the
            \\end of the Earth. There is SCSS, Tailwind, Sass, Less, Stylus, and more. However all of these abstraction take a thin layer approach
            \\ where the focus is less on the ui layout, and more on teh reduction of syntax, ie Tailwind converts margin-top to mt.
            \\This may reduce verbosity, and number of keys to press, but does not reduce the complexity required to center a div. 
        , .{
            .font_size = 18,
        });

        Custom.HtmlText(
            \\This is a website about how to <a href="https://thomasstep.com/blog/centering-a-div-with-tailwind-css">CENTER A DIV!!!!</a>
            \\Are you kidding me, what is this! <strong>class="flex flex-row min-h-screen justify-center items-center"</strong>. NONE of those words
            \\make any sense? Why can't we just do <strong>style="center"</strong>. I have found that in the few years of working in Web development.
            \\Styling has caused an enormity of abstraction layers, and more so pushed developers completely away from the Frontend.
        , .{
            .font_size = 18,
        });

        Custom.HtmlText(
            \\Fabric has taken a completely new approach. In the very early stages of Fabric's creation, an entire UI layout algorithmn
            \\was built from scratch. The aim of this was, to design an ergonmic, and usable simple styling system, for developers to work
            \\with. Today, Fabric does not use this UI algo, due to the benefits of the browser's DOM engine, but still uses the same styling api interface.
            \\To center any element in Fabric, just write <code>display = .Center</code>, or <code>child_alignment = .center</code>, Fabric 
            \\even exposes it own Center Component type, Center(Style) Component, which will Center any child elements within it.
            \\No more <strong>justify-content</strong>, or <strong>align-items</strong>, or <strong>text-align</strong>, ect... only <code>.x = .start</code>, or 
            \\<code>.y = .center</code>, these are also direction independent, adding <code>direction = .row</code>
            \\or <code>direction = .column</code>, will still layout elements in y and x axis, correctly, unlike justify-content, and align-items.
        , .{
            .font_size = 18,
        });

        Custom.HtmlText(
            \\A typical CSS styled Button requires the following styling <code>style="display: flex; justify-content: center, align-items: center,
            \\border-radius: 8px; border: 1px solid black; background: transparent;"</style></code>.
            \\While in Fabric we do the following, <code>Style{ .display = .Center, .border = { .radius = .all(8) } }</code>.
        , .{ .font_size = 18 });

        Static.Text("Rant Over", .{ .font_size = 24, .font_weight = 700 });
        Custom.HtmlText(
            \\Lets look at some examples of how styling works in Fabric. As you will see, Fabric has a number of defaults, and is easily overidable.
        , .{ .font_size = 18 });
        styling_sample_code_editor.render(0);
    });
}
