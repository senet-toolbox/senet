const std = @import("std");
const Fabric = @import("fabric");
const Bridge = Fabric.Bridge;
const RootPage = @import("routes/Page.zig");
const Navbar = @import("components/Navbar.zig");
const DocsNavbar = @import("components/DocNavbar.zig");
const AcornNavbar = @import("components/AcornNavbar.zig");
// const ErrorPage = @import("routes/Error.zig");
const FabricDocs = @import("routes/docs/fabric/Page.zig");
// const ReverbDocs = @import("routes/docs/reverb/Page.zig");
const MetalDocs = @import("routes/docs/metal/Page.zig");
const Install = @import("routes/install/Page.zig");
const Huh = @import("routes/huh/Page.zig");
const Acorn = @import("routes/acorn/Acorn.zig");
// const About = @import("routes/about/Page.zig");
// const FabricConcepts = @import("routes/docs/fabric/concepts/:concept/Page.zig");
// const ReverbConcepts = @import("routes/docs/reverb/concepts/:concept/Page.zig");
// const TreehouseDocs = @import("routes/docs/treehouse/Page.zig");
// const TreehouseConcepts = @import("routes/docs/treehouse/concepts/:concept/Page.zig");
// const Playground = @import("routes/playground/Page.zig");
const Theme = @import("theme");
pub var theme: Theme = Theme{};
var fabric: Fabric.lib = undefined;

var allocator: std.mem.Allocator = undefined;
// export fn deinit() void {
//     fabric.deinit();
// }

fn initLayouts() !void {
    try Fabric.lib.registerLayout("/", layout, .{});
    try Fabric.lib.registerLayout("/docs", layoutDocs, .{ .reset = true });
    // try Fabric.lib.registerLayout("/acorn", layoutAcorn, .{ .reset = true });
}

pub fn layout(page: *const fn () void) void {
    Navbar.render();
    page();
    // Footer.render();
}

pub fn layoutDocs(page: *const fn () void) void {
    DocsNavbar.render();
    page();
}

fn layoutAcorn(page: *const fn () void) void {
    AcornNavbar.render();
    page();
}

export fn instantiate(window_width: f32, window_height: f32) void {
    fabric.init(.{
        .screen_width = window_width,
        .screen_height = window_height,
        .allocator = &allocator,
        .page_node_count = 512,
    });
    // Fabric.lib.clearPersitantStorage();
    initLayouts() catch |err| {
        std.log.err("Failed to register layout {any}", .{err});
    };
    Theme.getTheme();
    Navbar.init();
    // DocsNavbar.init();
    RootPage.init();
    // Acorn.init();
    // ErrorPage.init();
    // MetalDocs.init();
    // FabricDocs.init();
    // FabricConcepts.init();
    // ReverbDocs.init();
    // ReverbConcepts.init();
    // TreehouseDocs.init();
    // TreehouseConcepts.init();
    // Install.init();
    // Huh.init();
    // About.init();
    // Playground.init();
    // Fabric.lib.loopInterval("reconciler", Fabric.cycle, .{}, 60);
}

export fn renderUI(route: [*:0]u8) void {
    Fabric.renderCycle(route);
}

pub fn main() !void {
    allocator = std.heap.wasm_allocator;
    Fabric.setGlobalStyleVariables(
        &[_]Fabric.ThemeType{
            .{ .default = {} },
            .{ .name = "dark" },
        },
        Theme.ThemeColors,
        &[_]Theme.ThemeColors{ Theme.Light, Theme.Dark },
    );
}
