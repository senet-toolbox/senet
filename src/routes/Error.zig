const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Navbar = @import("../components/Navbar.zig");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Style = Fabric.Style;
const Custom = @import("../components/Custom.zig");
const root = @import("../main.zig");

pub fn init() void {
    Fabric.Page(@src(), render, null, Style.override(.{
        .width = .percent(1),
        .height = .percent(1),
        .direction = .column,
        .child_alignment = .{ .y = .center, .x = .start },
    }));
}

pub fn render() void {
    Navbar.render();
    Static.Center(.{
        .height = .percent(100),
        .width = .percent(100),
    })({
        if (!Fabric.isMobile()) {
            Static.Center(.{
                .width = .clamp_percent(60, 786, 100),
                .height = .percent(100),
                .direction = .column,
            })({
                Static.Text("Error, Sorry this page doesn't exist. But there are others you may like!", .{
                    .display = .Center,
                    .font_size = 36,
                    .font_weight = 700,
                    .text_color = .hex("#1a1a1a"),
                });
            });
        }
        // Static.FlexBox(.{
        //     .width = .clamp_percent(40, 600, 100),
        //     .direction = .column,
        //     .child_alignment = .center,
        // })({
        if (Fabric.isMobile()) {
            Static.Image("/assets/Logo.svg", .{
                .width = .percent(70),
                .display = .Center,
                .margin = .{ .top = 80 },
            });
        } else {
            // Static.Image("/assets/Logo.svg", .{
            //     .width = .percent(100),
            // });
        }

        if (Fabric.isMobile()) {
            Static.Center(.{
                .direction = .column,
                .padding = .horizontal(12),
                .child_gap = 16,
            })({
                Static.FlexBox(.{
                    .child_gap = 32,
                })({
                    Static.Link(.{ .url = "https://github.com/vic-Rokx/fabric", .aria_label = "redirect link to tether github repo" }, .{
                        .text_decoration = .none,
                        .height = .px(56),
                        .width = .px(56),
                        .border_thickness = .all(1),
                        .border_color = .hex("#EFEFEF"),
                        .border_radius = .all(8),
                        .display = .Center,
                    })({
                        Static.Icon("bi bi-github", .{
                            .font_size = 28,
                            .text_color = .hex("#252525"),
                        });
                    });
                    Static.Link(.{ .url = "https://github.com/vic-Rokx/fabric", .aria_label = "redirect link to discord" }, .{
                        .text_decoration = .none,
                        .height = .px(56),
                        .width = .px(56),
                        .border_thickness = .all(1),
                        .border_radius = .all(8),
                        .border_color = .hex("#EFEFEF"),
                        .display = .Center,
                    })({
                        Static.Icon("bi bi-discord", .{
                            .font_size = 28,
                            .text_color = .hex("#252525"),
                        });
                    });
                });

                Custom.HtmlText(
                    \\Writing code should be more <strong style="color: #6439FF">cumbersome</strong> than <strong style="color: #6439FF">reading it!</strong>
                , .{
                    .display = .Center,
                    .font_size = 32,
                    .font_weight = 700,
                });
                Custom.HtmlText(
                    \\<strong style="color: #6439FF">Tether</strong> is a  
                    \\toolkit that works as a complete framework out of the box yet remains fully modular and adaptable to your exact needs.
                , .{
                    .display = .Center,
                    .font_size = 20,
                });
            });
            if (Fabric.isMobile()) {
                Static.FlexBox(.{
                    .height = .px(100),
                    .child_gap = 20,
                    .child_alignment = .center,
                    .width = .percent(100),
                })({
                    Static.Link(.{ .url = "/huh", .aria_label = "what is tether?" }, .{
                        .display = .Flex,
                        .child_alignment = .center,
                        .width = .px(160),
                        .height = .px(45),
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
                        Static.Text("Huh?", .{
                            .font_weight = 300,
                            .font_size = 18,
                            .text_color = .hex("#ffffff"),
                        });
                    });
                    Static.Link(.{ .url = "/download", .aria_label = "download page for tether" }, .{
                        .display = .Flex,
                        .width = .px(160),
                        .height = .px(45),
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
                        .text_decoration = .none,
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
            }
        }
        // });
    });
}
