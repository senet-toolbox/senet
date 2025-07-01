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
const main = @import("../../../main.zig");

var theme_background: [4]u8 = undefined;
var border_color: [4]u8 = undefined;
var text_color: [4]u8 = undefined;
var dark_text: [4]u8 = undefined;
var secondary: [4]u8 = undefined;
var tint: [4]u8 = undefined;
var alternate_tint: [4]u8 = undefined;
var input_element: Element = Element{};

const SideBar = @This();

const MenuItem = struct {
    title: []const u8,
    link: []const u8,
    icon: []const u8,
};

const menu_items: []const MenuItem = &.{
    MenuItem{
        .title = "Home",
        .link = "/docs/fabric",
        .icon = "bi bi-house", // Keep as is - perfect for home
    },
    MenuItem{
        .title = "Just let me build!!!!",
        .link = "/docs/fabric/concepts/justletmebuild",
        .icon = "bi bi-fire", // Keep as is - perfect for home
    },
    MenuItem{
        .title = "Introduction",
        .link = "/docs/fabric/concepts/introduction",
        .icon = "bi bi-book", // Book icon for introductory content
    },
    MenuItem{
        .title = "Basics",
        .link = "/docs/fabric/concepts/basics",
        .icon = "bi bi-mortarboard", // Graduation cap for learning basics
    },
    MenuItem{
        .title = "Project Structure",
        .link = "/docs/fabric/concepts/project",
        .icon = "bi bi-diagram-3",
    },
    MenuItem{
        .title = "Routing",
        .link = "/docs/fabric/concepts/routing",
        .icon = "bi bi-signpost", // Signpost for navigation/routing
    },
    MenuItem{
        .title = "Reactivity",
        .link = "/docs/fabric/concepts/reactivity",
        .icon = "bi bi-arrow-repeat", // Circular arrows for reactive updates
    },
    MenuItem{
        .title = "Kit",
        .link = "/docs/fabric/concepts/kit",
        .icon = "bi bi-tools", // Tools icon for toolkit/kit
    },
    MenuItem{
        .title = "Events & Handlers",
        .link = "/docs/fabric/concepts/events",
        .icon = "bi bi-cursor",
    },
    MenuItem{
        .title = "JS Libs",
        .link = "/docs/fabric/concepts/jslibs",
        .icon = "bi bi-filetype-js", // Tools icon for toolkit/kit
    },
    MenuItem{
        .title = "WASM Bridge",
        .link = "/docs/fabric/concepts/bridge",
        .icon = "bi bi-ethernet",
    },

 
    MenuItem{
        .title = "Gotchas",
        .link = "/docs/fabric/concepts/gotchas",
        .icon = "bi bi-exclamation-triangle", // Warning triangle for gotchas/pitfalls
    },
};
pub fn init() void {}

fn openDialog() void {}

fn list() void {
    Static.FlexBox(.{
        .child_alignment = .{ .x = .between, .y = .center },
        .child_gap = 8,
        .padding = .{ .top = 8, .bottom = 8, .left = 12, .right = 12 },
        .position = .{ .type = .fixed, .top = .fixed(0), .left = .percent(0), .right = .percent(0) },
        .width = .percent(100),
        .z_index = 999,
        .blur = 3,
        .border_color = main.theme.getAttribute("border_color"),
        .border_thickness = .{ .bottom = 1 },
    })({
        Static.FlexBox(.{
            .child_alignment = .{ .x = .start, .y = .center },
            .child_gap = 8,
        })({
            Static.Link(.{ .url = "/", .aria_label = "home page of tether" }, .{
                .text_decoration = .none,
                .cursor = .pointer,
            })({
                Static.Svg(logo, .{
                    .display = .Flex,
                    .child_alignment = .{ .x = .center, .y = .center },
                    .width = .fixed(36),
                });
            });
            Static.Text("Tether", .{
                .font_weight = 500,
                .font_size = 18,
            });
            Static.Block(.{
                .border_thickness = .{ .left = 1 },
                .height = .fixed(24),
                .border_color = .rgb(0, 0, 0),
            })({});
            Static.Text("Docs", .{
                .font_weight = 500,
                .font_size = 18,
            });
        });

        Static.Button(.{ .onPress = openDialog, .aria_label = "search-dialog" }, .{
            .display = .Flex,
            .child_alignment = .{ .x = .between, .y = .center },
            .width = .percent(16),
            .height = .fixed(38),
            .padding = .{ .top = 4, .bottom = 4, .left = 8, .right = 8 },
            .border_radius = .all(8),
            .border_thickness = .all(1),
            .border_color = .hex("#3A3A3A"),
            .background = .transparent,
            .cursor = .pointer,
            .hover = .{ .border_color = .hex("#802BFF") }
        })({
            Static.FlexBox(.{
                .child_alignment = .start_center,
                .child_gap = 24,
            })({
                Static.Icon("bi bi-search", .{
                    .font_size = 16,
                });
                Static.Text("Search...", .{
                    .font_size = 16,
                });
            });
            Static.Icon("bi bi-command", .{
                .font_size = 16,
            });
        });
    });
    Static.List(.{
        .list_style = .none,
        .display = .Flex,
        .direction = .column,
        .padding = .{ .top = 16, .bottom = 16, .right = 8, .left = 8 },
        .child_gap = 16,
        .width = .percent(14),
        .position = .{ .type = .fixed, .top = .fixed(48) },
    })({
        for (menu_items) |item| {
            Static.ListItem(.{
                .width = .percent(100),
                .border_radius = .all(4),
                .hover = .{
                    .background = .hex("#E4E4E4"),
                },
            })({
                Static.Link(.{ .url = item.link, .aria_label = item.title }, .{
                    .text_decoration = .none,
                    .width = .percent(100),
                    .display = .Flex,
                    .child_alignment = .{ .x = .start, .y = .center },
                    .child_gap = 12,
                    .padding = .{ .top = 10, .bottom = 10, .right = 8, .left = 8 },
                    .cursor = .pointer,
                })({
                    Static.Icon(item.icon, .{});
                    Static.Text(item.title, .{
                        .font_size = 14,
                    });
                });
            });
        }
    });
}

pub fn render() void {
    list();
}
