const std = @import("std");
const Vapor = @import("vapor");
const Row = Vapor.Row;
const Text = Vapor.Text;
const ButtonCtx = Vapor.CtxButton;
const Icon = Vapor.Icon;
const List = Vapor.List;
const ListItem = Vapor.ListItem;
const CtxButton = Vapor.CtxButton;
const RedirectLink = Vapor.RedirectLink;
const Button = Vapor.Button;

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

pub fn init() void {
    // sheet.init(&Fabric.lib.allocator_global);
    // sidebar.* = .{};
}

pub fn show() void {
    // sheet.toggle();
}

fn goto(url: []const u8) void {
    Vapor.Kit.navigate(url);
    // sheet.toggle();
}

fn render() void {
    const current_path = Vapor.Kit.getWindowPath();
    Row().style(&.{
        .position = .{ .type = .fixed, .top = .px(60), .left = .percent(2), .z_index = 999 },
        .size = .hw(.percent(100), .mobile_desktop_percent(100, 14)),
    })({
        List().style(&.{
            .list_style = .none,
            .direction = .column,
            .padding = .{ .top = 16, .bottom = 64, .right = 8, .left = 8 },
            .child_gap = 12,
            .size = .hw(.percent(95), .percent(100)),
            .scroll = .scroll_y(),
            .show_scrollbar = false,
            .layout = .{},
        })({
            for (menu_items) |item| {
                const uuid = Vapor.fmtln("menu-{s}", .{item.link});
                ListItem()
                    .id(uuid)
                    .style(&.{
                    .size = .hw(.fit, .percent(100)),
                    .visual = .{
                        .background = if (std.mem.eql(u8, current_path, item.link)) .transparentizeHex(.palette(.tint), 0.1) else .transparent,
                        .border = .r(1, if (std.mem.eql(u8, current_path, item.link)) .palette(.tint) else .transparent),
                        .layer = if (std.mem.eql(u8, current_path, item.link)) .dot(0.5, 6, .transparentizeHex(.palette(.tint), 0.3)) else null,
                    },
                    .interactive = .{
                        .hover = .{
                            .background = if (std.mem.eql(u8, current_path, item.link)) .transparentizeHex(.palette(.tint), 0.1) else .palette(.highlight_color),
                        },
                    },
                })({
                    CtxButton(goto, .{item.link}).style(&.{
                        .visual = .{
                            .text_decoration = .none,
                            .cursor = .pointer,
                            .background = .transparent,
                        },
                        .size = .w(.percent(100)),
                        .layout = .left_center,
                        .child_gap = 12,
                        .padding = .tblr(10, 10, 8, 8),
                    })({
                        // Icon(item.icon).style(&.{
                        //     // .visual = .{ .text_color = if (std.mem.eql(u8, current_path, item.link)) .palette(.tint) else .palette(.text_color) },
                        // });
                        Text(item.label).style(&.{
                            .visual = .{
                                .text_color = if (std.mem.eql(u8, current_path, item.link)) .palette(.tint) else .palette(.text_color),
                                .font_size = 14,
                            },
                            .font_family = "Montserrat",
                        });
                    });
                });
            }
        });
    });
}
