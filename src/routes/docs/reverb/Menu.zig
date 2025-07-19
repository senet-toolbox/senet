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
        .link = "/docs/reverb",
        .icon = "bi bi-house", // Keep as is - perfect for home
        .tags = &.{
            Tag{
                .keywords = &.{ "reverb home", "reverb", "docs", "home" },
                .sub_title = "Reverb Docs",
                .url = "/docs/reverb",
                .description = "Reverb documentation...",
            },
        },
    },
    MenuItem{
        .title = "Just let me build!!!!",
        .link = "/docs/reverb/concepts/justletmebuild",
        .icon = "bi bi-fire", // Keep as is - perfect for home
        .tags = &.{
            Tag{
                .keywords = &.{ "started", "installation", "reverb", "immediate", "create server", "metal create server" },
                .sub_title = "Create a Server",
                .url = "/docs/reverb/concepts/justletmebuild/#create-command",
                .description = "Use reverb to create and run an applic...",
            },
        },
    },
    MenuItem{
        .title = "Introduction",
        .link = "/docs/reverb/concepts/introduction",
        .icon = "bi bi-book", // Book icon for introductory content
        .tags = &.{
            Tag{
                .keywords = &.{ "introduction", "installation", "reverb" },
                .sub_title = "Install Reverb",
                .url = "/docs/reverb/concepts/introduction/#curl-install",
                .description = "Reverb curl command install, current only for MacOS...",
            },
            Tag{
                .keywords = &.{ "introduction", "pros", "cons", "installation", "reverb" },
                .sub_title = "Install Reverb",
                .url = "/docs/reverb/concepts/introduction/#pros-cons",
                .description = "Pros and cons of using Reverb, compared...",
            },
        },
    },

    MenuItem{
        .title = "Basics",
        .link = "/docs/reverb/concepts/basics",
        .icon = "bi bi-mortarboard", // Graduation cap for learning basics
        .tags = &.{
            Tag{
                .keywords = &.{
                    "basics",
                    "learning",
                    "reverb",
                    "docs",
                },
                .sub_title = "Reverb Basics",
                .url = "/docs/reverb/concepts/basics/#introduction",
                .description = "Introduction to Reverb, and how to use it...",
            },
        },
    },
    MenuItem{
        .title = "Routing",
        .link = "/docs/reverb/concepts/routing",
        .icon = "bi bi-signpost", // Signpost for navigation/routing
    },
    MenuItem{
        .title = "Context",
        .link = "/docs/reverb/concepts/context",
        .icon = "bi bi-lightbulb",
    },
    MenuItem{
        .title = "Middleware",
        .link = "/docs/reverb/concepts/middleware",
        .icon = "bi bi-activity",
    },
    MenuItem{
        .title = "Memory Tracking",
        .link = "/docs/reverb/concepts/memory",
        .icon = "bi bi-memory",
    },
    MenuItem{
        .title = "Project Structure",
        .link = "/docs/reverb/concepts/project",
        .icon = "bi bi-diagram-3",
    },

    MenuItem{
        .title = "Loom Engine",
        .link = "/docs/reverb/concepts/loom",
        .icon = "bi bi-flower1", // Circular arrows for reactive updates
    },
    MenuItem{
        .title = "Scehduler",
        .link = "/docs/reverb/concepts/scheduler",
        .icon = "bi bi-calendar-event", // Circular arrows for reactive updates
    },
    MenuItem{
        .title = "Kit",
        .link = "/docs/reverb/concepts/kit",
        .icon = "bi bi-tools", // Tools icon for toolkit/kit
    },
    MenuItem{
        .title = "KeyStone",
        .link = "/docs/reverb/concepts/keystone",
        .icon = "bi bi-unlock",
    },
    MenuItem{
        .title = "Gotchas",
        .link = "/docs/reverb/concepts/gotchas",
        .icon = "bi bi-exclamation-triangle", // Warning triangle for gotchas/pitfalls
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
    const current_path = Fabric.Kit.getWindowPath();
    Static.FlexBox(.{
        .child_alignment = .{ .x = .between, .y = .center },
        .child_gap = 8,
        .padding = .{ .top = 8, .bottom = 8, .left = 12, .right = 12 },
        .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
        .height = .percent(6),
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
        if (!Fabric.isMobile()) {
            Static.Button(.{ .onPress = openDialog, .aria_label = "search-dialog" }, .{
                .display = .Flex,
                .child_alignment = .{ .x = .between, .y = .center },
                .width = .percent(20),
                .height = .px(38),
                .padding = .{ .top = 4, .bottom = 4, .left = 8, .right = 8 },
                .border_radius = .all(8),
                .border_thickness = .all(1),
                .border_color = .hex("#E1E1E1"),
                .background = .transparentizeHex("#ffffff", 70),
                .cursor = .pointer,
                .hover = .{ .border_color = .hex("#802BFF") },
            })({
                Static.FlexBox(.{
                    .child_alignment = .left_center,
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
        }
    });
    Static.Box(.{
        .position = .{ .type = .fixed, .top = .percent(6), .left = .percent(0) },
        .width = .clamp_percent(14, 14, 100),
        .height = .percent(100),
        .z_index = 999,
    })({
        Static.List(.{
            .list_style = .none,
            .display = .Flex,
            .direction = .column,
            .padding = .{ .top = 16, .bottom = 64, .right = 8, .left = 8 },
            .child_gap = 16,
            .width = .percent(100),
            .overflow_y = .scroll,
            .height = .percent(95),
            .show_scrollbar = false,
        })({
            for (menu_items) |item| {
                Static.ListItem(.{
                    .width = .percent(100),
                    // .border_radius = .all(4),
                    .background = if (std.mem.eql(u8, current_path, item.link)) .transparentizeHex("#802BFF", 30) else .transparent,
                    .hover = .{
                        .background = if (std.mem.eql(u8, current_path, item.link)) .transparentizeHex("#802BFF", 30) else .hex("#EDEDED"),
                    },
                    .border_thickness = .{ .right = 2 },
                    .border_color = if (std.mem.eql(u8, current_path, item.link)) .hex("#802BFF") else .transparent,
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
                        Static.Icon(item.icon, .{
                            .text_color = if (std.mem.eql(u8, current_path, item.link)) .darken("#802BFF", 30) else .hex("#212121"),
                        });
                        Static.Text(item.title, .{
                            .text_color = if (std.mem.eql(u8, current_path, item.link)) .darken("#802BFF", 30) else .hex("#212121"),
                            .font_size = 14,
                        });
                    });
                });
            }
        });
    });
    Search.render();
}

pub fn render(_: void) void {
    Static.Block(.{
        .position = .{ .top = .px(0), .type = .fixed },
        .width = .percent(14),
        .padding = .{ .bottom = 128 },
        .z_index = 999,
        .height = .percent(100),
    })({
        list();
    });
}
