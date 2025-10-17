const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Dynamic = Fabric.Dynamic;
const Signal = Fabric.Signal;
const println = Fabric.println;
const root = @import("../main.zig");
const Search = @import("Search.zig");
const Kit = Fabric.Kit;
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
const ButtonCycle = Static.ButtonCycle;
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
    //     Fabric.cycle();
    // }
}
const Url = struct {
    url: []const u8,
    title: []const u8,
};
const urls: [5]Url = .{
    .{
        .url = "/docs/fabric",
        .title = "Fabric",
    },
    .{
        .url = "/docs/reverb",
        .title = "Reverb",
    },
    .{
        .url = "/docs/treehouse",
        .title = "Treehouse",
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
        ListItem.style(&Styles.item)({
            Link(.{ .url = url.url, .aria_label = url.title }).style(&.{
                .visual = .{ .text_decoration = .none },
            })({
                Text(url.title).style(&.{ .visual = .font(20, 300, .palette(.text_color)), .font_family = "IBM Plex Mono,monospace" });
            });
        });
    }
}

const Self = @This();
var show_dropdown: Signal(bool) = undefined;

fn showDropDown() void {
    println("SHOW DROPDOWN", .{});
    show_dropdown.set(!show_dropdown.get());
}

fn switchTheme(opt: []const u8) void {
    println("Switch Theme! {s}", .{opt});
    // if (opt[0] == 'D') {
    //     Fabric.Theme.switchTheme(.dark);
    //     return;
    // }
    // Fabric.Theme.switchTheme(.light);
    return;
}

pub fn init() void {
    show_dropdown.init(false);
    Search.init();
}

pub fn closeAll(evt: *Fabric.Event) void {
    evt.preventDefault();
    // show_dropdown.set(false);
}

pub fn setDefault() void {
    show_dropdown.set(false);
}

fn openDialog() void {
    Fabric.println("openDialog", .{});
    Search.toggle();
}

fn navigate(url: []const u8) void {
    Kit.navigate(url);
    menu = !menu;
    Fabric.cycle();
}

fn toggleTheme() void {
    Theme.toggleTheme();
    Fabric.cycle();
}

pub fn render() void {
    if (Fabric.isDesktop()) {
        // Box.id("nav")
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
        // Box.id("nav")
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
        // Box.id("nav")
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
        Box.id("nav").style(&.{
            .position = .nav,
            .size = .hw(.px(60), .grow),
            .layout = .x_between_center,
            .padding = .horizontal(50),
            .z_index = 999,
            .visual = .{ .blur = 2 },
        })({
            Box.style(&.{
                .size = .{ .height = .px(50) },
                .direction = .row,
                .layout = .left_center,
                .child_gap = 10,
            })({
                Link(.{ .url = "/", .aria_label = "home page of tether" }).style(&.{
                    .visual = .{ .text_decoration = .none },
                })({
                    Center.style(&.{
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
                            .visual = .{ .text_color = .palette(.text_color) },
                            .transition = .{ .duration = 100 },
                            .interactive = .{ .hover = .{
                                .text_color = .palette(.tint),
                            } },
                        });
                        // Image(.{ .src = "/assets/logonormal.svg" }).style(&.{
                        //     .size = .{ .width = .percent(100), .height = .percent(100) },
                        //     .visual = .{ .text_color = .hex("#5A27FF") },
                        // });
                    });
                });
                List.style(&.{
                    .child_gap = 60,
                    .layout = .center,
                    .size = .hw(.percent(100), .percent(100)),
                })({
                    routes();
                });
            });

            Center.style(&.{
                .child_gap = 24,
                .size = .w(.percent(30)),
            })({
                ButtonCycle(.{ .on_press = openDialog, .aria_label = "search-dialog" }).style(&.{
                    .layout = .x_between_center,
                    .size = .hw(.px(38), .percent(70)),
                    .padding = .tblr(4, 4, 8, 8),
                    .visual = .{ .border = .simple(.hex("#E1E1E1")), .cursor = .pointer, .background = .palette(.background) },
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
                RedirectLink(.{ .url = "https://github.com/vic-Rokx/fabric", .aria_label = "redirect link to tether github repo" }).style(&.{
                    .visual = .{ .text_decoration = .none },
                })({
                    Icon(.github).style(&.{
                        .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                        .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
                    });
                });
                RedirectLink(.{ .url = "https://github.com/vic-Rokx/fabric", .aria_label = "redirect link to discord" }).style(&.{
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
                    Graphic(.{ .src = "src/assets/zig_simple.svg" }).style(&.{
                        .size = .{ .height = .px(24), .width = .px(24) },
                        .visual = .{ .fill = .palette(.icon_color) },
                        .interactive = .{ .hover = .{ .fill = .palette(.tint) } },
                    });
                    // Icon("bi bi-discord").style(&.{
                    //     .visual = .{ .font_size = 24, .text_color = .palette(.icon_color) },
                    //     .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
                    // });
                });
                Button(.{ .on_press = toggleTheme }).style(&.{
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
    } else {
        Box.style(&.{
            .layout = .x_between_center,
            .child_gap = 8,
            .padding = .horizontal(16),
            .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
            .size = .hw(.px(80), .percent(100)),
            .visual = .bg(.palette(.background)),
            .z_index = 999,
        })({
            Box.style(&.{ .layout = .left_center })({
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
            Box.style(&.{ .layout = .right_center })({
                ButtonCycle(.{ .on_press = openMenu }).style(&.{
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

                ButtonCycle(.{ .on_press = openMenu }).style(&.{
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
            Box.style(&.{
                .position = .{ .type = .fixed, .top = .px(80), .left = .px(0) },
                .size = .w(.percent(100)),
                .z_index = 999,
                // .visual = .{ .background = Theme.background, .border = .tb(.hex("#E4E4E4")) },
            })({
                List.style(&.{
                    .list_style = .none,
                    .direction = .column,
                    .padding = .tblr(16, 16, 8, 8),
                    .child_gap = 16,
                    .size = .w(.percent(100)),
                })({
                    for (urls) |item| {
                        ListItem.style(&.{
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
    // Search.render();
    // });
}

const Styles = struct {
    pub const item = Fabric.Style{
        .list_style = .none,
        .size = .{ .width = .elastic(50, 130), .height = .px(30) },
        .layout = .{ .y = .center, .x = .start },
        .visual = .{ .border = .bottom(.transparent) },
        // .border_color = if (std.mem.eql(u8, current_path, url.url)) text_color else .transparent,
        .interactive = .{
            .hover = .{
                .border_color = .palette(.text_color),
                .border_thickness = .{ .bottom = 1, .top = 0, .left = 0, .right = 0 },
            },
        },
    };
};
