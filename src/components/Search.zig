const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Binded = Fabric.Binded;
const Dynamic = Fabric.Dynamic;
const HtmlElement = Fabric.Element;
const menu_items = @import("../routes/docs/fabric/Menu.zig").menu_items;
const MenuItem = @import("../routes/docs/fabric/Menu.zig").MenuItem;

var search_box: HtmlElement = HtmlElement{};
var background: HtmlElement = HtmlElement{};
var show: bool = false;
var dynamic_menu_items: std.ArrayList(MenuItem) = undefined;
pub fn init() void {
    dynamic_menu_items = std.ArrayList(MenuItem).init(Fabric.lib.allocator_global);
    dynamic_menu_items.appendSlice(menu_items) catch {
        Fabric.println("Error appending menu items", .{});
    };
}

pub fn toggle() void {
    show = !show;
    Fabric.cycle();
}

pub fn mount() void {
    _ = background.addListener(.click, close);
    _ = search_box.addListener(.input, search);
    _ = search_box.focus();
}

/// Searches the item's title and all relevant fields within its tags.
fn search(_: *Fabric.Event) void {
    const text = search_box.getInputValue() orelse return;

    // Clear the list to rebuild it for the new search
    dynamic_menu_items.clearRetainingCapacity();

    // If the search box is empty, show all items
    if (text.len == 0) {
        dynamic_menu_items.appendSlice(menu_items) catch {};
        Fabric.cycle();
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

    Fabric.cycle();
}

fn close(_: *Fabric.Event) void {
    toggle();
}

fn navigate(link: []const u8) void {
    Fabric.Kit.navigate(link);
    toggle();
}

var showBorder: bool = false;
fn toggleBorder() void {
    Fabric.println("Border toggled", .{});
    showBorder = !showBorder;
    Fabric.cycle();
}

pub fn render() void {
    if (show) {
        Static.Hooks(.{ .mounted = mount }, .{})({
            Static.Center(.{
                .position = .{
                    .type = .fixed,
                    .top = .percent(0),
                },
                .height = .percent(100),
                .width = .percent(100),
                .direction = .row,
                .z_index = 999,
            })({
                Binded.Box(&background, .{
                    .position = .{
                        .type = .fixed,
                        .top = .percent(0),
                        .right = .px(0),
                        .left = .px(0),
                        .bottom = .px(0),
                    },
                    .background = .transparentizeHex("#000000", 100),
                })({});
                Static.Box(.{
                    .height = .percent(80),
                    .width = .clamp_percent(36, 36, 90),
                    .background = .hex("#F5F5F5"),
                    .padding = .all(12),
                    .direction = .column,
                    .child_alignment = .top_center,
                    .overflow_y = .scroll,
                    .child_gap = 8,
                    .border_radius = .all(8),
                    .z_index = 1100,
                })({
                    Static.Box(.{
                        .width = .percent(100),
                        .border_radius = .all(8),
                        // .position = .{ .type = .relative },
                        .child_alignment = .x_between_center,
                        .padding = .horizontal(12),
                        .hover = .{
                            .border_color = .hex("#5A27FF"),
                            .border_thickness = .all(2),
                        },
                        .focus = .{
                            .border_color = .hex("#5A27FF"),
                            .border_thickness = .all(2),
                            .shadow = .{
                                .color = .rgba(139, 92, 246, 200),
                                .blur = 3,
                                .spread = 1,
                            },
                        },
                        .border_color = .transparent,
                        .border_thickness = .all(2),
                    })({
                        Static.Icon("bi bi-search", .{
                            .font_size = 16,
                        });
                        Binded.Input(&search_box, .{ .string = .{ .default = "Search..." } }, .{
                            .width = .percent(100),
                            .height = .px(60),
                            .padding = .{ .top = 4, .bottom = 4, .left = 8, .right = 8 },
                            .background = .transparent,
                            .font_size = 18,
                            .outline = .none,
                            .border_thickness = .all(0),
                        });
                        Static.Icon("bi bi-command", .{
                            .font_size = 16,
                        });
                    });

                    Pure.AllocText("Results {d}", .{3}, .{
                        .font_weight = 700,
                        .font_size = 14,
                        .width = .percent(100),
                        .margin = .{ .top = 20 },
                    });
                    Pure.List(.{
                        .display = .Flex,
                        .direction = .column,
                        .width = .percent(100),
                        .list_style = .none,
                        .padding = .all(0),
                        .child_gap = 16,
                    })({
                        for (dynamic_menu_items.items) |item| {
                            Dynamic.ListItem(item.id, .{
                                .width = .percent(100),
                                .background = .hex("#ffffff"),
                                .border_radius = .all(4),
                            })({
                                Static.CtxButton(navigate, .{item.link}, .{
                                    .display = .Flex,
                                    .width = .percent(100),
                                    .height = .px(60),
                                    .border_radius = .top_bottom(4, 0),
                                    .border_color = .rgba(0, 0, 0, 0),
                                    .border_thickness = .all(2),
                                    .padding = .horizontal(8),
                                    .cursor = .pointer,
                                    .direction = .column,
                                    .hover = .{
                                        .border_color = .hex("#5A27FF"),
                                        .border_thickness = .all(2),
                                    },
                                    .text_decoration = .none,
                                })({
                                    Static.Text(item.title, .{
                                        .font_size = 18,
                                        .text_color = .hex("#5A27FF"),
                                        .font_weight = 700,
                                    });
                                    Static.Text(item.link, .{
                                        .font_size = 12,
                                        .text_color = .hex("#353535"),
                                    });
                                });
                                for (item.tags, 0..) |tag, i| {
                                    Static.Link(.{ .aria_label = tag.sub_title, .url = tag.url }, .{
                                        .display = .Flex,
                                        .width = .percent(100),
                                        .height = .px(60),
                                        .border_color = .rgba(0, 0, 0, 0),
                                        .border_thickness = .all(2),
                                        .cursor = .pointer,
                                        .direction = .column,
                                        .padding = .horizontal(8),
                                        .text_decoration = .none,
                                        .hover = .{
                                            .border_color = .hex("#5A27FF"),
                                            .border_thickness = .all(2),
                                            .border_radius = if (item.tags.len - 1 == i) .top_bottom(0, 4) else null,
                                        },
                                    })({
                                        Static.Text(tag.sub_title, .{
                                            .font_size = 16,
                                            .font_weight = 700,
                                            .text_color = .hex("#353535"),
                                        });
                                        Static.Text(tag.description, .{
                                            .font_size = 14,
                                            .text_color = .hex("#353535"),
                                        });
                                    });
                                }
                            });
                        }
                    });
                });
            });
        });
    }
}
