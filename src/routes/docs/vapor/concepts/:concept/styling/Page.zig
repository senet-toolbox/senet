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
const Compiler = @import("../../../../../../main.zig");

// Initialization
var content: Content.new("") = undefined;
var markdown: Compiler.vaporize.MarkDown(.{
    .{ .tag = "styling_samples", .function = samples },
}) = .{};
var page: []const u8 = "";
var markdown_loaded: bool = false;
pub fn init() void {
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/styling/styling_page.md", handlePage, .{ .method = .GET });
}

fn handlePage(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .ok => |data| {
            content.content_text = data.body;
            page = data.body;
            markdown.compile(page) catch |err| {
                Vapor.printErr("Failed to compile markdown: {any}", .{err});
                return;
            };
            markdown_loaded = true;
        },
        .err => |err| {
            Vapor.printErr("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.cycle();
}

pub fn Txt(text: []const u8) void {
    Text(text).style(&.{ .visual = .font(18, null, null) });
}

pub fn component() void {
    markdown.render() catch unreachable;
}

pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}

const common_style = Style{
    .layout = .top_right,
    .size = .{
        .height = .px(120),
    },
    .visual = .{
        .border = .round(.vapor_blue, .all(4)),
    },
    .padding = .all(8),
};

pub const pill_button_base = Style{
    .layout = .center,
    .size = .hw(.px(45), .px(160)),
    .visual = .pill(.hex("#000000")),
    .transition = .{ .duration = 100 },
    .interactive = .hover_scale(),
    .child_gap = 8,
};

fn mergedStyle() Style {
    var base = pill_button_base;
    return base.merge(Style{
        .visual = .{ .border = .simple(.hex("#E1E1E1")) },
    });
}

fn clicked() void {
    Vapor.alert("You clicked me!", .{});
}

fn samples() void {
    Stack().height(.grow).spacing(16).direction(.column).children({
        Box()
            .layer(.dot(0.5, 20, .white))
            .background(.vapor_blue)
            .width(.percent(100))
            .height(.auto)
            .layout(.center)
            .children({
            Text("I like Dots!")
                .font(48, 700, .white).fontFamily("Montserrat").end();
        });

        Box().style(&common_style)({
            Text("Top right Text").fontSize(14).end();
        });

        // Here we use the baseStyle, now we can override the default style
        Box().baseStyle(&common_style).layout(.top_left).children({
            Text("Top left Text").fontSize(14).end();
        });

        Button(clicked).style(&pill_button_base)({
            Text("Click Me").fontSize(18).end();
        });

        // Here we merge the pill style,
        Button(clicked).style(&mergedStyle())({
            Text("Click Me").fontSize(18).end();
        });
    });
}
