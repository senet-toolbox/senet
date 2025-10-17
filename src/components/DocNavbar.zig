const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Types = Fabric.Types;
const Dynamic = Fabric.Dynamic;
const Element = Fabric.Element;
// const Sheet = @import("Sheet.zig").Sheet;
const Signal = Fabric.Signal;
const Kit = Fabric.Kit;
const println = Fabric.println;
const logo = @embedFile("logo.svg");
const Binded = Fabric.Binded;
const Search = @import("Search.zig");
const Center = Static.Center;
const Box = Static.Box;
const Image = Static.Image;
const Text = Static.Text;
const Page = Fabric.Page;
const Pure = Fabric.Pure;
const Graphic = Static.Graphic;
const Icon = Static.Icon;
const Button = Static.Button;
const ButtonCycle = Static.ButtonCycle;
const Link = Static.Link;
const List = Static.List;
const ListItem = Static.ListItem;
const RedirectLink = Static.RedirectLink;
const Theme = @import("theme");
const IconTokens = @import("user_config").IconTokens;

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
pub const MenuItem = struct {
    id: []const u8,
    title: []const u8,
    link: []const u8,
    icon: *const IconTokens,
    tags: []const Tag = &.{},
};

pub const menu_items: []const MenuItem = &.{
    MenuItem{
        .id = "home",
        .title = "Home",
        .link = "/docs/fabric",
        .icon = .house, // Keep as is - perfect for home
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
        .id = "just-let-me-build",
        .title = "Just let me build!!!!",
        .link = "/docs/fabric/concepts/justletmebuild",
        .icon = .fire, // Keep as is - perfect for home
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
        .id = "introduction",
        .title = "Introduction",
        .link = "/docs/fabric/concepts/introduction",
        .icon = .book, // Book icon for introductory content
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
        .id = "basics",
        .title = "Basics",
        .link = "/docs/fabric/concepts/basics",
        .icon = .mortarboard, // Graduation cap for learning basics
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
        .id = "project-structure",
        .title = "Project Structure",
        .link = "/docs/fabric/concepts/project",
        .icon = .diagram_3,
        .tags = &.{
            Tag{
                .keywords = &.{"routing"},
                .sub_title = "Routes Directory",
                .url = "/docs/fabric/concepts/project/#routes-directory",
                .description = "Routes Directory...",
            },
            Tag{
                .keywords = &.{"web"},
                .sub_title = "Web Directory",
                .url = "/docs/fabric/concepts/project/#web-directory",
                .description = "Web Directory...",
            },
        },
    },
    MenuItem{
        .id = "routing",
        .title = "Routing",
        .link = "/docs/fabric/concepts/routing",
        .icon = .signpost, // Signpost for navigation/routing
        .tags = &.{
            Tag{
                .keywords = &.{ "dynamic", "routes", "dynamic routes" },
                .sub_title = "Dynamci Routes",
                .url = "/docs/fabric/concepts/routing/#dynamic-routes",
                .description = "Dynamic Routes...",
            },
        },
    },
    MenuItem{
        .id = "reactivity",
        .title = "Reactivity",
        .link = "/docs/fabric/concepts/reactivity",
        .icon = .arrow_repeat, // Circular arrows for reactive updates
        .tags = &.{
            Tag{
                .keywords = &.{ "ui to code", "ui reactivity" },
                .sub_title = "UI to Code",
                .url = "/docs/fabric/concepts/reactivity/#ui-to-code",
                .description = "Going from UI to Code...",
            },
        },
    },
    MenuItem{
        .id = "layout",
        .title = "Layout",
        .link = "/docs/fabric/concepts/layout",
        .icon = .columns, // Circular arrows for reactive updates
        .tags = &.{
            Tag{
                .keywords = &.{ "layout", "defaults", "spacing", "overlay" },
                .sub_title = "Introduction",
                .url = "/docs/fabric/concepts/layout/#introduction",
                .description = "How to use layouts...",
            },
        },
    },
    MenuItem{
        .id = "styling",
        .title = "Styling",
        .link = "/docs/fabric/concepts/styling",
        .icon = .paint_bucket, // Circular arrows for reactive updates
    },
    MenuItem{
        .id = "kit",
        .title = "Kit",
        .link = "/docs/fabric/concepts/kit",
        .icon = .tools, // Tools icon for toolkit/kit
    },
    MenuItem{
        .id = "events-and-handlers",
        .title = "Events & Handlers",
        .link = "/docs/fabric/concepts/events",
        .icon = .cursor,
    },
    MenuItem{
        .id = "lifecycle-hooks",
        .title = "Lifecycle Hooks",
        .link = "/docs/fabric/concepts/hooks",
        .icon = .hourglass_split,
    },
    MenuItem{
        .id = "js-libs",
        .title = "JS Libs",
        .link = "/docs/fabric/concepts/jslibs",
        .icon = .filetype_js, // Tools icon for toolkit/kit
    },
    MenuItem{
        .id = "wasm-bridge",
        .title = "WASM Bridge",
        .link = "/docs/fabric/concepts/bridge",
        .icon = .ethernet,
    },
    MenuItem{
        .id = "keystone",
        .title = "KeyStone",
        .link = "/docs/fabric/concepts/keystone",
        .icon = .unlock,
        .tags = &.{
            Tag{
                .keywords = &.{ "keystone", "auth", "authentication", "login", "signup", "registration", "login", "signup", "registration" },
                .sub_title = "KeyStone is the Auth system",
                .url = "/docs/fabric/concepts/reactivity/#sign-up",
                .description = "How to sign up and login with Oauth...",
            },
        },
    },
    MenuItem{
        .id = "gotchas",
        .title = "Gotchas",
        .link = "/docs/fabric/concepts/gotchas",
        .icon = .exclamation_triangle, // Warning triangle for gotchas/pitfalls
    },
    MenuItem{
        .id = "tutorials",
        .title = "Tutorials",
        .link = "/docs/fabric/concepts/tutorials",
        .icon = .award,
    },

    MenuItem{
        .id = "metal",
        .title = "Metal",
        .link = "/docs/metal",
        .icon = .motherboard, // Graduation cap for learning basics
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

fn toggleTheme() void {
    println("Toggle Theme", .{});
    Theme.toggleTheme();
    Fabric.cycle();
}

fn list() void {
    const current_path = Fabric.Kit.getWindowPath();
    Box.style(&.{
        .layout = .x_between_center,
        .child_gap = 8,
        .padding = .{ .top = 8, .bottom = 8, .left = 12, .right = 12 },
        .position = .{ .type = .fixed, .top = .px(0), .left = .percent(8), .right = .percent(0) },
        .size = .hw(.mobile_desktop_percent(8, 6), .percent(100 - 8)),
        .z_index = 400,
        .blur = 3,
    })({
        Box.style(&.{
            .layout = .x_between_center,
            .child_gap = 8,
            .size = .h(.percent(100)),
        })({
            Link(.{ .url = "/", .aria_label = "home page of tether" }).style(&.{
                .visual = .{ .text_decoration = .none },
                .cursor = .pointer,
            })({
                Image(.{ .src = "/assets/circlelogo.webp" }).style(&.{
                    .layout = .center,
                    .size = .square_px(42),
                });
            });
            Text("Tether").style(&.{
                .visual = .{ .font_weight = 500, .font_size = 18 },
            });
            // Svg(@embedFile("text.svg"), .{
            //     .size = .{ .w(.px(80),
            // });
            Box.style(&.{
                .visual = .{ .border = .l(1, .rgb(0, 0, 0)) },
                .size = .{ .height = .px(24) },
            })({});
            Text("Docs").style(&.{
                .visual = .{ .font_weight = 700, .font_size = 18 },
            });
        });
        if (!Fabric.isMobile()) {
            // Button(.{ .on_press = openDialog, .aria_label = "search-dialog" }).style(&.{
            //     .layout = .x_between_center,
            //     .size = .hw(.px(38), .percent(20)),
            //     .padding = .{ .top = 4, .bottom = 4, .left = 8, .right = 8 },
            //     .visual = .{
            //         .border = .solid(.all(1), .hex("#E1E1E1"), .all(8)),
            //         .background = .transparentizeHex("#ffffff", 70),
            //     },
            //     .cursor = .pointer,
            //     .interactive = .{ .hover = .{ .border_color = .hex("#802BFF") } },
            // })({
            //     Box.style(&.{
            //         .layout = .left_center,
            //         .child_gap = 24,
            //     })({
            //         Icon("bi bi-search").style(&.{
            //             .visual = .{ .font_size = 16, .text_color = .hex("#A2A2A2") },
            //         });
            //         Text("Search...").style(&.{
            //             .visual = .{ .font_size = 16, .text_color = .hex("#A2A2A2") },
            //             .font_family = "Montserrat",
            //         });
            //     });
            //     Icon("bi bi-command").style(&.{
            //         .visual = .{ .font_size = 16, .text_color = .hex("#A2A2A2") },
            //     });
            // });

            ButtonCycle(.{ .on_press = openDialog, .aria_label = "search-dialog" }).style(&.{
                .layout = .x_between_center,
                .size = .hw(.px(38), .percent(50)),
                .padding = .tblr(4, 4, 8, 8),
                .visual = .button(.palette(.background), .simple(.hex("#E1E1E1"))),
                .cursor = .pointer,
                .interactive = .{ .hover = .{
                    .border = .simple(.palette(.tint)),
                } },
            })({
                Box.style(&.{ .layout = .left_center, .child_gap = 24 })({
                    Icon(.search).style(&.{
                        .visual = .{ .font_size = 16, .text_color = .palette(.icon_color) },
                    });
                    Text("Search...").style(&.{
                        .visual = .{ .font_size = 16, .text_color = .palette(.icon_color) },
                        .font_family = "Montserrat, sans-serif",
                    });
                });
                Icon(.command).style(&.{
                    .visual = .{ .font_size = 16, .text_color = .palette(.icon_color) },
                });
            });
            // Box.plain();
            Box.style(&.{
                .size = .{ .width = .percent(20), .height = .percent(100) },
                .layout = .right_center,
                .padding = .horizontal(12),
                .child_gap = 24,
            })({
                Button(.{ .on_press = toggleTheme }).style(&.{
                    .visual = .{ .background = .transparent },
                    .cursor = .pointer,
                })({
                    Icon(.cloud_moon).style(&.{
                        .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                        .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
                    });
                });
            });
        }
    });
    Box.style(&.{
        .position = .{ .type = .fixed, .top = if (Fabric.isMobile()) .percent(8) else .percent(8), .left = .percent(8) },
        .size = .hw(.percent(100), .mobile_desktop_percent(100, 14)),
        .z_index = 999,
    })({
        List.style(&.{
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
                ListItem.style(&.{
                    .size = .hw(.fit, .percent(100)),
                    // .border_radius = .all(4),
                    .visual = .{
                        .background = if (std.mem.eql(u8, current_path, item.link)) .transparentizeHex(.palette(.tint), 0.1) else .transparent,
                        .border = .r(2, if (std.mem.eql(u8, current_path, item.link)) .palette(.tint) else .transparent),
                    },
                    .interactive = .{
                        .hover = .{
                            .background = if (std.mem.eql(u8, current_path, item.link)) .transparentizeHex(.palette(.tint), 0.1) else .palette(.highlight_color),
                        },
                    },
                })({
                    Link(.{ .url = item.link, .aria_label = item.title }).style(&.{
                        .visual = .{ .text_decoration = .none },
                        .size = .w(.percent(100)),
                        .layout = .left_center,
                        .child_gap = 12,
                        .padding = .{ .top = 10, .bottom = 10, .right = 8, .left = 8 },
                        .cursor = .pointer,
                    })({
                        Icon(item.icon).style(&.{
                            .visual = .{ .text_color = if (std.mem.eql(u8, current_path, item.link)) .palette(.tint) else .palette(.text_color) },
                        });
                        Text(item.title).style(&.{
                            .visual = .{
                                .text_color = if (std.mem.eql(u8, current_path, item.link)) .palette(.tint) else .palette(.text_color),
                                .font_size = 14,
                            },
                        });
                    });
                });
            }
        });
    });
    // Search.render();
}

pub fn render() void {
    Box.style(&.{
        .position = .nav,
        .size = .hw(.percent(100), .mobile_desktop_percent(100, 14)),
        .padding = .{ .bottom = 128 },
        .z_index = 999,
    })({
        list();
    });
}
