const Vapor = @import("vapor");
const Compiler = @import("../../../../../../main.zig");
const Content = @import("../../../../../../components/Content.zig");
const Vaporize = @import("vaporize");
const Stack = Vapor.Stack;
const Text = Vapor.Text;

var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var page: []const u8 = "";
var content: Content.new("") = undefined;
var markdown_loaded: bool = false;

var generated_markdown: Compiler.vaporize.MarkDown(.{}) = .{};

pub fn init() void {
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/animation/animation_page.md", handlePage, .{ .method = .GET });
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

fn component() void {
    markdown.render() catch unreachable;
}

// Render
pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}
