const std = @import("std");
const Fabric = @import("fabric");
const Page = Fabric.Page;
const Basics = @import("basics/Page.zig");
const Introduction = @import("introduction/Page.zig");
const Routing = @import("routing/Page.zig");

const Routes = enum {
    introduction,
    basics,
    routing,
};

// Initialization
pub fn init() void {
    Basics.init();
    Introduction.init();
    Routing.init();
    Page(@src(), render, null, .{});
}

fn getPage(path: []const u8) ?*const fn () void {
    var segments = std.mem.tokenizeScalar(u8, path, '/');
    while (segments.next()) |current| {
        if (segments.peek() == null) {
            const route: Routes = std.meta.stringToEnum(Routes, current) orelse return null;
            switch (route) {
                .basics => {
                    return Basics.render;
                },
                .routing => {
                    return Routing.render;
                },
                .introduction => {
                    return Introduction.render;
                },
                else => return null,
            }
        }
    }
    return null;
}

// Render
pub fn render() void {
    // We grab the current window path
    const path = Fabric.Kit.getWindowPath();
    // load the correct render function based on the path
    const render_page = getPage(path) orelse return;
    render_page();
}
