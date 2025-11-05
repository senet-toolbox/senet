const std = @import("std");
const Vapor = @import("vapor");
const Bridge = Vapor.Bridge;
const RootPage = @import("routes/Page.zig");
const Navbar = @import("components/Navbar.zig");
const DocsNavbar = @import("components/DocNavbar.zig");
const AcornNavbar = @import("components/AcornNavbar.zig");
const VaporDocs = @import("routes/docs/vapor/Page.zig");
const VaporDocsConcepts = @import("routes/docs/vapor/concepts/:concept/Page.zig");
const MetalDocs = @import("routes/docs/metal/Page.zig");
const Huh = @import("routes/huh/Page.zig");
const Install = @import("routes/install/Page.zig");
const Theme = @import("theme");
const TestPage = @import("routes/TestPage.zig");
const Content = @import("components/Content.zig");
fn registerLayouts() !void {
    initLayouts();
    try Vapor.lib.registerLayout("/", layout, .{});
    try Vapor.lib.registerLayout("/docs", layoutDocs, .{ .reset = true });
}

fn initHooks() void {
    // _ = Vapor.registerHook("/docs", hook, .before);
    // _ = Vapor.registerHook("/docs", hookAfter, .after);
}

fn hook(ctx: Vapor.lib.HookContext) void {
    Vapor.print("Hook called {s}", .{ctx.to_path});
    // DocsNavbar.reinitObserver();
}

fn hookAfter(ctx: Vapor.lib.HookContext) void {
    // Content.initBoxes();
    Vapor.print("After Hook called {s}", .{ctx.to_path});
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
    Vapor.Page(.{ .route = "/" }, RootPage.render, null);
    VaporDocs.init();
    VaporDocsConcepts.init();
    MetalDocs.init();
    Huh.init();
    Install.init();
}

export fn immediateMode() void {
    Vapor.cycle();
}

pub fn instantiate(window_width: f32, window_height: f32, allocator: std.mem.Allocator) void {
    // InitializeVapor
    Vapor.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = allocator,
        .page_node_count = 5 * 1024,
    });
    // initHooks();

    // Global style variables
    Vapor.setGlobalStyleVariables(.{ // Adds 11kb
        .themes = &[_]Vapor.ThemeDefinition{
            Vapor.ThemeDefinition{ .name = "light", .theme = Theme.Light, .default = true },
            Vapor.ThemeDefinition{ .name = "dark", .theme = Theme.Dark },
        },
    });

    // Initialize your root component or app
    registerLayouts() catch |err| {
        Vapor.lib.printlnSrcErr("Failed to register layout {any}", .{err}, @src());
    };
    initPages();

    // Vapor.lib.loopInterval("immediatemode", immediateMode, .{{}}, 60);
}

export fn renderUI(route: [*:0]u8) void {
    Vapor.renderCycle(route);
}
