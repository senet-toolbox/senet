const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Navbar = @import("../components/Navbar.zig");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Style = Fabric.Style;
const description_1: []const u8 = "Writing code should be more ";
const description_2: []const u8 = "cumbersome";
const description_3: []const u8 = ", than ";
const description_4: []const u8 = "reading it!";
const description_5: []const u8 = " ";
const description_6: []const u8 = "Tether";
const description_7: []const u8 = " aims to unite the fragmented hell of dependencies known as Web Development, and finally create a simple and approachable toolkit for developers new and old.";
pub fn init() void {
    Navbar.init();
    Fabric.Page(@src(), render, null, Style.override(.{
        .width = .percent(1),
        .height = .percent(1),
        .direction = .column,
        .child_alignment = .{ .y = .center, .x = .start },
    }));
}

fn log() void {}

pub fn render() void {
    Navbar.render();
    Static.Center(.{
        .height = .percent(100),
        .width = .percent(100),
    })({
        Static.Center(.{
            .width = .percent(50),
            .height = .percent(100),
            .direction = .column,
        })({
            Static.Header("First all-in-one app toolkit.", .XLarge, .{
                .font_weight = 900,
                .font_size = 90,
                .margin = .all(10),
            });
            Static.Block(.{
                .margin = .all(10),
            })({
                Static.Text(description_1, .{
                    .display = .Inline,
                    .font_weight = 500,
                    .font_size = 20,
                    .opacity = 0.7,
                });
                Static.Text(description_2, .{
                    .display = .Inline,
                    .font_weight = 700,
                    .font_size = 20,
                    .text_color = .hex("#6439FF"),
                });
                Static.Text(description_3, .{
                    .display = .Inline,
                    .font_weight = 500,
                    .font_size = 20,
                    .opacity = 0.7,
                });
                Static.Text(description_4, .{
                    .display = .Inline,
                    .font_weight = 700,
                    .font_size = 20,
                    .text_color = .hex("#6439FF"),
                });
                Static.Text(description_5, .{
                    .display = .Inline,
                    .font_weight = 500,
                    .font_size = 20,
                    .opacity = 0.7,
                });
                Static.Text("", .{
                    .font_weight = 500,
                    .font_size = 20,
                    .opacity = 0.7,
                    .margin = .{ .top = 12 },
                });
                Static.Text(description_6, .{
                    .display = .Inline,
                    .font_weight = 900,
                    .font_size = 20,
                    .text_color = .hex("#6439FF"),
                });
                Static.Text(description_7, .{
                    .display = .Inline,
                    .font_weight = 500,
                    .font_size = 20,
                    .opacity = 0.7,
                });
            });
            Static.FlexBox(.{
                .height = .fixed(100),
                .child_gap = 20,
                .child_alignment = .start_center,
                .width = .percent(100),
            })({
                Static.Button(.{ .onPress = log }, .{
                    .display = .Flex,
                    .child_alignment = .center,
                    .width = .fixed(160),
                    .height = .fixed(45),
                    .border_radius = .all(99),
                    .border_thickness = .all(0),
                    .background = .hex("#262626"),
                    .transition = .{
                        .duration = 300,
                        .properties = &.{.transform},
                        .timing = .ease,
                    },
                    .hover = .{
                        .transform = .{ .scale_size = 1.05, .type = .scale },
                    },
                })({
                    Static.Text("Increment", .{
                        .font_family = "Montserrat",
                        .font_weight = 300,
                        .font_size = 18,
                        .text_color = .hex("#ffffff"),
                    });
                });
                Static.Button(.{ .onPress = log }, .{
                    .display = .Flex,
                    .width = .fixed(160),
                    .height = .fixed(45),
                    .background = .hex("#ffffff"),
                    .border_color = .hex("#262626"),
                    .border_radius = .all(99),
                    .border_thickness = .all(1),
                    .child_alignment = .center,
                    .child_gap = 6,
                    .transition = .{
                        .duration = 300,
                        .properties = &.{.transform},
                        .timing = .ease,
                    },
                    .hover = .{
                        .transform = .{ .scale_size = 1.05, .type = .scale },
                    },
                })({
                    Static.Text("Download", .{
                        .font_family = "Montserrat",
                        .font_weight = 300,
                        .font_size = 18,
                        .text_color = .hex("#262626"),
                    });
                    Static.Icon("bi bi-cloud-download-fill", .{
                        .text_color = .hex("#262626"),
                        .font_size = 20,
                    });
                });
            });
        });
        Static.FlexBox(.{
            .width = .percent(40),
            .direction = .column,
            .child_alignment = .center,
        })({
            Static.Svg(@embedFile("Logo.svg"), .{
                .width = .percent(100),
            });
        });
        // Static.FlexBox(.{})({
        //     Static.Text("Code should be cumbersome to write, but easy to understand!", .{
        //         .font_size = 32,
        //         .white_space = .pre,
        //     });
        // });
    });
}
