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
const Reactivity = @import("reactivity/Page.zig");
const Kit = @import("kit/Page.zig");
const Events = @import("events/Page.zig");
const Project = @import("project/Page.zig");
const JSLibs = @import("jslibs/Page.zig");
const Bridge = @import("bridge/Page.zig");
const Just = @import("justletmebuild/Page.zig");
const Menu = @import("../../Menu.zig");
const Footer = @import("../../Footer.zig");

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
                .introduction => {
                    return Introduction.render;
                },
                .project => {
                    return Project.render;
                },
                .kit => {
                    return Kit.render;
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
                else => return null,
            }
        }
    }
    return null;
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
            .child_alignment = .{ .x = .start, .y = .start },
            .padding = .horizontal(12),
            .direction = .row,
            .width = .percent(100),
            // .height = .percent(90),
        })({
            Static.Block(.{
                .width = .percent(12),
            })({
                Menu.render();
            });
            Static.FlexBox(.{
                .width = .grow,
                .child_alignment = .start_center,
                .padding = .{ .top = 60, .bottom = 120 },
                .direction = .column,
            })({
                Static.FlexBox(.{
                    .width = .percent(64),
                    .child_gap = 32,
                    .direction = .column,
                    .child_alignment = .{ .x = .start, .y = .start },
                    .padding = .{ .bottom = 120 },
                })({
                    render_page();
                    Footer.render();
                });
            });
        });
    });
}
