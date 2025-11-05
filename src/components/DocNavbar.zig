const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Types = Vapor.Types;
const Dynamic = Vapor.Dynamic;
const Element = Vapor.Element;
// const Sheet = @import("Sheet.zig").Sheet;
const Signal = Vapor.Signal;
const Kit = Vapor.Kit;
const println = Vapor.println;
const logo = @embedFile("logo.svg");
const Binded = Vapor.Binded;
const Search = @import("Search.zig");
const Center = Static.Center;
const Box = Static.Box;
const Image = Static.Image;
const Text = Static.Text;
const Page = Vapor.Page;
const Pure = Vapor.Pure;
const Graphic = Static.Graphic;
const Icon = Static.Icon;
const Button = Static.Button;
const ButtonCycle = Static.ButtonCycle;
const Link = Static.Link;
const List = Static.List;
const CtxButton = Static.CtxButton;
const ListItem = Static.ListItem;
const RedirectLink = Static.RedirectLink;
const Theme = @import("theme");
const IconTokens = @import("user_config").IconTokens;
const Hooks = Static.Hooks;
const Observer = Vapor.Kit.Observer;
const Stack = Static.Stack;
const Content = @import("../components/Content.zig");

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
    sections: []const *const struct { title: []const u8, link: []const u8 } = &.{},
    link: []const u8,
    icon: *const IconTokens,
    tags: []const Tag = &.{},
};

pub const menu_items: []const MenuItem = &.{
    MenuItem{
        .id = "overview",
        .title = "Overview",
        .link = "/docs/vapor",
        .sections = &.{
            &.{ .title = "What is Vapor?", .link = "what-is-vapor" },
            &.{ .title = "Vapor is simple", .link = "vapor-is-simple" },
            &.{ .title = "Making a button", .link = "making-a-button" },
            &.{ .title = "A glimpse under the hood", .link = "a-glimpse-under-the-hood" },
            &.{ .title = "UI Node", .link = "ui-node" },
        },
        .icon = .house, // Keep as is - perfect for home
        .tags = &.{
            Tag{
                .keywords = &.{ "vapor home", "vapor", "docs", "home" },
                .sub_title = "Vapor Docs",
                .url = "/docs/vapor",
                .description = "Vapor documentation...",
            },
        },
    },
    MenuItem{
        .id = "just-let-me-build",
        .title = "Just let me build!!!!",
        .link = "/docs/vapor/concepts/justletmebuild",
        .icon = .fire, // Keep as is - perfect for home
        .tags = &.{
            Tag{
                .keywords = &.{ "started", "installation", "vapor", "immediate", "create app", "vapor create app" },
                .sub_title = "Create an App",
                .url = "/docs/vapor/concepts/justletmebuild/#create-command",
                .description = "Use vapor to create and run an applic...",
            },
        },
    },
    MenuItem{
        .id = "basics",
        .title = "Basics",
        .link = "/docs/vapor/concepts/basics",
        .sections = &.{
            &.{ .title = "Basics", .link = "basics" },
            &.{ .title = "CSR VS SSR", .link = "csr-vs-ssr" }, // TODO
            &.{ .title = "Creating a Vapor App", .link = "creating-a-vapor-app" },
            &.{ .title = "Core Functions", .link = "core-functions" },
            &.{ .title = "Instantiate", .link = "instantiate" },
            &.{ .title = "RenderUI", .link = "renderUI" },
            &.{ .title = "export", .link = "export" },
            &.{ .title = "Virtual Dom & Reconciliation", .link = "virtual-dom-and-reconciliation" },
            &.{ .title = "Performance", .link = "performance" },
            &.{ .title = "Structuring your application", .link = "structuring-your-application" },
            &.{ .title = "Global Components", .link = "global-components" },
            &.{ .title = "Instance Components", .link = "instance-components" },
            &.{ .title = "Its just Zig", .link = "its-just-zig" },
        },
        .icon = .mortarboard, // Graduation cap for learning basics
        .tags = &.{
            Tag{
                .keywords = &.{ "basics", "learning", "vapor", "docs", "reconciler", "rendering" },
                .sub_title = "Vapor Basics",
                .url = "/docs/vapor/concepts/basics/#introduction",
                .description = "Introduction to Vapor, and how to use it...",
            },
            Tag{
                .keywords = &.{ "reconciler", "rendering", "rerender" },
                .sub_title = "How rendering works",
                .url = "/docs/vapor/concepts/basics/#reconciler",
                .description = "How the reconciler and rendering of vapor wor...",
            },
        },
    },
    MenuItem{
        .id = "project-structure",
        .title = "Project Structure",
        .link = "/docs/vapor/concepts/project",
        .sections = &.{
            &.{ .title = "Project Structure", .link = "project-structure" },
        },
        .icon = .diagram_3,
        .tags = &.{
            Tag{
                .keywords = &.{"routing"},
                .sub_title = "Routes Directory",
                .url = "/docs/vapor/concepts/project/#routes-directory",
                .description = "Routes Directory...",
            },
            Tag{
                .keywords = &.{"web"},
                .sub_title = "Web Directory",
                .url = "/docs/vapor/concepts/project/#web-directory",
                .description = "Web Directory...",
            },
        },
    },
    MenuItem{
        .id = "routing",
        .title = "Routing",
        .link = "/docs/vapor/concepts/routing",
        .sections = &.{
            &.{ .title = "Routing", .link = "routing" },
            &.{ .title = "Page()", .link = "page-sample" },
        },
        .icon = .signpost, // Signpost for navigation/routing
        .tags = &.{
            Tag{
                .keywords = &.{ "dynamic", "routes", "dynamic routes" },
                .sub_title = "Dynamci Routes",
                .url = "/docs/vapor/concepts/routing/#dynamic-routes",
                .description = "Dynamic Routes...",
            },
        },
    },
    MenuItem{
        .id = "reactivity",
        .title = "Reactivity",
        .link = "/docs/vapor/concepts/reactivity",
        .sections = &.{
            &.{ .title = "Reactivity", .link = "reactivity" },
            &.{ .title = "Signal Types", .link = "signal-types" },
            &.{ .title = "UI as reactivity", .link = "ui-as-reactivity" },
            &.{ .title = "Immediate Mode", .link = "immediate-mode" },
            &.{ .title = "80% of content in an application is static", .link = "80-content-is-static" },
            &.{ .title = "Retained Mode", .link = "retained-mode" },
            &.{ .title = "Using cycle()", .link = "using-cycle" },
            &.{ .title = "Zig is meant to be Explicit!", .link = "zig-is-meant-to-be-explicit" },
            &.{ .title = "Signal(T)", .link = "signalT" },
            &.{ .title = "Effects", .link = "effects" },
            &.{ .title = "With the concept of effects", .link = "with-the-concept-of-effects" },
            &.{ .title = "Without the concept of effects", .link = "without-the-concept-of-effects" },
            &.{ .title = "Its just Zig", .link = "its-just-zig" },
        },
        .icon = .arrow_repeat, // Circular arrows for reactive updates
        .tags = &.{
            Tag{
                .keywords = &.{ "ui to code", "ui reactivity" },
                .sub_title = "UI to Code",
                .url = "/docs/vapor/concepts/reactivity/#ui-to-code",
                .description = "Going from UI to Code...",
            },
        },
    },
    MenuItem{
        .id = "layout",
        .title = "Layout",
        .link = "/docs/vapor/concepts/layout",
        .icon = .columns, // Circular arrows for reactive updates
        .sections = &.{
            &.{ .title = "Layouts", .link = "layouts" },
            &.{ .title = "Register Layouts", .link = "register-layout" },
        },
        .tags = &.{
            Tag{
                .keywords = &.{ "layout", "defaults", "spacing", "overlay" },
                .sub_title = "Introduction",
                .url = "/docs/vapor/concepts/layout/#introduction",
                .description = "How to use layouts...",
            },
        },
    },
    MenuItem{
        .id = "styling",
        .title = "Styling",
        .link = "/docs/vapor/concepts/styling",
        .sections = &.{
            &.{ .title = "Styling", .link = "styling" },
            &.{ .title = "Quick little rant", .link = "quick-little-rant" },
            &.{ .title = "End of little rant", .link = "end-of-little-rant" },
            &.{ .title = "New Approach", .link = "new-approach" },
            &.{ .title = "Layout", .link = "layout" },
            &.{ .title = "Two types of styling", .link = "two-types-of-styling" },
            &.{ .title = "Builder functions", .link = "builder-functions" },
            &.{ .title = "Builder patterns", .link = "builder-patterns" },
            &.{ .title = "Style", .link = "style-struct" },
            &.{ .title = "Taking it further", .link = "taking-it-even-further" },
            &.{ .title = "Structs powerful!", .link = "structs-are-insanely-powerful" },
            &.{ .title = "Code Block", .link = "code-block" },
        },
        .icon = .paint_bucket, // Circular arrows for reactive updates
    },
    MenuItem{
        .id = "kit",
        .title = "Kit",
        .link = "/docs/vapor/concepts/kit",
        .icon = .tools, // Tools icon for toolkit/kit
        .sections = &.{
            &.{ .title = "Kit", .link = "kit" },
            &.{ .title = "Why Callbacks again?", .link = "why-callbacks" },
            &.{ .title = "Example", .link = "example" },
            &.{ .title = "fetch", .link = "fetch" },
            &.{ .title = "fetchCtx", .link = "fetchCtx" },
            &.{ .title = "navigate", .link = "navigate" },
            &.{ .title = "routePush", .link = "routePush" },
            &.{ .title = "getWindowPath", .link = "getWindowPath" },
            &.{ .title = "getWindowParams", .link = "getWindowParams" },
            &.{ .title = "persist", .link = "persist" },
            &.{ .title = "getPersist", .link = "getPersist" },
        },
    },
    MenuItem{
        .id = "events-and-handlers",
        .title = "Events & Handlers",
        .link = "/docs/vapor/concepts/events",
        .icon = .cursor,
        .sections = &.{
            &.{ .title = "Events and Handlers", .link = "events-and-handlers" },
            &.{ .title = "Basic event listener", .link = "basic-event-listener" },
            &.{ .title = "Binded event listener", .link = "binded-event-listener" },
            &.{ .title = "Type safety", .link = "type-safety" },
            &.{ .title = "Field saftey", .link = "field-saftey" },
        },
    },
    MenuItem{
        .id = "lifecycle-hooks",
        .title = "Lifecycle Hooks",
        .link = "/docs/vapor/concepts/hooks",
        .sections = &.{
            &.{ .title = "Hooks", .link = "hooks-overview" },
            &.{ .title = "Router Hooks", .link = "router-hooks" },
            &.{ .title = "Hook Context", .link = "hook-context" },
            &.{ .title = "Register Hooks", .link = "register-hook" },
            &.{ .title = "Lifecycle Hooks", .link = "lifecycle-hooks" },
            &.{ .title = "Component Hooks", .link = "component-hooks" },
            &.{ .title = "Tree Hooks", .link = "tree-hooks" },
            &.{ .title = "OnEnd", .link = "onend" },
            &.{ .title = "OnCommit", .link = "oncommit" },
        },
        .icon = .hourglass_split,
    },
    // MenuItem{
    //     .id = "js-libs",
    //     .title = "JS Libs",
    //     .link = "/docs/vapor/concepts/jslibs",
    //     .icon = .filetype_js, // Tools icon for toolkit/kit
    // },
    // MenuItem{
    //     .id = "wasm-bridge",
    //     .title = "WASM Bridge",
    //     .link = "/docs/vapor/concepts/bridge",
    //     .icon = .ethernet,
    // },
    MenuItem{
        .id = "performance",
        .title = "Performance",
        .link = "/docs/vapor/concepts/performance",
        .icon = .ethernet,
        .tags = &.{
            Tag{
                .keywords = &.{ "performance", "auth", "authentication", "login", "signup", "registration", "login", "signup", "registration" },
                .sub_title = "Performance is the Auth system",
                .url = "/docs/vapor/concepts/reactivity/#sign-up",
                .description = "How to sign up and login with Oauth...",
            },
        },
    },
    // MenuItem{
    //     .id = "csr-vs-ssr",
    //     .title = "CSR vs SSR",
    //     .link = "/docs/vapor/concepts/csr_vs_ssr",
    //     .icon = .filetype_js, // Tools icon for toolkit/kit
    //     .sections = &.{
    //         &.{ .title = "CSR vs SSR", .link = "csr-vs-ssr" },
    //         &.{ .title = "Architecture", .link = "architecture" },
    //         &.{ .title = "Better Way", .link = "better-way" },
    //         &.{ .title = "WASM Framework", .link = "wasm-framework" },
    //         &.{ .title = "Example", .link = "example" },
    //         &.{ .title = "SEO", .link = "seo" },
    //         &.{ .title = "Real-Time Data", .link = "real-time-data" },
    //         &.{ .title = "Synchronization Problem", .link = "synchronization-problem" },
    //     },
    // },
    MenuItem{
        .id = "tutorials",
        .title = "Tutorials",
        .link = "/docs/vapor/concepts/tutorials",
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

var current_menu_item: ?MenuItem = null;
var current_section: []const u8 = "";
var sections: std.StringArrayHashMap(void) = undefined;
pub var section_indices: std.AutoHashMap(usize, void) = undefined;
pub fn init() void {
    sections = std.StringArrayHashMap(void).init(Vapor.lib.frame_arena.persistentAllocator());
    section_indices = std.AutoHashMap(usize, void).init(Vapor.lib.frame_arena.persistentAllocator());
}

fn openDialog() void {
    Search.toggle();
}

fn toggleTheme() void {
    Theme.toggleTheme();
    // Vapor.cycle();
}

fn goto(url: []const u8) void {
    sections.clearRetainingCapacity();
    Vapor.onEnd(reinitObserver); // This will triger at the end of the current cycle
    for (menu_items) |item| {
        if (std.mem.eql(u8, url, item.link)) {
            current_menu_item = item;
        }
    }
    Vapor.Kit.navigate(url);
    Kit.scrollTo(0, 0);
}

fn handleSection(target: Observer.Target) void {
    if (target.is_in_view) {
        sections.put(target.url, {}) catch unreachable;
        Content.boxes[target.index].active = true;
    } else {
        const yes = sections.swapRemove(target.url);
        if (yes) {
            Content.boxes[target.index].active = false;
        }
    }
    Vapor.cycle();
}

pub fn reinitObserver() void {
    Content.deinitBoxes();
    _ = Observer.reinit("menu-bar");
    Content.initBoxes(); // This creates the boxes after the page is mounted
}
var mounted: bool = false;
fn mount() void {
    const current_path = Vapor.Kit.getWindowPath();
    _ = Observer.new("menu-bar", handleSection, .{
        .threshold = 0.4,
    });
    if (!mounted) {
        current_menu_item = null;
        for (menu_items) |item| {
            if (std.mem.eql(u8, current_path, item.link)) {
                current_menu_item = item;
                break;
            }
        }
    }

    // Vapor.registerCtxTimeout(300, createBoxes, .{{}});
    Content.initBoxes(); // This creates the boxes after the page is mounted
    mounted = true;
    // Vapor.cycle();
}

fn list() void {
    const current_path = Vapor.Kit.getWindowPath();

    if (!mounted) {
        current_menu_item = null;
        for (menu_items) |item| {
            if (std.mem.eql(u8, current_path, item.link)) {
                current_menu_item = item;
                break;
            }
        }
    }

    Hooks(.{ .mounted = mount })({
        Box.style(&.{
            .layout = .x_between_center,
            .child_gap = 8,
            .padding = .{ .top = 8, .bottom = 8, .left = 12, .right = 12 },
            .position = .{ .type = .fixed, .top = .px(0), .left = .percent(8), .right = .percent(0), .z_index = 400 },
            .size = .hw(.mobile_desktop_percent(8, 6), .percent(100 - 8)),
            .visual = .{
                .blur = 3,
            },
        })({
            Box.style(&.{
                .layout = .x_between_center,
                .child_gap = 8,
                .size = .h(.percent(100)),
            })({
                Link(.{ .url = "/", .aria_label = "home page of tether" }).style(&.{
                    .visual = .{ .text_decoration = .none, .cursor = .pointer },
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
            if (!Vapor.isMobile()) {
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
                    .visual = .{ .border = .simple(.hex("#E1E1E1")), .background = .transparent, .cursor = .pointer },
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
                    Button(.{ .on_press = toggleTheme, .aria_label = "toggle theme" }).style(&.{
                        .visual = .{ .background = .transparent, .cursor = .pointer },
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
            .position = .{ .type = .fixed, .top = if (Vapor.isMobile()) .percent(8) else .percent(8), .left = .percent(8), .z_index = 999 },
            .size = .hw(.percent(100), .mobile_desktop_percent(100, 14)),
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
                            .border = .r(1, if (std.mem.eql(u8, current_path, item.link)) .palette(.tint) else .transparent),
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
                            Icon(item.icon).style(&.{
                                .visual = .{ .text_color = if (std.mem.eql(u8, current_path, item.link)) .palette(.tint) else .palette(.text_color) },
                            });
                            Text(item.title).style(&.{
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
        Stack.style(&.{
            .position = .{ .type = .fixed, .top = if (Vapor.isMobile()) .percent(8) else .percent(8), .right = .percent(2), .z_index = 999 },
            .size = .hw(.percent(100), .mobile_desktop_percent(100, 14)),
        })({
            Box.style(&.{
                .layout = .left_center,
                .child_gap = 8,
            })({
                Icon(.list_task).font(20, 500, .palette(.text_color)).close();
                Text("On this page").font(16, 500, .palette(.text_color)).close();
            });
            List.style(&.{
                .list_style = .none,
                .direction = .column,
                .padding = .{ .top = 16, .bottom = 64, .right = 0, .left = 0 },
                .child_gap = 8,
                .size = .hw(.percent(95), .percent(100)),
                .scroll = .scroll_y(),
                .show_scrollbar = false,
                .layout = .{},
            })({
                if (current_menu_item) |current| {
                    for (current.sections) |section| {
                        const url = Vapor.fmtln("#{s}", .{section.link});
                        const title = section.title;
                        const color: Vapor.Types.Color = if (sections.get(section.link) != null) .palette(.tint) else .transparent;
                        const text_color: Vapor.Types.Color = if (sections.get(section.link) != null) .palette(.tint) else .palette(.text_color);
                        ListItem.style(&.{
                            .size = .hw(.fit, .percent(100)),
                        })({
                            Link(.{ .url = url, .aria_label = title }).style(&.{
                                .visual = .{
                                    .text_decoration = .none,
                                    .cursor = .pointer,
                                    .border = .l(2, color),
                                },
                                .padding = .l(6),
                                .size = .w(.percent(100)),
                                .layout = .left_center,
                            })({
                                Text(title).style(&.{
                                    .visual = .{
                                        .text_color = text_color,
                                        .font_size = 14,
                                    },
                                });
                            });
                        });
                    }
                }
            });
        });
    });
    // Search.render();
}

pub fn render() void {
    Box.style(&.{
        .position = .nav,
        .size = .hw(.percent(100), .mobile_desktop_percent(100, 14)),
        .padding = .{ .bottom = 128 },
    })({
        list();
    });
}
