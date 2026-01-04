const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const println = Vapor.println;
const root = @import("../main.zig");
const Search = @import("Search.zig");
const Kit = Vapor.Kit;
const Text = Static.Text;
const Box = Static.Box;
const Link = Static.Link;
const Stack = Static.Stack;
const Image = Static.Image;
const Svg = Static.Svg;
const Center = Static.Center;
const Icon = Static.Icon;
const List = Static.List;
const ListItem = Static.ListItem;
const CtxButton = Static.CtxButton;
const RedirectLink = Static.RedirectLink;
const Button = Static.Button;
const Theme = @import("theme");
const Graphic = Static.Graphic;

var last_time: i64 = 0;
pub fn throttle() bool {
    const current_time = std.time.milliTimestamp();
    if (current_time - last_time < 60) {
        return true;
    }
    last_time = current_time;
    return false;
}

var menu: bool = false;
fn openMenu() void {
    // if (!throttle()) {
    menu = !menu;
    //     Vapor.cycle();
    // }
}
const Url = struct {
    url: []const u8,
    title: []const u8,
};
const urls: [5]Url = .{
    .{
        .url = "/docs/vapor",
        .title = "[0] = Vapor",
    },
    .{
        .url = "/docs/reverb",
        .title = "[1] = Reverb",
    },
    .{
        .url = "/docs/treehouse",
        .title = "[2] = Canopy",
    },
    .{
        .url = "/docs/metal",
        .title = "Metal",
    },
    .{
        .url = "/about",
        .title = "About Me",
    },
};

inline fn routes() void {
    // const current_path = Kit.getWindowPath();
    for (urls) |url| {
        ListItem().style(&Styles.item)({
            Link(.{ .url = url.url, .aria_label = url.title }).style(&.{
                .visual = .{ .text_decoration = .none },
            })({
                Text(url.title).style(&.{ .visual = .font(20, 300, .palette(.text_color)), .font_family = "IBM Plex Mono,monospace" });
            });
        });
    }
}

const Self = @This();

fn switchTheme(opt: []const u8) void {
    println("Switch Theme! {s}", .{opt});
    // if (opt[0] == 'D') {
    //     Vapor.Theme.switchTheme(.dark);
    //     return;
    // }
    // Vapor.Theme.switchTheme(.light);
    return;
}

pub fn init() void {
    Search.init();
}

pub fn closeAll(evt: *Vapor.Event) void {
    evt.preventDefault();
}

pub fn setDefault() void {
}

fn openDialog() void {
    Search.toggle();
}

fn navigate(url: []const u8) void {
    Kit.navigate(url);
    menu = !menu;
    // Vapor.cycle();
}

fn toggleTheme() void {
    Theme.toggleTheme();
    // Vapor.cycle();
}

pub fn render() void {
    if (Vapor.isDesktop()) {
        // Box().id("nav")
        //     .baseStyle(&.{
        //         .size = .hw(.px(60), .grow),
        //         .layout = .x_between_center,
        //         .padding = .horizontal(50),
        //         .blur = 2,
        //         .z_index = 999,
        //     })
        //     .pos(.nav)
        //     .body()({
        //     Text("hello").plain();
        // });
        //
        // Box().id("nav")
        //     .pos(.nav)
        //     .height(.px(60))
        //     .width(.grow)
        //     .layout(.x_between_center)
        //     .padding(.horizontal(50))
        //     .blur(2)
        //     .zIndex(999)
        //     .body()({
        //     Text("hello").plain();
        // });
        //
        // Box().id("nav")
        //     .style(&.{
        //     .position = .nav,
        //     .size = .hw(.px(60), .grow),
        //     .layout = .x_between_center,
        //     .padding = .horizontal(50),
        //     .blur = 2,
        //     .z_index = 999,
        // })({
        //     Text("hello").plain();
        // });
        Box().id("nav").style(&.{
            .position = .nav,
            .size = .hw(.px(60), .grow),
            .layout = .x_between_center,
            .padding = .horizontal(50),
            .visual = .{ .blur = 2 },
        })({
            Box().style(&.{
                .size = .{ .height = .px(50) },
                .direction = .row,
                .layout = .left_center,
                .child_gap = 10,
            })({
                Link(.{ .url = "/", .aria_label = "home page of tether" }).style(&.{
                    .visual = .{ .text_decoration = .none },
                })({
                    Center().style(&.{
                        .size = .{ .width = .px(45) },
                        .margin = .{ .right = 30 },
                        .transition = .{ .duration = 100 },
                        .interactive = .{ .hover = .{ .transform = .scale() } },
                        .visual = .{ .text_color = .palette(.text_color) },
                    })({
                        // Svg(.{ .svg = @embedFile("../assets/logonormal.svg") }).style(&.{
                        //     .size = .{ .width = .percent(100), .height = .percent(100) },
                        //     .visual = .{ .text_color = .palette(.text_color) },
                        //     .transition = .{ .duration = 100 },
                        //     .interactive = .{ .hover = .{
                        //         .text_color = .palette(.tint),
                        //     } },
                        // });
                        Graphic(.{ .src = "/src/assets/logonormal.svg" }).style(&.{
                            .size = .{ .width = .percent(100), .height = .percent(100) },
                            .visual = .{ .fill = .palette(.text_color), .stroke = .palette(.text_color) },
                            .transition = .{ .duration = 100 },
                            .interactive = .{ .hover = .{
                                .fill = .palette(.tint),
                                .stroke = .palette(.tint),
                            } },
                        });
                        // Image(.{ .src = "/assets/logonormal.svg" }).style(&.{
                        //     .size = .{ .width = .percent(100), .height = .percent(100) },
                        //     .visual = .{ .text_color = .hex("#5A27FF") },
                        // });
                    });
                });
                List().style(&.{
                    .child_gap = 60,
                    .layout = .center,
                    .size = .hw(.percent(100), .percent(100)),
                })({
                    routes();
                });
            });

            Center().style(&.{
                .child_gap = 24,
                .size = .w(.percent(30)),
            })({
                Button(.{ .on_press = openDialog, .aria_label = "search-dialog" }).style(&.{
                    .layout = .x_between_center,
                    .size = .hw(.px(38), .percent(70)),
                    .padding = .tblr(4, 4, 8, 8),
                    .visual = .{ .border = .simple(.hex("#E1E1E1")), .cursor = .pointer, .background = .palette(.background) },
                    .interactive = .{ .hover = .{
                        .border = .simple(.palette(.tint)),
                    } },
                })({
                    Box().style(&.{ .layout = .left_center, .child_gap = 24 })({
                        Icon(.search).style(&.{
                            .visual = .{ .font_size = 16, .text_color = .palette(.icon_color) },
                        });
                        Text("Search...").style(&.{
                            .visual = .font(16, 500, .palette(.icon_color)),
                            .font_family = "IBM Plex Mono,monospace",
                        });
                    });
                    Icon(.command).style(&.{
                        .visual = .{ .font_size = 16, .text_color = .palette(.icon_color) },
                    });
                });
                RedirectLink(.{ .url = "https://github.com/vic-Rokx/vapor", .aria_label = "redirect link to tether github repo" }).style(&.{
                    .visual = .{ .text_decoration = .none },
                })({
                    Icon(.github).style(&.{
                        .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                        .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
                    });
                });
                RedirectLink(.{ .url = "https://github.com/vic-Rokx/vapor", .aria_label = "redirect link to discord" }).style(&.{
                    .visual = .{ .text_decoration = .none },
                })({
                    Icon(.discord).style(&.{
                        .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                        .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
                    });
                });
                RedirectLink(.{ .url = "https://ziglang.org/", .aria_label = "redirect link to ziglang" }).style(&.{
                    .visual = .{ .text_decoration = .none },
                })({
                    Graphic(.{ .src = "/src/assets/zig_simple.svg" }).style(&.{
                        .size = .{ .height = .px(24), .width = .px(24) },
                        .visual = .{ .fill = .palette(.icon_color) },
                        .interactive = .{ .hover = .{ .fill = .palette(.tint) } },
                    });
                    // Icon("bi bi-discord").style(&.{
                    //     .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                    //     .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
                    // });
                });
                Button(.{ .on_press = toggleTheme, .aria_label = "toggle theme" }).style(&.{
                    .visual = .{
                        .background = .transparent,
                        .cursor = .pointer,
                    },
                    .padding = .all(0),
                    .margin = .all(0),
                })({
                    Icon(.cloud_moon).style(&.{
                        .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                        .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
                    });
                });
            });
        });
        Search.render();
    } else {
        Box().style(&.{
            .layout = .x_between_center,
            .child_gap = 8,
            .padding = .horizontal(16),
            .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0), .z_index = 999 },
            .size = .hw(.px(80), .percent(100)),
            .visual = .{
                .background = .palette(.background),
            },
        })({
            Box().style(&.{ .layout = .left_center })({
                Link(.{ .url = "/", .aria_label = "home page of tether" }).style(&.{
                    .visual = .{ .text_decoration = .none },
                    .size = .h(.px(48)),
                    .layout = .center,
                })({
                    Image(.{ .src = "/assets/circlelogo.webp" }).style(&.{
                        .size = .w(.px(48)),
                    });
                });
            });
            Box().style(&.{ .layout = .right_center })({
                Button(.{ .on_press = openMenu }).style(&.{
                    .size = .hw(.px(36), .px(48)),
                    .visual = .bg(.palette(.background)),
                })({
                    Icon(.search).style(&.{
                        .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                        .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
                    });
                });

                Button(.{ .on_press = toggleTheme }).style(&.{
                    .visual = .{ .cursor = .pointer, .background = .palette(.background) },
                    .size = .hw(.px(36), .px(48)),
                })({
                    Icon(.cloud_moon).style(&.{
                        .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                    });
                });

                Button(.{ .on_press = openMenu }).style(&.{
                    .size = .hw(.px(36), .px(48)),
                    .visual = .bg(.palette(.background)),
                })({
                    if (menu) {
                        Icon(.x_lg).style(&.{
                            .id = "close-menu",
                            .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                        });
                    } else {
                        Icon(.list).style(&.{
                            .id = "open-menu",
                            .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                        });
                    }
                });
            });
        });
        if (menu) {
            Box().style(&.{
                .position = .{ .type = .fixed, .top = .px(80), .left = .px(0), .z_index = 999 },
                .size = .w(.percent(100)),
                // .visual = .{ .background = Theme.background, .border = .tb(.hex("#E4E4E4")) },
            })({
                List().style(&.{
                    .list_style = .none,
                    .direction = .column,
                    .padding = .tblr(16, 16, 8, 8),
                    .child_gap = 16,
                    .size = .w(.percent(100)),
                })({
                    for (urls) |item| {
                        ListItem().style(&.{
                            .size = .w(.percent(70)),
                        })({
                            CtxButton(navigate, .{item.url}).style(&.{
                                .size = .w(.percent(100)),
                                .layout = .left_center,
                                .child_gap = 12,
                                .padding = .tblr(10, 10, 8, 8),
                                .visual = .{ .cursor = .pointer, .background = .white },
                            })({
                                Text(item.title).style(&.{
                                    .font_family = "Montserrat",
                                    .visual = .font(18, 300, .hex("#262626")),
                                });
                            });
                        });
                    }
                });
            });
        }
    }
    // List.body()({});
    // Static.Hooks(.{ .mounted = mount }).body()({});
    // Static.List.body()({});
    // });
}

fn mount() void {
    // _ = background.addListener(.click, closeEvent);
    // _ = search_box.addListener(.input, search);
    // _ = search_box.focus();
}

const Styles = struct {
    pub const item = Vapor.Style{
        .list_style = .none,
        .size = .{ .width = .auto, .height = .px(30) },
        .layout = .{ .y = .center, .x = .start },
        .visual = .{ .border = .bottom(.transparent) },
        // .transition = .{ .duration = 100 },
        // .border_color = if (std.mem.eql(u8, current_path, url.url)) text_color else .transparent,
        .interactive = .{
            .hover = .{
                .border = .bottom(.palette(.text_color)),
            },
        },
    };
};
