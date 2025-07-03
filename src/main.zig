const std = @import("std");
const fabric = @import("fabric");
const RootPage = @import("routes/Page.zig");
const FabricDocs = @import("routes/docs/fabric/Page.zig");
const Docs = @import("routes/docs/Page.zig");
const Download = @import("routes/download/Page.zig");
const Huh = @import("routes/huh/Page.zig");
const About = @import("routes/about/Page.zig");
const Concepts = @import("routes/docs/fabric/concepts/:concept/Page.zig");
var fb: fabric.lib = undefined;
const Theme = @import("Theme.zig");
pub var theme: Theme = Theme{};

var allocator: std.mem.Allocator = undefined;
export fn deinit() void {
    fb.deinit();
}
export fn instantiate(window_width: i32, window_height: i32) void {
    fb.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = &allocator,
    });
    RootPage.init();
    // Docs.init();
    FabricDocs.init();
    Concepts.init();
    // Download.init();
    // Huh.init();
    // About.init();
}

export fn renderUI(route_ptr: [*:0]u8) i32 {
    const route = std.mem.span(route_ptr);
    fabric.renderCycle(route);
    return 0;
}

pub fn main() !void {
    allocator = std.heap.wasm_allocator;
}
