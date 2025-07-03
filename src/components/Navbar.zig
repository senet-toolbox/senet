const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Dynamic = Fabric.Dynamic;
const Signal = Fabric.Signal;
const println = Fabric.println;
const root = @import("../main.zig");
const Search = @import("Search.zig");

var theme_background: Fabric.Types.Background = undefined;
var text_color: Fabric.Types.Background = undefined;
var tint: Fabric.Types.Background = undefined;

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
    if (!throttle()) {
        menu = !menu;
        Fabric.cycle();
    }
}
const Url = struct {
    url: []const u8,
    title: []const u8,
};
const urls: [4]Url = .{
    .{
        .url = "/docs/fabric",
        .title = "Fabric",
    },
    .{
        .url = "/docs/tether",
        .title = "Tether",
    },
    .{
        .url = "/docs/treehouse",
        .title = "Treehouse",
    },
    .{
        .url = "/about",
        .title = "About Me",
    },
};
fn routes() void {
    for (urls) |url| {
        Static.ListItem(.{
            // .style_id = "dropdown",
            .list_style = .none,
            .width = .elastic(50, 130),
            .height = .px(30),
            .display = .Flex,
            .child_alignment = .{ .y = .center, .x = .start },
            .border_thickness = .{ .bottom = 1, .top = 0, .left = 0, .right = 0 },
            .hover = .{
                .border_color = text_color,
                .border_thickness = .{ .bottom = 1, .top = 0, .left = 0, .right = 0 },
                // .display = .Flex,
            },
        })({
            Static.Link(.{ .url = url.url, .aria_label = url.title }, .{
                .text_decoration = .none,
            })({
                Static.Text(url.title, .{
                    .font_size = 20,
                    .text_color = text_color,
                });
            });
        });
    }
    Static.Block(.{
        .style_id = "dropdown",
        .width = .px(300),
        .height = .px(300),
        .display = .Flex,
    })({});
}

const Self = @This();
var allocator = std.heap.page_allocator;
var show_dropdown: Signal(bool) = undefined;

const ThemeOption = struct {
    name: []const u8,
    icon: []const u8,
};
const theme_options: []const ThemeOption = &.{
    .{
        .name = "Light",
        .icon = "bi bi-brightness-low-fill",
    },
    .{
        .name = "Dark",
        .icon = "bi bi-moon-stars-fill",
    },
};

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
    // Fabric.eventListener(.click, closeAll);
    show_dropdown.init(false);
    Search.init();
}
// fn activeTheme(theme: Theme) [4]f32 {
//     if (Fabric.Theme.theme == theme) {
//         return tint;
//     }
//     return .{ 0, 0, 0, 0 };
// }
// fn dropdownTextColor(theme: Theme) [4]f32 {
//     if (Fabric.Theme.theme == theme) {
//         return .{ 0, 0, 0, 255 };
//     }
//     return text_color;
// }

pub fn closeAll(evt: *Fabric.Event) void {
    evt.preventDefault();
    // show_dropdown.set(false);
}

pub fn setDefault() void {
    show_dropdown.set(false);
}

fn openDialog() void {
    Search.toggle();
}

pub fn render() void {
    text_color = Fabric.Types.Background.hex("#262626");
    tint = Fabric.Types.Background.hex("#6338FF");
    Fabric.Layout(.{
        .file = "/routes/",
        .module = "",
        .column = 0,
        .fn_name = "",
        .line = 0,
    }, .{})({
        Search.render();
        if (!Fabric.isMobile()) {
            Static.FlexBox(.{
                .position = .{
                    .type = .fixed,
                    .right = .px(0),
                    .left = .px(0),
                },
                .display = .Flex,
                .width = .grow,
                .height = .px(60),
                .direction = .row,
                .child_alignment = .{ .x = .between, .y = .center },
                .padding = .{
                    .left = 50,
                    .right = 50,
                },
                .blur = 1,
            })({
                Static.FlexBox(.{
                    .height = .px(50),
                    .direction = .row,
                    .child_alignment = .start_center,
                    .child_gap = 10,
                })({
                    Static.Link(.{ .url = "/", .aria_label = "home page of tether" }, .{
                        .text_decoration = .none,
                    })({
                        Static.Center(.{
                            .width = .px(45),
                            .margin = .{ .right = 30 },
                        })({
                            Static.Image("/assets/logonormal.svg", .{
                                .width = .percent(100),
                                .height = .percent(100),
                                .text_color = text_color,
                            });
                        });
                    });
                    Static.List(.{
                        .child_gap = 60,
                        .display = .Flex,
                        .child_alignment = .center,
                    })({
                        routes();
                    });
                });

                Static.Center(.{
                    .child_gap = 24,
                    .width = .percent(30),
                })({
                    Static.Button(.{ .onPress = openDialog, .aria_label = "search-dialog" }, .{
                        .display = .Flex,
                        .child_alignment = .{ .x = .between, .y = .center },
                        .width = .percent(70),
                        .height = .px(38),
                        .padding = .{ .top = 4, .bottom = 4, .left = 8, .right = 8 },
                        .border_radius = .all(8),
                        .border_thickness = .all(1),
                        .border_color = .hex("#3A3A3A"),
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
                            });
                            Static.Text("Search...", .{
                                .font_family = "Montserrat",
                                .font_size = 16,
                            });
                        });
                        Static.Icon("bi bi-command", .{
                            .font_size = 16,
                        });
                    });
                    Static.Link(.{ .url = "https://github.com/vic-Rokx/fabric", .aria_label = "redirect link to tether github repo" }, .{
                        .text_decoration = .none,
                    })({
                        Static.Icon("bi bi-github", .{
                            .text_color = text_color,
                            .font_size = 20,
                        });
                    });
                    Static.Link(.{ .url = "https://github.com/vic-Rokx/fabric", .aria_label = "redirect link to discord" }, .{
                        .text_decoration = .none,
                    })({
                        Static.Icon("bi bi-discord", .{
                            .text_color = text_color,
                            .font_size = 20,
                        });
                    });

                    Static.Column(.{})({
                        Static.Button(.{ .onPress = showDropDown, .aria_label = "theme-switch" }, .{})({
                            Static.Icon("bi bi-moon-stars-fill", .{
                                .text_color = text_color,
                                .font_size = 20,
                            });
                        });
                        if (show_dropdown.get()) {
                            Static.List(.{
                                .display = .Flex,
                                .position = .{ .type = .absolute, .top = .px(32), .right = .percent(0.05) },
                                .border_radius = .all(6),
                                .border_thickness = .all(1),
                                .height = .fit,
                                .child_gap = 4,
                                .direction = .column,
                                .padding = .{ .left = 4, .right = 4, .top = 4, .bottom = 4 },
                                .width = .px(100),
                            })({
                                for (theme_options) |opt| {
                                    Static.ListItem(.{
                                        .display = .Flex,
                                        .list_style = .none,
                                        .width = .percent(100),
                                        .height = .px(26),
                                        .hover = .{},
                                        .border_radius = .all(4),
                                    })({
                                        Static.CtxButton(switchTheme, .{opt.name}, .{
                                            .width = .percent(100),
                                            .height = .percent(100),
                                            .display = .Flex,
                                            .child_alignment = .{ .y = .center, .x = .start },
                                            .padding = .{ .left = 8, .top = 4, .bottom = 4, .right = 4 },
                                            // .background = activeTheme(opt.theme),
                                            .border_radius = .all(4),
                                            .child_gap = 8,
                                        })({
                                            Static.Icon(opt.icon, .{
                                                .width = .px(16),
                                                .height = .px(16),
                                                .text_color = .hex("#C0C0C0"),
                                                // .text_color = dropdownTextColor(opt.theme),
                                            });
                                            Static.Text(opt.name, .{
                                                .font_size = 14,
                                                .font_weight = 400,
                                                // .text_color = dropdownTextColor(opt.theme),
                                            });
                                        });
                                    });
                                }
                            });
                        }
                    });
                });
            });
        } else {
            Static.FlexBox(.{
                .child_alignment = .{ .x = .between, .y = .center },
                .child_gap = 8,
                .padding = .horizontal(12),
                .height = .px(50),
                .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
                .width = .percent(100),
                .z_index = 999,
                .background = root.theme.getAttribute("background"),
            })({
                Static.FlexBox(.{ .child_alignment = .start_center, .child_gap = 12 })({
                    Static.Link(.{ .url = "/", .aria_label = "home page of tether" }, .{
                        .text_decoration = .none,
                        .height = .px(36),
                        .display = .Center,
                    })({
                        // Static.Image("/assets/logonormal.svg", .{
                        //     .width = .px(36),
                        // });
                    });
                });
                Static.Button(.{ .onPress = openMenu }, .{
                    .width = .px(36),
                    .height = .px(36),
                })({
                    if (menu) {
                        Pure.Icon("bi bi-x-lg", .{
                            .font_size = 32,
                        });
                    } else {
                        Pure.Icon("bi bi-list", .{
                            .font_size = 32,
                        });
                    }
                });
            });
            if (menu) {
                Static.Block(.{
                    .position = .{ .type = .fixed, .top = .px(50), .left = .px(0) },
                    .width = .percent(100),
                    .background = root.theme.getAttribute("background"),
                    .z_index = 999,
                })({
                    Static.List(.{
                        .list_style = .none,
                        .display = .Flex,
                        .direction = .column,
                        .padding = .{ .top = 16, .bottom = 16, .right = 8, .left = 8 },
                        .child_gap = 16,
                        .width = .percent(100),
                    })({
                        for (urls) |item| {
                            Static.ListItem(.{
                                .width = .percent(100),
                                .border_radius = .all(4),
                                .hover = .{
                                    .background = .hex("#E4E4E4"),
                                },
                            })({
                                Static.Link(.{ .url = item.url, .aria_label = item.title }, .{
                                    .text_decoration = .none,
                                    .width = .percent(100),
                                    .display = .Flex,
                                    .child_alignment = .{ .x = .start, .y = .center },
                                    .child_gap = 12,
                                    .padding = .{ .top = 10, .bottom = 10, .right = 8, .left = 8 },
                                    .cursor = .pointer,
                                })({
                                    // Static.Icon(item.icon, .{});
                                    Static.Text(item.title, .{
                                        .font_size = 18,
                                    });
                                });
                            });
                        }
                    });
                });
            }
        }
    });
}
