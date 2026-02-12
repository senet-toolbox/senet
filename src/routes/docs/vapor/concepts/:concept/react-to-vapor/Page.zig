const Vapor = @import("vapor");
const Compiler = @import("../../../../../../main.zig");
const Content = @import("../../../../../../components/Content.zig");
const Vaporize = @import("vaporize");
const Stack = Vapor.Stack;
const Text = Vapor.Text;
const Page = Vapor.Page;
const Box = Vapor.Box;

var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var page: []const u8 = "";
var content: Content.new("") = undefined;
var markdown_loaded: bool = false;

var generated_markdown: Compiler.vaporize.MarkDown(.{}) = .{};

pub fn init() void {
    Page(.{ .route = "react-to-vapor" }, render, null);

    Vapor.Kit.fetch("/documents/react_to_vapor_page.md", handlePage, .{ .method = .GET });
}

fn handlePage(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .Ok => |data| {
            content.content_text = data.body;
            page = data.body;
            markdown.compile(page) catch |err| {
                Vapor.printErr("Failed to compile markdown: {any}", .{err});
                return;
            };
            markdown_loaded = true;
        },
        .Err => |err| {
            Vapor.printErr("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.cycle();
}

fn component() void {
    markdown.render() catch unreachable;
}

// Render
pub fn render() void {
    if (!markdown_loaded) return;
    Box().style(&.{
        .size = .w( .percent(100)),
        .layout = .top_center,
        .padding = .tblr(64, 64, 12, 12),
        .visual = .{
            .layer = .grid(32, 1, .transparentizeHex(.palette(.grid_color), 0.9)),
            .border = .{
                .thickness = .lr(1),
                .color = .palette(.border_color_light),
            },
        },
        .position = .relative,
    }).children({
        Box().style(&.{
            .size = .w(.percent(80)),
            .child_gap = 16,
            .direction = .column,
            .layout = .{ .x = .start, .y = .start },
        }).children({
            Box().style(&.{
                .child_gap = 4,
                .direction = .column,
                .size = .hw(.percent(100), .percent(100)),
                .layout = .{},
            }).children({
                component();
            });
        });
    });
    // content.content(component);
}
