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
const Search = @import("../../../components/Search.zig");

var theme_background: [4]u8 = undefined;
var border_color: [4]u8 = undefined;
var text_color: [4]u8 = undefined;
var dark_text: [4]u8 = undefined;
var secondary: [4]u8 = undefined;
var tint: [4]u8 = undefined;
var alternate_tint: [4]u8 = undefined;
var input_element: Element = Element{};

const SideBar = @This();

const Tag = struct {
    keywords: Keywords = &.{},
    url: []const u8 = "",
    sub_title: []const u8 = "",
    description: []const u8 = "",
};
const Keywords = []const []const u8;
const MenuItem = struct {
    title: []const u8,
    link: []const u8,
    icon: []const u8,
    tags: []const Tag = &.{},
};

pub const menu_items: []const MenuItem = &.{
    MenuItem{
        .title = "Home",
        .link = "/docs/fabric",
        .icon = "bi bi-house", // Keep as is - perfect for home
        .tags = &.{
            Tag{
                .keywords = &.{ "fabric home", "fabric", "docs", "home" },
                .sub_title = "Fabric Docs",
                .url = "/docs/fabric",
                .description = "Fabric documentation...",
            },
        },
    },
    MenuItem{
        .title = "Just let me build!!!!",
        .link = "/docs/fabric/concepts/justletmebuild",
        .icon = "bi bi-fire", // Keep as is - perfect for home
        .tags = &.{
            Tag{
                .keywords = &.{ "started", "installation", "fabric", "immediate", "create app", "fabric create app" },
                .sub_title = "Create an App",
                .url = "/docs/fabric/concepts/justletmebuild/#create-command",
                .description = "Use fabric to create and run an applic...",
            },
        },
    },
    MenuItem{
        .title = "Introduction",
        .link = "/docs/fabric/concepts/introduction",
        .icon = "bi bi-book", // Book icon for introductory content
        .tags = &.{
            Tag{
                .keywords = &.{ "introduction", "installation", "fabric" },
                .sub_title = "Install Fabric",
                .url = "/docs/fabric/concepts/introduction/#curl-install",
                .description = "Fabric curl command install, current only for MacOS...",
            },
            Tag{
                .keywords = &.{ "introduction", "pros", "cons", "installation", "fabric" },
                .sub_title = "Install Fabric",
                .url = "/docs/fabric/concepts/introduction/#pros-cons",
                .description = "Pros and cons of using Fabric, compared...",
            },
        },
    },

    MenuItem{
        .title = "Basics",
        .link = "/docs/fabric/concepts/basics",
        .icon = "bi bi-mortarboard", // Graduation cap for learning basics
        .tags = &.{
            Tag{
                .keywords = &.{ "basics", "learning", "fabric", "docs", "reconciler", "rendering" },
                .sub_title = "Fabric Basics",
                .url = "/docs/fabric/concepts/basics/#introduction",
                .description = "Introduction to Fabric, and how to use it...",
            },
            Tag{
                .keywords = &.{ "reconciler", "rendering", "rerender" },
                .sub_title = "How rendering works",
                .url = "/docs/fabric/concepts/basics/#reconciler",
                .description = "How the reconciler and rendering of fabric wor...",
            },
        },
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
        .title = "Styling",
        .link = "/docs/fabric/concepts/styling",
        .icon = "bi bi-paint-bucket", // Circular arrows for reactive updates
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
        .title = "Lifecycle Hooks",
        .link = "/docs/fabric/concepts/hooks",
        .icon = "bi bi-hourglass-split",
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
        .title = "KeyStone",
        .link = "/docs/fabric/concepts/keystone",
        .icon = "bi bi-unlock",
    },
    MenuItem{
        .title = "Gotchas",
        .link = "/docs/fabric/concepts/gotchas",
        .icon = "bi bi-exclamation-triangle", // Warning triangle for gotchas/pitfalls
    },
    MenuItem{
        .title = "Tutorials",
        .link = "/docs/fabric/concepts/tutorials",
        .icon = "bi bi-award",
    },

    MenuItem{
        .title = "Metal",
        .link = "/docs/metal",
        .icon = "bi bi-motherboard", // Graduation cap for learning basics
        .tags = &.{
            Tag{
                .keywords = &.{ "metal", "docker" },
                .sub_title = "No more Docker",
                .url = "/docs/metal/#introduction",
                .description = "Tether, and all its sub frameworks run on metal, no docker...",
            },
        },
    },
};
pub fn init() void {}

fn openDialog() void {
    Search.toggle();
}

fn list() void {
    if (!Fabric.isMobile()) {
        Static.FlexBox(.{
            .child_alignment = .{ .x = .between, .y = .center },
            .child_gap = 8,
            .padding = .{ .top = 8, .bottom = 8, .left = 12, .right = 12 },
            .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
            .width = .percent(100),
            .z_index = 400,
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
                    Static.Image("/assets/circlelogo.webp", .{
                        .display = .Flex,
                        .child_alignment = .{ .x = .center, .y = .center },
                        .width = .px(42),
                        .height = .px(42),
                    });
                });
                Static.Text("Tether", .{
                    .font_weight = 500,
                    .font_size = 18,
                });
                // Static.Svg(@embedFile("text.svg"), .{
                //     .width = .px(80),
                // });
                Static.Block(.{
                    .border_thickness = .{ .left = 1 },
                    .height = .px(24),
                    .border_color = .rgb(0, 0, 0),
                })({});
                Static.Text("Docs", .{
                    .font_weight = 700,
                    .font_size = 18,
                });
            });
            Static.Button(.{ .onPress = openDialog, .aria_label = "search-dialog" }, .{
                .display = .Flex,
                .child_alignment = .{ .x = .between, .y = .center },
                .width = .percent(20),
                .height = .px(38),
                .padding = .{ .top = 4, .bottom = 4, .left = 8, .right = 8 },
                .border_radius = .all(8),
                .border_thickness = .all(1),
                .border_color = .hex("#E1E1E1"),
                .background = .transparent,
                .cursor = .pointer,
                .hover = .{ .border_color = .hex("#802BFF") },
            })({
                Static.FlexBox(.{
                    .child_alignment = .start_center,
                    .child_gap = 24,
                })({
                    Static.Icon("bi bi-search", .{
                        .font_size = 16,
                        .text_color = .hex("#A2A2A2"),
                    });
                    Static.Text("Search...", .{
                        .font_family = "Montserrat",
                        .font_size = 16,
                        .text_color = .hex("#A2A2A2"),
                    });
                });
                Static.Icon("bi bi-command", .{
                    .font_size = 16,
                    .text_color = .hex("#A2A2A2"),
                });
            });
        });
    }
    Static.List(.{
        .list_style = .none,
        .display = .Flex,
        .direction = .column,
        .padding = .{ .top = 16, .bottom = 16, .right = 8, .left = 8 },
        .child_gap = 16,
        .width = .percent(100),
        .overflow_y = .scroll,
        .height = .percent(100),
        .show_scrollbar = false,
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
    Search.render();
}

pub fn render(_: void) void {
    list();
}
