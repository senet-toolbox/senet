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
const Animation = @import("animation/Page.zig");
const Memory = @import("memory/Page.zig");
const NewToZig = @import("new-to-zig/Page.zig");
const Menu = @import("../../Menu.zig");
const Footer = @import("../../Footer.zig");
const root = @import("../../../../../main.zig");
const Sheet = @import("../../Sheet.zig").Sheet;
const Box = Static.Box;
const Center = Static.Center;
const Todo = @import("todo/Page.zig");
const ReactToVapor = @import("react-to-vapor/Page.zig");
const DontKnowZig = @import("dont-know-zig/Page.zig");
const ThemeAndIcons = @import("theme-and-icons/Page.zig");
const Opaque = @import("opaque/Page.zig");
const ApiCheatSheet = @import("api/Page.zig");
const Components = @import("components/Page.zig");
const CommonPatterns = @import("common-patterns/Page.zig");
const Gotchas = @import("gotchas/Page.zig");

var sheet: Sheet(void, Menu.render) = undefined;

const Routes = enum {
    basics,
    @"new-to-zig",
    vaporize,
    components,
    routing,
    layout,
    reactivity,
    animation,
    performance,
    kit,
    project,
    events,
    justletmebuild,
    styling,
    hooks,
    memory,
    tutorials,
    @"codex-engine",
    @"dont-know-zig",
    @"theme-and-icons",
    @"common-patterns",
    gotchas,
    todo,
    api,
};

// Initialization
pub fn init() void {
    Page(.{ .route = "/docs/vapor/concepts/:concept/" }, render, null);

    Basics.init();
    Animation.init();
    Vaporize.init();
    Routing.init();
    Layout.init();
    Reactivity.init();
    Kit.init();
    NewToZig.init();
    // Opaque.init();
    // // // Gotchas.init();
    // // // JSLibs.init();
    Events.init();
    // // // Bridge.init();
    Project.init();
    Just.init();
    Styling.init();
    Hooks.init();
    Performance.init();
    Tutorials.init();
    // // Tutorials.init();
    // // CsrVsSsr.init();
    CodexEngine.init();
    Memory.init();
    // Todo.init();
    // sheet.init(&Vapor.lib.allocator_global);
    ReactToVapor.init();
    DontKnowZig.init();
    ThemeAndIcons.init();
    ApiCheatSheet.init();
    Components.init();
    CommonPatterns.init();
    Gotchas.init();
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
                .animation => {
                    return Animation.render;
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
                .@"dont-know-zig" => {
                    return DontKnowZig.render;
                },
                // .@"opaque" => {
                //     return Opaque.render;
                // },
                .components => {
                    return Components.render;
                },
                .@"common-patterns" => {
                    return CommonPatterns.render;
                },
                .gotchas => {
                    return Gotchas.render;
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
                .performance => {
                    return Performance.render;
                },
                .tutorials => {
                    return Tutorials.render;
                },
                .@"theme-and-icons" => {
                    return ThemeAndIcons.render;
                },
                // .csr_vs_ssr => {
                //     return CsrVsSsr.render;
                // },
                .@"codex-engine" => {
                    return CodexEngine.render;
                },
                .todo => {
                    return Todo.render;
                },
                .api => {
                    return ApiCheatSheet.render;
                },
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
    }).children({
        Box().style(&.{
            .padding = .horizontal(12),
            .direction = .row,
            .size = .w(.percent(100)),
        }).children({
            Center().style(&.{
                .size = .w(.percent(100)),
                .padding = .{ .top = 60, .bottom = 120 },
                .direction = .column,
            }).children({
                Box().style(&.{
                    .size = .w(.mobile_desktop_percent(100, 50)),
                    // .width = .mobile_desktop_percent(100, 64),
                    // .size = .w(.percent(100)),
                    .child_gap = 32,
                    .direction = .column,
                    .padding = .{ .bottom = 80 },
                    .margin = .tb(32, 32),
                }).children({
                    render_page();
                    Footer.render();
                });
            });
        });
    });
}
