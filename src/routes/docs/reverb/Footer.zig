const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Types = Fabric.Types;
const Dynamic = Fabric.Dynamic;
const Element = Fabric.Element;
const Sheet = @import("Sheet.zig").Sheet;
const Signal = Fabric.Signal;
const Kit = Fabric.Kit;
const println = Fabric.println;
const logo = @embedFile("logo.svg");
const Binded = Fabric.Binded;

var current_route: usize = 0;
const routes: []const []const u8 = &.{
    "/docs/reverb/concepts/introduction",
    "/docs/reverb/concepts/basics",
    "/docs/reverb/concepts/routing",
    "/docs/reverb/concepts/context",
    "/docs/reverb/concepts/middleware",
    "/docs/reverb/concepts/memory",
    "/docs/reverb/concepts/project",
    "/docs/reverb/concepts/loom",
    "/docs/reverb/concepts/scheduler",
    "/docs/reverb/concepts/kit",
    "/docs/reverb/concepts/keystone",
    "/docs/reverb/concepts/gotchas",
    "/docs/reverb/concepts/metal",
};

fn gotoNextRoute() void {
    current_route += 1;
    const route = routes[current_route];
    Kit.navigate(route);
}

fn gotoPrevRoute() void {
    if (current_route == 0) return;
    current_route -= 1;
    const route = routes[current_route];
    Kit.navigate(route);
}

fn getPrevPathTitle() ?[]const u8 {
    if (current_route < 1) return null;
    const path = routes[current_route - 1];
    var segments = std.mem.tokenizeScalar(u8, path, '/');
    while (segments.next()) |current| {
        if (segments.peek() == null) {
            return current;
        }
    }
    return null;
}

fn getNextPathTitle() ?[]const u8 {
    if (current_route >= routes.len - 1) return null;
    const path = routes[current_route + 1];
    var segments = std.mem.tokenizeScalar(u8, path, '/');
    while (segments.next()) |current| {
        if (segments.peek() == null) {
            return current;
        }
    }
    return null;
}

fn setCurrentRoute(path: []const u8) void {
    for (routes, 0..) |route, i| {
        if (std.mem.eql(u8, path, route)) {
            current_route = i;
        }
    }
}

pub fn render() void {
    const path = Fabric.Kit.getWindowPath();
    setCurrentRoute(path);
    Static.FlexBox(.{
        .width = .percent(100),
        .child_alignment = .{ .x = .end, .y = .center },
        .child_gap = 32,
    })({
        if (getPrevPathTitle()) |title| {
            Static.Button(.{ .onPress = gotoPrevRoute }, .{
                .width = .percent(50),
                .height = .px(72),
                .border_radius = .all(4),
                .border_color = .hex("#ebedf0"),
                .border_thickness = .all(1),
                .display = .Flex,
                .padding = .all(12),
                .direction = .column,
                .transition = .{},
                .hover = .{ .border_color = .hex("#802BFF"), .border_thickness = .all(1) },
                .cursor = .pointer,
            })({
                Static.Text("Prev", .{
                    .font_size = 16,
                });
                Static.Center(.{
                    .child_gap = 12,
                })({
                    Static.Text(title, .{
                        .font_size = 18,
                        .text_color = .hex("#282a36"),
                    });
                    Static.Icon("bi bi-arrow-return-left", .{
                        .font_size = 16,
                    });
                });
            });
        }
        if (getNextPathTitle()) |title| {
            Static.Button(.{ .onPress = gotoNextRoute }, .{
                .width = .percent(50),
                .height = .px(72),
                .border_radius = .all(4),
                .border_color = .hex("#ebedf0"),
                .border_thickness = .all(1),
                .display = .Flex,
                .padding = .all(12),
                .child_alignment = .{ .x = .end, .y = .start },
                .direction = .column,
                .transition = .{},
                .hover = .{ .border_color = .hex("#802BFF"), .border_thickness = .all(1) },
                .cursor = .pointer,
                .background = .transparent,
            })({
                Static.Text("Next", .{
                    .font_size = 16,
                });
                Static.Center(.{
                    .child_gap = 12,
                })({
                    Static.Icon("bi bi-arrow-return-right", .{
                        .font_size = 16,
                    });
                    Static.Text(title, .{
                        .font_size = 18,
                        .text_color = .hex("#282a36"),
                    });
                });
            });
        }
    });
}
