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
    "/docs/fabric/concepts/introduction",
    "/docs/fabric/concepts/basics",
    "/docs/fabric/concepts/project",
    "/docs/fabric/concepts/routing",
    "/docs/fabric/concepts/reactivity",
    "/docs/fabric/concepts/kit",
    "/docs/fabric/concepts/events",
    "/docs/fabric/concepts/bridge",
    "/docs/fabric/concepts/gotchas",
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
    const path = routes[current_route + 1];
    var segments = std.mem.tokenizeScalar(u8, path, '/');
    while (segments.next()) |current| {
        if (segments.peek() == null) {
            return current;
        }
    }
    return null;
}

pub fn render() void {
    Static.FlexBox(.{
        .width = .percent(100),
        .child_alignment = .{ .x = .end, .y = .center },
        .child_gap = 32,
    })({
        if (getPrevPathTitle()) |title| {
            Static.Button(.{ .onPress = gotoPrevRoute }, .{
                .width = .percent(50),
                .height = .fixed(72),
                .border_radius = .all(4),
                .border_color = .hex("#ebedf0"),
                .border_thickness = .all(1),
                .display = .Flex,
                .padding = .all(12),
                .child_alignment = .{ .x = .start, .y = .start },
                .direction = .column,
                .transition = .{},
                .hover = .{ .border_color = .hex("#802BFF"), .border_thickness = .all(1) },
                .cursor = .pointer,
            })({
                Static.Text("Prev", .{
                    .font_size = 16,
                });
                Static.FlexBox(.{
                    .child_gap = 12,
                })({
                    Static.Icon("bi bi-arrow-return-left", .{
                        .font_size = 16,
                    });
                    Static.Text(title, .{
                        .font_size = 18,
                        .text_color = .hex("#282a36"),
                    });
                });
            });
        }
        if (getNextPathTitle()) |title| {
            Static.Button(.{ .onPress = gotoNextRoute }, .{
                .width = .percent(50),
                .height = .fixed(72),
                .border_radius = .all(4),
                .border_color = .hex("#ebedf0"),
                .border_thickness = .all(1),
                .display = .Flex,
                .padding = .all(12),
                .child_alignment = .{ .x = .start, .y = .end },
                .direction = .column,
                .transition = .{},
                .hover = .{ .border_color = .hex("#802BFF"), .border_thickness = .all(1) },
                .cursor = .pointer,
            })({
                Static.Text("Next", .{
                    .font_size = 16,
                });
                Static.FlexBox(.{
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
