const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Binded = Fabric.Binded;
const HtmlElement = Fabric.Element;
const menu_items = @import("../routes/docs/fabric/Menu.zig").menu_items;

var search_box: HtmlElement = HtmlElement{};
var background: HtmlElement = HtmlElement{};
var show: bool = false;
pub fn init() void {}

pub fn toggle() void {
    show = !show;
    Fabric.cycle();
}

pub fn mount() void {
    _ = background.addListener(.click, close);
}

fn close(_: *Fabric.Event) void {
    toggle();
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
            })({
                Binded.FlexBox(&background, .{
                    .position = .{
                        .type = .fixed,
                        .top = .percent(0),
                    },
                    .height = .percent(100),
                    .width = .percent(100),
                    .background = .transparentizeHex("#000000", 100),
                })({});
                Static.FlexBox(.{
                    .z_index = 1100,
                    .height = .percent(80),
                    .width = .clamp_percent(36, 700, 90),
                    .background = .hex("#F5F5F5"),
                    .padding = .all(12),
                    .direction = .column,
                    .child_alignment = .{ .x = .center, .y = .start },
                    .overflow_y = .scroll,
                    .child_gap = 8,
                    .border_radius = .all(8),
                })({
                    Static.FlexBox(.{
                        .width = .percent(100),
                        .child_alignment = .between_center,
                        .border_radius = .all(8),
                        .border_thickness = .all(2),
                        .border_color = .hex("#EFEFEF"),
                        .cursor = .pointer,
                        .hover = .{
                            .border_color = .hex("#5A27FF"),
                            .border_thickness = .all(2),
                        },
                        .background = .hex("#ffffff"),
                        .padding = .horizontal(12),
                    })({
                        Static.Icon("bi bi-search", .{
                            .font_size = 16,
                        });
                        Binded.Input(&search_box, .{ .string = .{ .default = "Search..." } }, .{
                            .width = .percent(90),
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
                    Static.List(.{
                        .display = .Flex,
                        .direction = .column,
                        .width = .percent(100),
                        .list_style = .none,
                        .padding = .all(0),
                        .child_gap = 16,
                    })({
                        for (menu_items) |item| {
                            Static.ListItem(.{
                                .width = .percent(100),
                                .background = .hex("#ffffff"),
                                .border_radius = .all(4),
                            })({
                                Static.Link(.{ .aria_label = item.title, .url = item.link }, .{
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
