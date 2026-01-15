const Vapor = @import("vapor");
const Content = @import("../../../../../../components/Content.zig");
const Compiler = @import("../../../../../../main.zig");

var content: Content.new("") = undefined;
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var markdown_loaded: bool = false;
var page: []const u8 = "";

pub fn init() void {
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/new-to-zig/new_to_zig_page.md", handlePage, .{ .method = .GET });
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

pub fn render() void {
    content.content(component);
}

fn component() void {
    if (!markdown_loaded) return;
    markdown.render() catch unreachable;
}
