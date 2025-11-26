const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Types = Vapor.Types;
const Dynamic = Vapor.Dynamic;
const Element = Vapor.Element;
const Sheet = @import("Sheet.zig").Sheet;
const Signal = Vapor.Signal;
const Kit = Vapor.Kit;
const println = Vapor.println;
const logo = @embedFile("logo.svg");
const Binded = Vapor.Binded;
const Box = Static.Box;
const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const Center = Static.Center;
const Icon = Vapor.Icon;

var current_route: usize = 0;
const routes: []const []const u8 = &.{
    "/docs/vapor/concepts/justletmebuild",
    "/docs/vapor/concepts/basics",
    "/docs/vapor/concepts/project",
    "/docs/vapor/concepts/routing",
    "/docs/vapor/concepts/reactivity",
    "/docs/vapor/concepts/layout",
    "/docs/vapor/concepts/styling",
    "/docs/vapor/concepts/kit",
    "/docs/vapor/concepts/events",
    "/docs/vapor/concepts/hooks",
    "/docs/vapor/concepts/performance",
    "/docs/vapor/concepts/tutorials",
    "/docs/vapor/concepts/metal",
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
    const path = Vapor.Kit.getWindowPath() orelse "/";
    setCurrentRoute(path);
    Box().style(&.{
        .size = .w(.percent(100)),
        .layout = .{ .x = .end, .y = .center },
        .child_gap = 32,
    })({
        if (getPrevPathTitle()) |title| {
            Button(.{ .on_press = gotoPrevRoute }).style(&.{
                .size = .hw(.px(72), .percent(50)),
                .visual = .{
                    .border = .simple(.palette(.border_color_light)),
                    .background = .transparent,
                    .cursor = .pointer,
                    .text_color = .palette(.text_color),
                },
                .layout = .{ .x = .start, .y = .start },
                .padding = .all(12),
                .direction = .column,
                .transition = .{ .duration = 100 },
                .interactive = .{
                    .hover = .{
                        .border = .{ .color = .palette(.tint), .thickness = .all(1) },
                        .text_color = .palette(.tint),
                    },
                },
            })({
                Text("Prev").style(&.{
                    .visual = .{ .font_size = 16 },
                });
                Center().style(&.{
                    .child_gap = 12,
                })({
                    Text(title).style(&.{
                        .visual = .{ .font_size = 18 },
                    });
                    Icon(.arrow_return_left).style(&.{
                        .visual = .{ .font_size = 16 },
                    });
                });
            });
        }
        if (getNextPathTitle()) |title| {
            Button(.{ .on_press = gotoNextRoute }).style(&.{
                .size = .hw(.px(72), .percent(50)),
                .visual = .{
                    .border = .simple(.palette(.border_color_light)),
                    .background = .transparent,
                    .cursor = .pointer,
                    .text_color = .palette(.text_color),
                },
                .padding = .all(12),
                .direction = .column,
                .transition = .{ .duration = 100 },
                .interactive = .{
                    .hover = .{
                        .border = .{ .color = .palette(.tint), .thickness = .all(1) },
                        .text_color = .palette(.tint),
                    },
                },
                .layout = .{ .x = .end, .y = .start },
            })({
                Text("Next").style(&.{
                    .visual = .{ .font_size = 16 },
                });
                Center().style(&.{
                    .child_gap = 12,
                })({
                    Icon(.arrow_return_right).style(&.{
                        .visual = .{ .font_size = 16 },
                    });
                    Text(title).style(&.{
                        .visual = .{ .font_size = 18 },
                    });
                });
            });
        }
    });
}
