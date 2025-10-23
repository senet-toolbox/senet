const std = @import("std");
const Fabric = @import("fabric");
const Bridge = Fabric.Bridge;
const RootPage = @import("routes/Page.zig");
const Navbar = @import("components/Navbar.zig");
const DocsNavbar = @import("components/DocNavbar.zig");
const AcornNavbar = @import("components/AcornNavbar.zig");
const FabricDocs = @import("routes/docs/fabric/Page.zig");
const FabricDocsConcepts = @import("routes/docs/fabric/concepts/:concept/Page.zig");
const MetalDocs = @import("routes/docs/metal/Page.zig");
const Huh = @import("routes/huh/Page.zig");
const Install = @import("routes/install/Page.zig");
const Theme = @import("theme");
const TestPage = @import("routes/TestPage.zig");
fn registerLayouts() !void {
    initLayouts();
    try Fabric.lib.registerLayout("/", layout, .{});
    try Fabric.lib.registerLayout("/docs", layoutDocs, .{ .reset = true });
}

fn initLayouts() void {
    Navbar.init();
    DocsNavbar.init();
}

pub fn layout(page: *const fn () void) void {
    Navbar.render();
    page();
}

pub fn layoutDocs(page: *const fn () void) void {
    DocsNavbar.render();
    page();
}

fn layoutAcorn(page: *const fn () void) void {
    AcornNavbar.render();
    page();
}

fn initPages() void {
    // TestPage.init();
    RootPage.init();
    FabricDocs.init();
    // FabricDocsConcepts.init();
    // MetalDocs.init();
    // Huh.init();
    // Install.init();
}

pub fn instantiate(window_width: f32, window_height: f32, allocator: std.mem.Allocator) void {
    // Initialize Fabric
    Fabric.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = allocator,
        .page_node_count = 10 * 1024,
    });

    // Global style variables
    Fabric.setGlobalStyleVariables(.{ // Adds 11kb
        .themes = &[_]Fabric.ThemeDefinition{
            Fabric.ThemeDefinition{ .name = "light", .theme = Theme.Light, .default = true },
            Fabric.ThemeDefinition{ .name = "dark", .theme = Theme.Dark },
        },
    });

    // Initialize your root component or app
    registerLayouts() catch |err| {
        Fabric.lib.printlnSrcErr("Failed to register layout {any}", .{err}, @src());
    };
    initPages();
}

export fn renderUI(route: [*:0]u8) void {
    Fabric.renderCycle(route);
}
