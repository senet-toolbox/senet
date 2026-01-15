const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const println = Vapor.println;
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
const OverlayManager = @import("../../components/OverlayManager.zig");
const Opaque = @import("../../components/Opaque.zig");
const Item = @import("../../components/OpaqueTypes.zig").Item;

const CommandPalette = Opaque.CommandPalette;
const ComboBoxDialog = Opaque.ComboBoxDialog;

pub const MenuItem = Item([]const u8);

var command_palette: CommandPalette = .{};
var combobox_dialog: ComboBoxDialog([]const u8) = undefined;

pub var menu_items = [_]MenuItem{
    MenuItem{ .value = "/ui/accordion", .label = "Accordion", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/alert", .label = "Alert", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/button", .label = "Button", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/chart", .label = "Chart", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/combobox", .label = "Combobox", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/commandpalette", .label = "CommandPalette", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/datepicker", .label = "DatePicker", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/dialog", .label = "Dialog", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/drawer", .label = "Drawer", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/group", .label = "Group", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/select", .label = "Select", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/slider", .label = "Slider", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/sheet", .label = "Sheet", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/switch", .label = "Switch", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/table", .label = "Table", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/tabs", .label = "Tabs", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/textfield", .label = "TextField", .icon = Vapor.IconTokens.arrow_right },
    MenuItem{ .value = "/ui/toasts", .label = "Toasts", .icon = Vapor.IconTokens.arrow_right },
};

var nav: Vapor.Binded = .{};

pub fn init() void {
    combobox_dialog = .fromItems(&menu_items);
    combobox_dialog.on_select = onSelect;
    combobox_dialog.on_close = closePalette;
    command_palette.on_click = openSearch;
    command_palette.on_escape = closeSearch;
    OverlayManager.register(.keydown, navigateByNum, &nav);
}

fn navigateByNum(_: *Vapor.Binded, evt: *Vapor.Event) void {
    evt.preventDefault();
    Vapor.print("navigateByNum", .{});
    // const key = evt.key();
    // if (std.mem.eql(u8, key, "0")) {
    //     navigate("/vapor-ui");
    // } else if (std.mem.eql(u8, key, "1")) {
    //     navigate("/ui/commandpalette");
    // } else if (std.mem.eql(u8, key, "2")) {
    //     navigate("/templates");
    // } else if (std.mem.eql(u8, key, "3")) {
    //     navigate("/authentication");
    // } else if (std.mem.eql(u8, key, "4")) {
    //     navigate("/payment");
    // }
    //
    // if (std.mem.eql(u8, key, "x") and evt.metaKey()) {
    //     Theme.toggleTheme();
    // }
}

fn onSelect(item: *ComboBoxDialog([]const u8).ItemT) void {
    const path = item.value;
    Vapor.Kit.navigate(path);
    combobox_dialog.close();
}

fn openSearch() void {
    combobox_dialog.clearAll();
    combobox_dialog.clearText();
    combobox_dialog.open();
}

fn closeSearch() void {
    combobox_dialog.close();
}

fn closePalette() void {
    command_palette.clicked = false;
}

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
const urls: [4]Url = .{
    // .{
    //     .url = "/vapor-ui/docs",
    //     .title = "[0] = Docs",
    // },
    .{
        .url = "/vapor-ui/components",
        .title = "[1] = Components",
    },
    .{
        .url = "/vapor-ui/templates",
        .title = "[2] = Templates",
    },
    .{
        .url = "/vapor-ui/auth",
        .title = "[3] = Authentication",
    },
    .{
        .url = "/vapor-ui/payment",
        .title = "[4] = Payments",
    },
};

inline fn routes() void {
    // const current_path = Kit.getWindowPath();
    for (urls) |url| {
        ListItem().style(&Styles.item)({
            Link(.{ .url = url.url, .aria_label = url.title }).style(&.{
                .visual = .{ .text_decoration = .none },
            })({
                Text(url.title).style(&.{ .visual = .font(16, 300, .palette(.text_color)), .font_family = "IBM Plex Mono,monospace" });
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

// pub fn init() void {
//     // Search.init();
//     OverlayManager.register(.keydown, clickEvent, &local_binded);
// }

pub fn closeAll(evt: *Vapor.Event) void {
    evt.preventDefault();
}

pub fn setDefault() void {}

fn openDialog() void {
    // Search.toggle();
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

var local_binded: []const u8 = "";

pub fn clickEvent(_: *[]const u8, evt: *Vapor.Event) void {
    const key = evt.key();
    if (std.mem.eql(u8, key, "k") and evt.metaKey()) {
        openDialog();
    }
}

pub fn goto(url: []const u8) void {
    Vapor.Kit.navigate(url);
}

var mounted: bool = false;
var current_menu_item: ?MenuItem = null;
fn mount() void {
    mounted = true;
    Vapor.Kit.scrollTo(0, 0);
    // this runs after the vaporize is mounter
    const current_path = Vapor.Kit.getWindowPath() orelse "/vapor-ui";
    current_menu_item = null;
    for (menu_items) |item| {
        if (std.mem.eql(u8, current_path, item.value)) {
            current_menu_item = item;
            break;
        }
    }

    if (current_menu_item == null) return;
    const uuid = Vapor.fmtln("menu-{s}", .{current_menu_item.?.value});
    Vapor.scrollIntoView(uuid, .{ .block = .start });
}

pub fn render() void {
    const current_path = Vapor.Kit.getWindowPath() orelse "/vapor-ui";
    Vapor.Static.HooksCtx(.mounted, mount, .{})({
        if (Vapor.isDesktop()) {
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
                    CtxButton(goto, .{"/vapor-ui"})
                        .ariaLabel("home page of tether")
                        // Link(.{ .url = "/", .aria_label = "home page of tether" })
                        .style(&.{
                        .visual = .{ .text_decoration = .none },
                    })({
                        Center().style(&.{
                            .size = .{ .width = .px(84) },
                            .margin = .{ .right = 30 },
                            .transition = .{ .duration = 100 },
                            .interactive = .{ .hover = .{ .transform = .scale() } },
                            .visual = .{ .text_color = .palette(.text_color) },
                        })({
                            Graphic(.{ .src = "/assets/vapor_ui.svg" }).style(&.{
                                .size = .{ .width = .percent(100), .height = .percent(100) },
                                .visual = .{ .fill = .palette(.text_color), .stroke = .palette(.text_color) },
                                .transition = .{ .duration = 100 },
                                .interactive = .{ .hover = .{
                                    .fill = .palette(.tint),
                                    .stroke = .palette(.tint),
                                } },
                            });
                        });
                    });
                    List().style(&.{
                        .child_gap = 32,
                        .layout = .center,
                        .size = .hw(.percent(100), .percent(100)),
                    })({
                        routes();
                    });
                });

                Center().style(&.{
                    .child_gap = 8,
                    .size = .w(.percent(30)),
                })({
                    Box()
                        .width(.percent(70))
                        .margin(.r(12))
                        .children({
                        command_palette.render();
                    });
                    RedirectLink(.{ .url = "https://github.com/vic-Rokx/vapor", .aria_label = "redirect link to tether github repo" })
                        .class("nav-item")
                        .size(.hw_px(36, 36))
                        .layout(.center)
                        .background(.transparentizeHex(.black, 0.8))
                        .border(.round(.black, .all(8)))
                        .pointer()
                        .hover(.{
                            .background = .yellow,
                            .text_color = .black,
                        })
                        .children({
                        Icon(.github)
                            .class("nav-item-icon")
                            .inheritHover(&.{.text_color})
                            .font(18, 700, .white)
                            .end();
                    });
                    RedirectLink(.{ .url = "https://github.com/vic-Rokx/vapor", .aria_label = "redirect link to discord" })
                        .class("nav-item")
                        .size(.hw_px(36, 36))
                        .layout(.center)
                        .background(.transparentizeHex(.black, 0.8))
                        .border(.round(.black, .all(8)))
                        .pointer()
                        .hover(.{
                            .background = .yellow,
                            .text_color = .black,
                        })
                        .children({
                        Icon(.discord)
                            .class("nav-item-icon")
                            .inheritHover(&.{.text_color})
                            .font(18, 700, .white)
                            .end();
                    });

                    Button(.{ .on_press = toggleTheme, .aria_label = "toggle theme" })
                        .class("nav-item")
                        .size(.hw_px(36, 36))
                        .layout(.center)
                        .background(.transparentizeHex(.black, 0.8))
                        .border(.round(.black, .all(8)))
                        .pointer()
                        .hover(.{
                            .background = .yellow,
                            .text_color = .black,
                        })
                        .children({
                        Icon(.cloud_moon)
                            .class("nav-item-icon")
                            .inheritHover(&.{.text_color})
                            .font(18, 700, .white)
                            .end();
                    });
                });
            });
            if (!std.mem.eql(u8, current_path, "/vapor-ui")) {
                Box().style(&.{
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
                            const uuid = Vapor.fmtln("menu-{s}", .{item.value});
                            ListItem()
                                .id(uuid)
                                .style(&.{
                                .size = .hw(.fit, .percent(100)),
                                .visual = .{
                                    .background = if (std.mem.eql(u8, current_path, item.value)) .transparentizeHex(.palette(.tint), 0.1) else .transparent,
                                    .border = .r(1, if (std.mem.eql(u8, current_path, item.value)) .palette(.tint) else .transparent),
                                    .layer = if (std.mem.eql(u8, current_path, item.value)) .dot(0.5, 6, .transparentizeHex(.palette(.tint), 0.3)) else null,
                                },
                                .interactive = .{
                                    .hover = .{
                                        .background = if (std.mem.eql(u8, current_path, item.value)) .transparentizeHex(.palette(.tint), 0.1) else .palette(.highlight_color),
                                    },
                                },
                            })({
                                CtxButton(goto, .{item.value}).style(&.{
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
                                    //     // .visual = .{ .text_color = if (std.mem.eql(u8, current_path, item.value)) .palette(.tint) else .palette(.text_color) },
                                    // });
                                    Text(item.label).style(&.{
                                        .visual = .{
                                            .text_color = if (std.mem.eql(u8, current_path, item.value)) .palette(.tint) else .palette(.text_color),
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
                        Image(.{ .src = "/assets/circlelogo.webp", .alt = "tether logo" }).style(&.{
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
            // if (menu) {
            //     Box().style(&.{
            //         .position = .{ .type = .fixed, .top = .px(80), .left = .px(0), .z_index = 999 },
            //         .size = .w(.percent(100)),
            //         // .visual = .{ .background = Theme.background, .border = .tb(.hex("#E4E4E4")) },
            //     })({
            //         List().style(&.{
            //             .list_style = .none,
            //             .direction = .column,
            //             .padding = .tblr(16, 16, 8, 8),
            //             .child_gap = 16,
            //             .size = .w(.percent(100)),
            //         })({
            //             for (urls) |item| {
            //                 ListItem().style(&.{
            //                     .size = .w(.percent(70)),
            //                 })({
            //                     CtxButton(navigate, .{item.url}).style(&.{
            //                         .size = .w(.percent(100)),
            //                         .layout = .left_center,
            //                         .child_gap = 12,
            //                         .padding = .tblr(10, 10, 8, 8),
            //                         .visual = .{ .cursor = .pointer, .background = .white },
            //                     })({
            //                         Text(item.label).style(&.{
            //                             .font_family = "Montserrat",
            //                             .visual = .font(18, 300, .hex("#262626")),
            //                         });
            //                     });
            //                 });
            //             }
            //         });
            //     });
            // }
        }
    });
    combobox_dialog.render();
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
