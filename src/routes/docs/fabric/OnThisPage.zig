const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Types = Fabric.Types;
const Dynamic = Fabric.Dynamic;
const Element = Fabric.Element;

var otp_element: Element = Element{};
pub const Link = struct {
    title: []const u8,
    link: []const u8,
    id: []const u8,
};

fn mount() void {
    // otp_element.addClass("active");
    // Fabric.lib.addToClassesList("whatisfabric", "active");
}

fn navigate(link: []const u8) void {
    const path = std.fmt.allocPrint(Fabric.lib.allocator_global, "{s}{s}", .{ Fabric.Kit.getWindowPath(), link }) catch unreachable;
    Fabric.Kit.navigate(path);
    // otp_element.removeClass("active");
}

pub fn render(onthispage_items: []const Link) void {
    Static.Hooks(.{ .mounted = mount }, .{})({
        Static.List(.{
            .list_style = .none,
            .display = .Flex,
            .direction = .column,
            .padding = .{ .top = 16, .bottom = 16, .right = 8, .left = 8 },
            .child_gap = 16,
            .width = .percent(100),
            .overflow_y = .scroll,
            .height = .percent(100),
            .show_scrollbar = false,
            .margin = .all(0),
            .child_styles = &.{Types.ChildStyle{
                .style_id = "active",
                .text_color = .hex("#802BFF"),
            }},
        })({
            for (onthispage_items) |item| {
                Static.ListItem(.{
                    .width = .percent(100),
                    .margin = .all(0),
                    // .border_radius = .all(4),
                    // .background = if (std.mem.eql(u8, current_path, item.link)) .transparentizeHex("#802BFF", 30) else .transparent,
                    // .hover = .{
                    //     .background = if (std.mem.eql(u8, current_path, item.link)) .transparentizeHex("#802BFF", 30) else .hex("#EDEDED"),
                    // },
                    .border_thickness = .{ .right = 2 },
                    // .border_color = if (std.mem.eql(u8, current_path, item.link)) .hex("#802BFF") else .transparent,
                })({
                    Static.CtxButton(navigate, .{item.link}, .{
                        .width = .percent(100),
                        .display = .Flex,
                        .child_alignment = .{ .x = .start, .y = .center },
                        // .padding = .{ .top = 10, .bottom = 10, .right = 8, .left = 8 },
                        .cursor = .pointer,
                        .margin = .all(0),
                        .padding = .all(0),
                    })({
                        Static.Text(item.title, .{
                            .id = item.link,
                            .font_size = 14,
                        });
                    });
                });
            }
        });
    });
}
