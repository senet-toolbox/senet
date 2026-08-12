const std = @import("std");
const Vapor = @import("vapor");
const Types = Vapor.Types;
const Dynamic = Vapor.Dynamic;
const Element = Vapor.Element;
const Signal = Vapor.Signal;
const Kit = Vapor.Kit;
const logo = @embedFile("logo.svg");
const Binded = Vapor.Binded;
const Row = Vapor.Row;
const Text = Vapor.Text;
const Link = Vapor.Link;
const Image = Vapor.Image;
const Svg = Vapor.Svg;
const Button = Vapor.Button;
const Center = Vapor.Center;
const Icon = Vapor.Icon;
const menu_items = @import("../../../components/DocNavbar.zig").menu_items;
const MenuItem = @import("../../../components/DocNavbar.zig").MenuItem;
const goto = @import("../../../components/DocNavbar.zig").goto;

var current_route: usize = 0;

fn gotoNextRoute() void {
    current_route += 1;
    const route = menu_items[current_route].link;
    goto(route);
}

fn gotoPrevRoute() void {
    if (current_route == 0) return;
    current_route -= 1;
    const route = menu_items[current_route].link;
    goto(route);
}

fn getPrevPath() ?MenuItem {
    if (current_route < 1) return null;
    return menu_items[current_route - 1];
}

fn getNextPathItem() ?MenuItem {
    if (current_route >= menu_items.len - 1) return null;
    return menu_items[current_route + 1];
}

fn setCurrentRoute(path: []const u8) void {
    for (menu_items, 0..) |route, i| {
        if (std.mem.eql(u8, path, route.link)) {
            current_route = i;
        }
    }
}

var hovered_item: ?MenuItem = null;
fn onHover(item: MenuItem, _: *Vapor.Event) void {
    hovered_item = item;
}

fn onLeave(_: *Vapor.Event) void {
    hovered_item = null;
}

fn isSvg(item: MenuItem) bool {
    const react = std.mem.eql(u8, item.id, "react-to-vapor");
    const components = std.mem.eql(u8, item.id, "components");
    const deep = std.mem.eql(u8, item.id, "deep-dive");
    if (react or components or deep) {
        return true;
    }
    return false;
}
const BtnType = enum {
    Prev,
    Next,
};

fn renderBtn(btn_type: BtnType, item: MenuItem, callback: anytype) void {
    const is_prev = btn_type == .Prev;
    return Button(callback, .{})
        .class(if (is_prev) "prev-btn" else "next-btn")
        .size(.hw(.px(128), .percent(45)))
        .border(.simple(.palette(.border_color_light)))
        .background(.transparent)
        .cursor(.pointer)
        .padding(.all(12))
        .direction(.column)
        .layout(if (is_prev) .{ .x = .start, .y = .even } else .{ .x = .end, .y = .even })
        .duration(100)
        .fill(.palette(.text_color))
        .hover(.{
            .border = .simple(.palette(.tint)),
            .text_color = .palette(.tint),
            .fill = .palette(.tint),
        })
        .children({
        if (isSvg(item)) {
            applyIconsStyles(Vapor.Svg(.{ .svg = item.icon.svg.?, .override = true })).end();
        } else {
            applyIconsStyles(Icon(item.icon)).end();
        }
        Center().spacing(12).children({
            Text(item.title).fontSize(18).end();
        });
    });
}

pub fn render() void {
    const path = Vapor.Kit.getWindowPath() orelse "/";
    setCurrentRoute(path);
    Row().style(&.{
        .size = .w(.percent(100)),
        .layout = .x_between_center,
        .spacing = 32,
    }).children({
        if (getPrevPath()) |item| {
            renderBtn(.Prev, item, gotoPrevRoute);
        }
        if (getNextPathItem()) |item| {
            renderBtn(.Next, item, gotoNextRoute);
        }
    });
}

fn applyIconsStyles(component: Vapor.Builder(.pure)) Vapor.Builder(.pure) {
    return component
        .class("btn-icon")
        .fontSize(18)
        .height(.px(32))
        .padding(.all(4))
        .font(18, null, .palette(.text_color))
        .width(.px(32))
        .inheritHover(&.{ .border, .text_color, .fill })
        .layout(.center)
        .border(.{
        .color = .palette(.border_color_light),
        .thickness = .all(1),
    });
}
