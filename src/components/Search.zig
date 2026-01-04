const std = @import("std");
const Vapor = @import("vapor");
const Static = Vapor.Static;
const Binded = Vapor.Binded;
const Dynamic = Vapor.Dynamic;
const HtmlElement = Vapor.Binded;
const menu_items = @import("../components/DocNavbar.zig").menu_items;
const MenuItem = @import("../components/DocNavbar.zig").MenuItem;
const Theme = @import("theme");
const TextFmt = Vapor.TextFmt;
const TextField = Vapor.TextField;

var search_box: HtmlElement = HtmlElement{};
var background: Vapor.Binded = .{};
var show: bool = false;
var dynamic_menu_items: std.array_list.Managed(MenuItem) = undefined;
pub fn init() void {
    dynamic_menu_items = std.array_list.Managed(MenuItem).init(Vapor.lib.allocator_global);
    dynamic_menu_items.appendSlice(menu_items) catch {
        Vapor.println("Error appending menu items", .{});
    };
}

pub fn toggle() void {
    show = !show;
}

pub fn mount() void {
    current_item = null;
}

fn clear() void {
    dynamic_menu_items.clearRetainingCapacity();
    dynamic_menu_items.appendSlice(menu_items) catch {
        Vapor.println("Error appending menu items", .{});
    };
}

/// Searches the item's title and all relevant fields within its tags.
var binded_searchbar: Binded = .{};
fn search(evt: *Vapor.Event) void {
    const text = evt.text();

    // Clear the list to rebuild it for the new search
    dynamic_menu_items.clearRetainingCapacity();

    // If the search box is empty, show all items
    if (text.len == 0) {
        dynamic_menu_items.appendSlice(menu_items) catch {};
        // Vapor.cycle();
        return;
    }

    // Loop through the master list of all menu items
    for (menu_items) |item| {
        var found_match = false;

        // 1. Check if the main title matches
        if (std.ascii.startsWithIgnoreCase(item.title, text)) {
            found_match = true;
        }

        // 2. If no match yet, search through the tags
        if (!found_match) {
            for (item.tags) |tag| {
                // Check tag's sub_title and description
                if (std.ascii.startsWithIgnoreCase(tag.sub_title, text) or
                    std.ascii.startsWithIgnoreCase(tag.description, text))
                {
                    found_match = true;
                    break; // Match found, no need to check other tags
                }

                // Check the tag's keywords
                for (tag.keywords) |keyword| {
                    if (std.ascii.startsWithIgnoreCase(keyword, text)) {
                        found_match = true;
                        break; // Keyword matched, break from keyword loop
                    }
                }

                // If a keyword matched, break from the outer tag loop too
                if (found_match) {
                    break;
                }
            }
        }

        // 3. If a match was found anywhere, add the item to the dynamic list
        if (found_match) {
            dynamic_menu_items.append(item) catch {};
        }
    }
}

fn closeEvent(_: *Vapor.Event) void {
    show = false;
    Vapor.cycle();
}

fn close() void {
    show = false;
    clear();
}

var current_item: ?MenuItem = null;
fn onHover(item: MenuItem, _: *Vapor.Event) void {
    current_item = item;
}

fn onLeave(_: *Vapor.Event) void {
    current_item = null;
}

fn navigate(url: []const u8) void {
    Vapor.Kit.navigate(url);
    close();
}

pub fn render() void {
    if (show) {
        Static.Hooks(.{ .mounted = mount })({
            Static.Center().style(&.{
                .position = .{
                    .type = .fixed,
                    .top = .percent(0),
                    .bottom = .percent(0),
                    .left = .percent(0),
                    .right = .percent(0),
                    .z_index = 1100,
                },
                .size = .square_percent(100),
                .direction = .row,
            })({
                // Static.Box().bind(&background).style(&.{
                Static.Button(.{ .on_press = close })
                .style(&.{
                    .position = .{
                        .type = .fixed,
                        .top = .px(0),
                        .right = .px(0),
                        .left = .px(0),
                        .bottom = .px(0),
                        .z_index = 1100,
                    },
                    .visual = .{ .background = .transparentizeHex(.hex("#000000"), if (Theme.mode == .light) 0.1 else 0.7) },
                })({});
                Static.Box().style(&.{
                    .size = .{ .width = .mobile_desktop_percent(90, 40), .height = .percent(80) },
                    .visual = .{
                        .border = .simple(.palette(.text_color)),
                        // .border_radius = .all(8),
                        .background = .palette(.background),
                    },
                    .padding = .all(12),
                    .direction = .column,
                    .layout = .top_center,
                    .scroll = .scroll_y(),
                    .child_gap = 8,
                    .position = .{ .type = .relative, .z_index = 1101 },
                })({
                    Static.Box().style(&.{
                        .size = .{ .width = .percent(100) },
                        .layout = .x_between_center,
                        .padding = .horizontal(12),
                        .interactive = .{
                            .hover = .{
                                .border = .simple(.palette(.tint)),
                            },
                        },
                        .visual = .{ .border = .simple(.hex("#E1E1E1")), .cursor = .pointer, .background = .palette(.background) },
                    })({
                        Static.Icon(.search).style(&.{
                            .visual = .{ .font_size = 16 },
                        });
                        TextField(.string).onChange(search).style(&.{
                            .size = .hw(.px(38), .grow),
                            .padding = .tblr(4, 4, 8, 8),
                            .visual = .{
                                .border = .none,
                                .font_size = 18,
                                .background = .transparent,
                                .text_color = .palette(.text_color),
                                .outline = .none,
                            },
                            .font_family = "IBM Plex Mono,monospace",
                        });
                        Static.Icon(.command).style(&.{
                            .visual = .{ .font_size = 16 },
                        });
                    });

                    TextFmt("Results {d}", .{3}).style(&.{
                        .visual = .{ .font_weight = 700, .font_size = 14 },
                        .size = .{ .width = .percent(100) },
                        .margin = .{ .top = 20 },
                    });
                    Static.List().style(&.{
                        .direction = .column,
                        .size = .{ .width = .percent(100) },
                        .list_style = .none,
                        .padding = .all(0),
                        .child_gap = 16,
                    })({
                        for (dynamic_menu_items.items, 0..) |item, j| {
                            const border: Vapor.Types.BorderGrouped = if (j != 0) .sharp(.tblr(1, 1, 1, 1), .palette(.text_color)) else .simple(.palette(.text_color));
                            Static.ListItem()
                                .onHoverCtx(onHover, item)
                                .onLeave(onLeave)
                                .style(&.{
                                .size = .{ .width = .percent(100), .height = .fit },
                                .visual = .{
                                    .cursor = .pointer,
                                    .border = border,
                                },
                                .margin = .b(-1),
                                .padding = .tblr(8, 8, 8, 8),
                                .interactive = .{
                                    .hover = .{
                                        .border = .simple(.palette(.tint)),
                                    },
                                    .hover_position = .{ .z_index = 1000, .type = .relative },
                                },
                            })({
                                const text_color: Vapor.Types.Color = if (current_item) |c_item| if (std.mem.eql(u8, c_item.id, item.id)) .palette(.tint) else .palette(.text_color) else .palette(.text_color);
                                // Static.Link(.{ .url = item.link, .aria_label = item.title })
                                //     .textDecoration(.none)
                                //     .body()({
                                Static.CtxButton(navigate, .{item.link})
                                    .width(.full)
                                    .layout(.left_center)
                                    .direction(.column)
                                    .pointer()
                                    .textDecoration(.none
                                        // &.{
                                        // .size = .{ .width = .percent(100), .height = .px(60) },
                                        // .visual = .{
                                        //     .border_radius = .top_bottom(4, 0),
                                        //     .border_color = .transparent,
                                        //     .border_thickness = .all(2),
                                        //     .cursor = .pointer,
                                        //     .text_decoration = .none,
                                        // },
                                        // .padding = .horizontal(8),
                                        // .direction = .column,
                                        // .interactive = .{
                                        //     .hover = .{
                                        //         .border_color = .hex("#5A27FF"),
                                        //         .border_thickness = .all(2),
                                        //     },
                                        // },
                                        // }
                                    ).children({
                                    Static.Text(item.title).style(&.{
                                        .visual = .{ .font_size = 18, .text_color = text_color, .font_weight = 700 },
                                        .font_family = "IBM Plex Mono,monospace",
                                    });
                                    Static.Text(item.link).style(&.{
                                        .visual = .{ .font_size = 12, .text_color = text_color },
                                        .font_family = "IBM Plex Mono,monospace",
                                    });
                                    // });
                                    for (item.tags) |tag| {
                                        Static.Link(.{ .aria_label = tag.sub_title, .url = tag.url }).style(&.{
                                            .layout = .left_center,
                                            .size = .{ .width = .fit, .height = .fit },
                                            .visual = .{
                                                .cursor = .pointer,
                                                .text_decoration = .none,
                                                .border = .bottom(.transparent),
                                            },
                                            .direction = .column,
                                            .font_family = "Montserrat",
                                            // .padding = .horizontal(8),
                                            .interactive = .{
                                                .hover = .{
                                                    .border = .bottom(.palette(.tint)),
                                                },
                                            },
                                        })({
                                            Static.Text(tag.sub_title).style(&.{
                                                .visual = .{ .font_size = 14, .font_weight = 700, .text_color = text_color },
                                            });
                                            Static.Text(tag.description).style(&.{
                                                .visual = .{ .font_size = 14, .text_color = text_color },
                                            });
                                        });
                                    }
                                });
                            });
                        }
                    });
                });
            });
        });
    } else {
        Static.Null();
    }
}
