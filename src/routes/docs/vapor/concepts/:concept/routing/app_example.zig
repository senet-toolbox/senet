const std = @import("std");
const Fabric = @import("fabric");
const HomePage = @import("routes/Page.zig");
const FabricHome = @import("routes/docs/fabric/Page.zig");
const FabricDocsConcepts = @import("routes/docs/fabric/concepts/:concept/Page.zig");
const MetalDocs = @import("routes/docs/metal/Page.zig");
const Huh = @import("routes/huh/Page.zig");
const Install = @import("routes/install/Page.zig");

fn initPages() void {
    HomePage.init();
    FabricHome.init();
    FabricDocsConcepts.init();
    MetalDocs.init();
    Huh.init();
    Install.init();
}

pub fn instantiate(window_width: f32, window_height: f32, allocator: std.mem.Allocator) void {
    // Initialize Fabric
    Fabric.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = allocator,
        .page_node_count = 1024,
    });

    // Initialize your routes
    initPages();
}

export fn renderUI(route: [*:0]u8) void {
    Fabric.renderCycle(route);
}
