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

var theme_background: [4]u8 = undefined;
var border_color: [4]u8 = undefined;
var text_color: [4]u8 = undefined;
var dark_text: [4]u8 = undefined;
var secondary: [4]u8 = undefined;
var tint: [4]u8 = undefined;
var alternate_tint: [4]u8 = undefined;
var sheet: Sheet(*SideBar, list) = undefined;

const SideBar = @This();

const MenuItem = struct {
    title: []const u8,
    link: []const u8,
    icon: []const u8,
};

const menu_items: []const MenuItem = &.{
    MenuItem{
        .title = "Dashboard",
        .link = "/nightwatch/dashboard",
        .icon = "bi bi-house",
    },
    MenuItem{
        .title = "Projects",
        .link = "/nightwatch/projects",
        .icon = "bi bi-box",
    },
    MenuItem{
        .title = "Routes",
        .link = "/nightwatch/routes",
        .icon = "bi bi-diagram-3",
    },
    MenuItem{
        .title = "Treehouse",
        .link = "/nightwatch/treehouse",
        .icon = "bi bi-tree",
    },
    MenuItem{
        .title = "Database",
        .link = "/nightwatch/database",
        .icon = "bi bi-database",
    },
    MenuItem{
        .title = "Activity",
        .link = "/nightwatch/activity",
        .icon = "bi bi-activity",
    },
    MenuItem{
        .title = "Memory",
        .link = "/nightwatch/memory",
        .icon = "bi bi-memory",
    },
    MenuItem{
        .title = "Logs",
        .link = "/nightwatch/logs",
        .icon = "bi bi-lightbulb",
    },
    MenuItem{
        .title = "Sql Editor",
        .link = "/nightwatch/sql-editor",
        .icon = "bi bi-code-slash",
    },
};

pub fn init(sidebar: *SideBar) void {
    sheet.init(&Fabric.lib.allocator_global);
    sidebar.* = .{};
}

pub fn show() void {
    sheet.toggle();
}

fn list(_: *SideBar) void {
    Static.List(.{
        .list_style = .none,
        .display = .flex,
        .direction = .column,
        .padding = .{ .top = 16, .bottom = 16, .right = 16, .left = 16 },
        .child_gap = 16,
        .width = .percent(100),
    })({
        for (menu_items) |item| {
            Static.ListItem(.{
                .width = .percent(100),
                .border_radius = .all(4),
                .hover = .{
                    .background = .hex("#121212"),
                },
            })({
                Static.Link(item.link, .{
                    .text_decoration = .none,
                    .width = .percent(100),
                    .display = .flex,
                    .child_alignment = .{ .x = .start, .y = .center },
                    .child_gap = 12,
                    .padding = .{ .top = 10, .bottom = 10, .right = 8, .left = 8 },
                    .cursor = .pointer,
                })({
                    // Static.Icon(item.icon, .{
                    //     .font_size = 14,
                    // });
                    Static.Text(item.title, .{
                        .font_size = 14,
                    });
                });
            });
        }
    });
}

pub fn render(sidebar: *SideBar) void {
    Static.Block(.{
        .padding = .{
            .top = 120,
        },
        .width = .percent(100),
    })({
        sheet.render(sidebar);
    });
}
