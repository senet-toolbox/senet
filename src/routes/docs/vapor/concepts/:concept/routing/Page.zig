const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
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
const Graphic = Static.Graphic;
const Icon = Pure.Icon;
const Vaporize = @import("vaporize");

const Page = Vapor.Page;
const CodeEditor = @import("../../../../../../components/CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");
const HtmlText = Custom.Chain.HtmlText;

const Content = @import("../../../../../../components/Content.zig");
var content: Content.new(@embedFile("routing_page.md")) = .{};

var page_sample: CodeEditor = undefined;
var dyanmic_code_editor: CodeEditor = undefined;
var app_example: CodeEditor = undefined;
const items: []const []const u8 = &.{
    "Compiles to WASM and sent down the wire, resulting in client side rendering.",
    "Browser parse WASM 10x-20x faster than JS",
    "WASM is 1.5x-4x faster during runtime",
    "Embed your favorite JS Libraries",
    "Construct or modify GLUE the WASM Bridge",
    "Vapor only allocates at start up, no memory is allocated during runtime.",
    "Only Zig no html, js, ts, tsx, rsx, jsx",
};
var routing_page: *Vaporize.Node = undefined;
// Initialization
pub fn init() void {
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("routing_page.md"));
    routing_page = parser.parse() catch unreachable;
    // code_editor.init(&Vapor.lib.allocator_global, @embedFile("main_sample.zig"));
    // code_editor_component.init(&Vapor.lib.allocator_global, @embedFile("Component.zig"));
    // code_editor_lifecycle.init(&Vapor.lib.allocator_global, @embedFile("LifeCycle_sample.zig"));
    // code_editor_global.init(&Vapor.lib.allocator_global, @embedFile("global_sample.zig"));
    // code_editor_instance.init(&Vapor.lib.allocator_global, @embedFile("instance_sample.zig"));
    // code_editor_comptime.init(&Vapor.lib.allocator_global, @embedFile("comptime_sample.zig"));
    // page_sample.init(&Vapor.lib.allocator_global, @embedFile("page_sample.zig"));
    // app_example.init(&Vapor.lib.allocator_global, @embedFile("app_example.zig"));
    // dyanmic_code_editor.init(&Vapor.lib.allocator_global, @embedFile("dynamic_sample.zig"));
}

// Deinitialization
pub fn deinit() void {}

const styles = struct {
    pub const heading = &Vapor.Style{
        .font_family = "IBM Plex Sans",
        .visual = .font(24, 700, .palette(.text_color)),
    };
    pub const mini_heading = &Vapor.Style{
        .font_family = "IBM Plex Sans",
        .visual = .font(20, 700, .palette(.text_color)),
        .margin = .t(12),
    };
    pub const body_text = &Vapor.Style{
        .visual = .font(18, null, null),
    };
};

const BoxCode = Box.margin(.tb(8, 24)).size(.hw(.fit, .percent(100)));

var copied: bool = false;
fn copy() void {
    Vapor.Clipboard.copy(@embedFile("routing_page.md"));
    copied = true;
    Vapor.cycle();
    Vapor.registerCtxTimeout(500, toggleIcon, .{});
}

fn toggleIcon() void {
    copied = false;
    Vapor.cycle();
}

fn component() void {
    Vaporize.traverse(routing_page, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color),
        .heading_color = .palette(.text_color),
    }, void, null) catch unreachable;
}

// Render
pub fn render() void {
    content.content(component);
    // Page Header
    // Box.style(&.{
    //     .child_gap = 4,
    //     .direction = .column,
    //     .margin = .{ .bottom = 32 },
    //     .size = .w(.percent(100)),
    // })({
    //     Button(.{ .on_press = copy }).style(&.{
    //         .visual = .{ .background = .transparent, .cursor = .pointer },
    //         .size = .w(.percent(100)),
    //         .child_gap = 12,
    //         .padding = .tb(8, 8),
    //         .layout = .right_center,
    //     })({
    //         if (copied) {
    //             Icon(.check).style(&.{
    //                 .visual = .{ .font_size = 16 },
    //             });
    //         } else {
    //             Icon(.clipboard).style(&.{
    //                 .visual = .{ .font_size = 16 },
    //             });
    //         }
    //     });
    //     Custom.Virtualize(&.{
    //         .size = .hw(.percent(100), .percent(100)),
    //         .child_gap = 32,
    //         .layout = .{},
    //         .direction = .column,
    //     })({
    //         Box.style(&.{
    //             .child_gap = 4,
    //             .direction = .column,
    //             .size = .hw(.percent(100), .percent(100)),
    //             .layout = .{},
    //         })({
    //             Text("Getting Started").style(&.{
    //                 .visual = .font(16, 600, null),
    //                 .font_family = "IBM Plex Sans",
    //             });
    //             Vaporize.traverse(routing_page, .{
    //                 .code_color = .palette(.tint),
    //                 .text_color = .palette(.text_color),
    //                 .heading_color = .palette(.text_color),
    //             }, *anyopaque, &[_]Vaporize.TaggedFunction(*anyopaque){
    //                 // Vaporize.TaggedFunction(*anyopaque){ .tag = "global_sample.zig", .function = global.render, .args = undefined },
    //                 // Vaporize.TaggedFunction(*anyopaque){ .tag = "instance_sample.zig", .function = Counter.render, .args = @ptrCast(&counter) },
    //                 // Vaporize.TaggedFunction(*anyopaque){ .tag = "instance_sample2.zig", .function = Counter.render, .args = @ptrCast(&counter2) },
    //             }) catch unreachable;
    //         });
    //     });
    // });

    // Box.style(&.{
    //     .child_gap = 24,
    //     .direction = .column,
    //     .margin = .{ .bottom = 32 },
    //     .size = .w(.percent(100)),
    // })({
    //     Text("Routing").style(&.{
    //         .font_family = "IBM Plex Sans",
    //         .visual = .font(32, 700, .palette(.text_color)),
    //     });
    //     HtmlText(
    //         \\Routing in Vapor works off of the directory structure of your project. You have access to <code style="color: rgb(var(--tint))">:slug</code> and <code style="color: rgb(var(--tint))">static</code> routes.
    //     ).style(styles.body_text);
    //
    //     Graphic(.{ .src = "/src/assets/routes.svg" }).size(.square_percent(60)).close();
    //
    //     Text("Using Page()").style(styles.mini_heading);
    //     HtmlText(
    //         \\Every Route is declared in the <code style="color: rgb(var(--tint))">init()</code>
    //         \\function of the <code style="color: rgb(var(--tint))">.zig</code> file.
    //         \\By using the <code style="color: rgb(var(--tint))">Page</code> function, you can easily define your routes.
    //     ).style(styles.body_text);
    //
    //     BoxCode.body()({
    //         page_sample.render(0);
    //     });
    //     HtmlText(
    //         \\The <code style="color: rgb(var(--tint))">Page</code> function, adds the render function to the routes tree.
    //         \\The <code style="color: rgb(var(--tint))">render()</code> function is called during rendering, and rerendering.
    //     ).style(styles.body_text);
    //
    //     HtmlText(
    //         \\<code style="color: rgb(var(--danger))">The Page(...) should only be called once per route.</code>
    //     ).style(&.{ .visual = .font(20, 500, .palette(.danger)), .layout = .center });
    //
    //     HtmlText(
    //         \\Typically, in Vapor applications, we initialize all our routes in the App.zig file, located in the root of the project.
    //     ).style(styles.body_text);
    //
    //     HtmlText(
    //         \\<code style="color: rgb(var(--tint))">Page()</code> is the entry point for your application.
    //         \\It takes 3 arguments,
    //     ).style(styles.body_text);
    //
    //     List.direction(.column).childGap(8).body()({
    //         ListItem.body()({
    //             HtmlText("<code style=\"color: rgb(var(--tint))\">src: SourceLocation</code>").style(styles.body_text);
    //         });
    //         ListItem.body()({
    //             HtmlText("<code style=\"color: rgb(var(--tint))\">render_fn: RenderFn</code>").style(styles.body_text);
    //         });
    //         ListItem.body()({
    //             HtmlText("<code style=\"color: rgb(var(--tint))\">deinit_fn: DeinitFn</code>").style(styles.body_text);
    //         });
    //     });
    //     HtmlText(
    //         \\<code style="color: rgb(var(--tint))">SourceLocation</code> is a struct that contains the path to the file, and the line number.
    //         \\<code style="color: rgb(var(--tint))">@src()</code> is a builtin function that returns the current source location.
    //     ).style(styles.body_text);
    //
    //     BoxCode.body()({
    //         app_example.render(0);
    //     });
    // });
}
