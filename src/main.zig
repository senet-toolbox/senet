const std = @import("std");
const fabric = @import("fabric");
const RootPage = @import("routes/Page.zig");
const ErrorPage = @import("routes/Error.zig");
const FabricDocs = @import("routes/docs/fabric/Page.zig");
const ReverbDocs = @import("routes/docs/reverb/Page.zig");
const MetalDocs = @import("routes/docs/metal/Page.zig");
const Download = @import("routes/download/Page.zig");
const Huh = @import("routes/huh/Page.zig");
const About = @import("routes/about/Page.zig");
const FabricConcepts = @import("routes/docs/fabric/concepts/:concept/Page.zig");
const ReverbConcepts = @import("routes/docs/reverb/concepts/:concept/Page.zig");
var fb: fabric.lib = undefined;
const Theme = @import("Theme.zig");
pub var theme: Theme = Theme{};

var allocator: std.mem.Allocator = undefined;
export fn deinit() void {
    fb.deinit();
}
export fn instantiate(window_width: f32, window_height: f32) void {
    fb.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = &allocator,
    });
    RootPage.init();
    ErrorPage.init();
    // MetalDocs.init();
    FabricDocs.init();
    FabricConcepts.init();
    // ReverbDocs.init();
    // ReverbConcepts.init();
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
