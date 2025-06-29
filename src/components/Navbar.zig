const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Dynamic = Fabric.Dynamic;
const Signal = Fabric.Signal;
const println = Fabric.println;

var theme_background: Fabric.Types.Background = undefined;
var text_color: Fabric.Types.Background = undefined;
var tint: Fabric.Types.Background = undefined;

fn routes() void {
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
            .title = "About",
        },
    };
    for (urls) |url| {
        Static.ListItem(.{
            // .style_id = "dropdown",
            .list_style = .none,
            .width = .elastic(50, 130),
            .height = .fixed(30),
            .display = .Flex,
            .child_alignment = .{ .y = .center, .x = .start },
            .border_thickness = .{ .bottom = 1, .top = 0, .left = 0, .right = 0 },
            .hover = .{
                .border_color = text_color,
                .border_thickness = .{ .bottom = 1, .top = 0, .left = 0, .right = 0 },
                // .display = .Flex,
            },
        })({
            Static.Link(url.url, .{
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
        .width = .fixed(300),
        .height = .fixed(300),
        .display = .Flex,
    })({});
}

const Self = @This();
var allocator = std.heap.page_allocator;
var signal: Signal(u32) = undefined;
var show: Signal(bool) = undefined;
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
    signal.init(0);
    show.init(false);
    // Fabric.eventListener(.click, closeAll);
    show_dropdown.init(false);
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

pub fn render() void {
    text_color = Fabric.Types.Background.hex("#262626");
    tint = Fabric.Types.Background.hex("#6338FF");
    Static.FlexBox(.{
        .position = .{
            .type = .fixed,
            .right = .fixed(0),
            .left = .fixed(0),
        },
        .display = .Flex,
        .width = .grow,
        .height = .fixed(60),
        .direction = .row,
        .child_alignment = .{ .x = .between, .y = .center },
        .padding = .{
            .left = 50,
            .right = 50,
        },
        .z_index = 1000,
        .blur = 1,
    })({
        Static.FlexBox(.{
            .height = .fixed(50),
            .direction = .row,
            .child_alignment = .start_center,
            .child_gap = 10,
        })({
            Static.Link("/", .{
                .text_decoration = .none,
            })({
                Static.Center(.{
                    .width = .fixed(45),
                    .margin = .{ .right = 30 },
                })({
                    Static.Svg(@embedFile("../logo.svg"), .{
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
        })({
            Static.FlexBox(.{
                .child_alignment = .{ .x = .even, .y = .center },
                .width = .fixed(300),
                .padding = .{ .top = 4, .bottom = 4, .left = 6, .right = 6 },
                .border_radius = .all(8),
                .border_thickness = .all(1),
                .border_color = .hex("#3A3A3A"),
            })({
                Static.Icon("bi bi-search", .{
                    .text_color = text_color,
                    .font_size = 16,
                });
                Static.Input(.{
                    .string = .{
                        .default = "Search...",
                        .tag = "search-field",
                    },
                }, .{
                    .height = .fixed(30),
                    .font_size = 16,
                    .text_color = text_color,
                    .outline = .none,
                });
                Static.Icon("bi bi-command", .{
                    .text_color = text_color,
                    .font_size = 16,
                });
            });
            Static.RedirectLink("https://github.com/vic-Rokx/fabric", .{
                .text_decoration = .none,
            })({
                Static.Icon("bi bi-github", .{
                    .text_color = text_color,
                    .font_size = 20,
                });
            });
            Static.RedirectLink("https://github.com/vic-Rokx/fabric", .{
                .text_decoration = .none,
            })({
                Static.Icon("bi bi-discord", .{
                    .text_color = text_color,
                    .font_size = 20,
                });
            });

            Static.Column(.{})({
                Static.Button(.{ .onPress = showDropDown }, .{})({
                    Static.Icon("bi bi-moon-stars-fill", .{
                        .text_color = text_color,
                        .font_size = 20,
                    });
                });
                if (show_dropdown.get()) {
                    Static.List(.{
                        .display = .Flex,
                        .position = .{ .type = .absolute, .top = .fixed(32), .right = .percent(0.05) },
                        .border_radius = .all(6),
                        .border_thickness = .all(1),
                        .height = .fit,
                        .child_gap = 4,
                        .direction = .column,
                        .padding = .{ .left = 4, .right = 4, .top = 4, .bottom = 4 },
                        .width = .fixed(100),
                    })({
                        for (theme_options) |opt| {
                            Static.ListItem(.{
                                .display = .Flex,
                                .list_style = .none,
                                .width = .percent(100),
                                .height = .fixed(26),
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
                                        .width = .fixed(16),
                                        .height = .fixed(16),
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
}
