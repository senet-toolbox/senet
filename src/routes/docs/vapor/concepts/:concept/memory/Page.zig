const Vapor = @import("vapor");
const Compiler = @import("../../../../../../main.zig");
const Content = @import("../../../../../../components/Content.zig");

var content: Content.new("") = undefined; // TODO: Fix this
var markdown: Compiler.vaporize.MarkDown(.{}) = .{};
var markdown_loaded: bool = false;
var page: []const u8 = "";

pub fn init() void {
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/memory/memory_page.md", handlePage, .{ .method = .GET });
    content.init();
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
    Vapor.println("Loaded markdown", .{});
    markdown.render() catch unreachable;
}

pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}

