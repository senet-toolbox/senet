const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const Basics = @import("basics/Page.zig");
const Introduction = @import("introduction/Page.zig");
const Gotchas = @import("gotchas/Page.zig");
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
const KeyStone = @import("keystone/Page.zig");
const Menu = @import("../../Menu.zig");
const Footer = @import("../../Footer.zig");
const root = @import("../../../../../main.zig");
const Sheet = @import("../../Sheet.zig").Sheet;

var sheet: Sheet(void, Menu.render) = undefined;

const Routes = enum {
    basics,
    routing,
    reactivity,
    authentication,
    introduction,
    kit,
    project,
    gotchas,
    events,
    jslibs,
    bridge,
    justletmebuild,
    styling,
    hooks,
    keystone,
    tutorials,
    layout,
};

// Initialization
pub fn init() void {
    Basics.init();
    Introduction.init();
    Routing.init();
    Reactivity.init();
    Kit.init();
    Gotchas.init();
    JSLibs.init();
    Events.init();
    Bridge.init();
    Project.init();
    Just.init();
    Styling.init();
    Hooks.init();
    KeyStone.init();
    Tutorials.init();
    Layout.init();
    sheet.init(&Fabric.lib.allocator_global);
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
                .reactivity => {
                    return Reactivity.render;
                },
                .layout => {
                    return Layout.render;
                },
                .introduction => {
                    return Introduction.render;
                },
                .project => {
                    return Project.render;
                },
                .kit => {
                    return Kit.render;
                },
                .styling => {
                    return Styling.render;
                },
                .gotchas => {
                    return Gotchas.render;
                },
                .events => {
                    return Events.render;
                },
                .jslibs => {
                    return JSLibs.render;
                },
                .bridge => {
                    return Bridge.render;
                },
                .justletmebuild => {
                    return Just.render;
                },
                .hooks => {
                    return Hooks.render;
                },
                .keystone => {
                    return KeyStone.render;
                },
                .tutorials => {
                    return Tutorials.render;
                },
                else => return null,
            }
        }
    }
    return null;
}

var menu: bool = false;
fn openMenu() void {
    sheet.toggle();
    // Fabric.cycle();
}

// Render
pub fn render() void {
    const path = Fabric.Kit.getWindowPath();
    const render_page = getPage(path) orelse return;
    Static.FlexBox(.{
        .child_alignment = .{ .x = .between, .y = .start },
        .direction = .column,
        .width = .percent(100),
        .height = .percent(100),
    })({
        Static.FlexBox(.{
            .padding = .horizontal(12),
            .direction = .row,
            .width = .percent(100),
            // .height = .percent(90),
        })({
            Static.Center(.{
                .width = .percent(100),
                .padding = .{ .top = 60, .bottom = 120 },
                .direction = .column,
            })({
                Static.FlexBox(.{
                    .width = .clamp_percent(64, 786, 100),
                    .child_gap = 32,
                    .direction = .column,
                    .padding = .{ .bottom = 80 },
                })({
                    render_page();
                    Footer.render();
                });
            });
            if (!Fabric.isMobile()) {
                // Menu.render({});
            } else {
                Fabric.Layout(.{
                    .file = "/routes/docs/fabric/concepts/:concept",
                    .module = "",
                    .column = 0,
                    .fn_name = "",
                    .line = 0,
                }, .{})({
                    Static.FlexBox(.{
                        .child_alignment = .{ .x = .between, .y = .center },
                        .child_gap = 8,
                        .padding = .horizontal(12),
                        .height = .px(50),
                        .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
                        .width = .percent(100),
                        .z_index = 999,
                        .background = root.theme.getAttribute("background"),
                    })({
                        Static.FlexBox(.{ .child_alignment = .x_between_center, .child_gap = 12, .width = .percent(100) })({
                            Static.Link(.{ .url = "/", .aria_label = "home page of tether" }, .{
                                .text_decoration = .none,
                                .height = .px(36),
                                .display = .Center,
                            })({
                                Static.Image("/assets/circlelogo.webp", .{
                                    .display = .Flex,
                                    .child_alignment = .{ .x = .center, .y = .center },
                                    .width = .px(42),
                                    .height = .px(42),
                                });
                            });
                            Static.Button(.{ .onPress = openMenu }, .{
                                .width = .px(36),
                                .height = .px(36),
                            })({
                                Pure.Icon("bi bi-list", .{
                                    .font_size = 24,
                                });
                            });
                        });
                    });
                    sheet.render({});
                });
            }
        });
    });
}
