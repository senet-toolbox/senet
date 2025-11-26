const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Page = Vapor.Page;
const Basics = @import("basics/Page.zig");
const Introduction = @import("introduction/Page.zig");
const Routing = @import("routing/Page.zig");
const Tutorials = @import("tutorials/Page.zig");
const Reactivity = @import("reactivity/Page.zig");
const Kit = @import("kit/Page.zig");
const Events = @import("events/Page.zig");
const Project = @import("project/Page.zig");
const JSLibs = @import("jslibs/Page.zig");
const Bridge = @import("bridge/Page.zig");
const Just = @import("justletmebuild/Page.zig");
const Styling = @import("styling/Page.zig");
const Layout = @import("layouts/Page.zig");
const Hooks = @import("hooks/Page.zig");
const Vaporize = @import("vaporize/Page.zig");
const CsrVsSsr = @import("csr_vs_ssr/Page.zig");
const CodexEngine = @import("codex-engine/Page.zig");
const Performance = @import("performance/Page.zig");
const Memory = @import("memory/Page.zig");
const NewToZig = @import("new-to-zig/Page.zig");
const Menu = @import("../../Menu.zig");
const Footer = @import("../../Footer.zig");
const root = @import("../../../../../main.zig");
const Sheet = @import("../../Sheet.zig").Sheet;
const Box = Static.Box;
const Center = Static.Center;

var sheet: Sheet(void, Menu.render) = undefined;

const Routes = enum {
    basics,
    @"new-to-zig",
    vaporize,
    routing,
    reactivity,
    // // performance,
    // // // authentication,
    // // // introduction,
    kit,
    project,
    events,
    // // // jslibs,
    // // // bridge,
    justletmebuild,
    styling,
    hooks,
    memory,
    // // // keystone,
    // // tutorials,
    layout,
    // // csr_vs_ssr,
    // // @"ui-inversion",
    @"codex-engine",
};

// Initialization
pub fn init() void {
    Basics.init();
    Vaporize.init();
    Routing.init();
    Reactivity.init();
    Kit.init();
    NewToZig.init();
    // // Gotchas.init();
    // // JSLibs.init();
    Events.init();
    // // Bridge.init();
    Project.init();
    Just.init();
    Styling.init();
    Hooks.init();
    // Performance.init();
    // Tutorials.init();
    Layout.init();
    // CsrVsSsr.init();
    CodexEngine.init();
    Memory.init();
    // sheet.init(&Vapor.lib.allocator_global);
    Page(.{ .route = "/docs/vapor/concepts/:concept/" }, render, null);
}

fn getRender(path: []const u8) ?*const fn () void {
    var segments = std.mem.tokenizeScalar(u8, path, '/');
    while (segments.next()) |current| {
        if (segments.peek() == null) {
            const route: Routes = std.meta.stringToEnum(Routes, current) orelse return null;
            switch (route) {
                .basics => {
                    return Basics.render;
                },
                .vaporize => {
                    return Vaporize.render;
                },
                .routing => {
                    return Routing.render;
                },
                .reactivity => {
                    return Reactivity.render;
                },
                .layout => {
                    return Layout.render;
                },
                .@"new-to-zig" => {
                    return NewToZig.render;
                },
                // // .introduction => {
                // //     return Introduction.render;
                // // },
                .project => {
                    return Project.render;
                },
                .kit => {
                    return Kit.render;
                },
                .styling => {
                    return Styling.render;
                },
                .memory => {
                    return Memory.render;
                },
                .events => {
                    return Events.render;
                },
                // // .jslibs => {
                // //     return JSLibs.render;
                // // },
                // // .bridge => {
                // //     return Bridge.render;
                // // },
                .justletmebuild => {
                    return Just.render;
                },
                .hooks => {
                    return Hooks.render;
                },
                // .performance => {
                //     return Performance.render;
                // },
                // .tutorials => {
                //     return Tutorials.render;
                // },
                // .csr_vs_ssr => {
                //     return CsrVsSsr.render;
                // },
                .@"codex-engine" => {
                    return CodexEngine.render;
                },
                // else => return null,
            }
        }
    }
    return null;
}

// Render
pub fn render() void {
    const path = Vapor.Kit.getWindowPath() orelse "/";
    const render_page = getRender(path) orelse return;
    Box().style(&.{
        .layout = .x_between,
        .direction = .column,
        .size = .square_percent(100),
    })({
        Box().style(&.{
            .padding = .horizontal(12),
            .direction = .row,
            .size = .w(.percent(100)),
        })({
            Center().style(&.{
                .size = .w(.percent(100)),
                .padding = .{ .top = 60, .bottom = 120 },
                .direction = .column,
            })({
                Box().style(&.{
                    .size = .w(.mobile_desktop_percent(100, 50)),
                    // .width = .mobile_desktop_percent(100, 64),
                    // .size = .w(.percent(100)),
                    .child_gap = 32,
                    .direction = .column,
                    .padding = .{ .bottom = 80 },
                    .margin = .tb(32, 32),
                })({
                    render_page();
                    Footer.render();
                });
            });
        });
    });
}
