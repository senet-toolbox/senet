const std = @import("std");
const fabric = @import("fabric");
const RootPage = @import("routes/Page.zig");
var fb: fabric.lib = undefined;

var allocator: std.mem.Allocator = undefined;
export fn instantiate(window_width: i32, window_height: i32) void {
    // Init fabric.
    fb.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = &allocator,
    });
    // Init our Pages here.
    RootPage.init();
}

export fn renderUI(route_ptr: [*:0]u8) i32 {
    // Convert the 0 terminated pointer to a []const u8.
    const route = std.mem.span(route_ptr);
    // Pass the route to the render cycle.
    fabric.renderCycle(route);
    return 0;
}

// Entry point to run the wasm file.
pub fn main() !void {
    allocator = std.heap.wasm_allocator;
}
