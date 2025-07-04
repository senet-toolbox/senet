const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Navbar = @import("../components/Navbar.zig");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Style = Fabric.Style;
const Custom = @import("../components/Custom.zig");
const root = @import("../main.zig");
const description_1: []const u8 = "Writing code should be more ";
const description_2: []const u8 = "cumbersome";
const description_3: []const u8 = ", than ";
const description_4: []const u8 = "reading it!";
const description_5: []const u8 = " ";
const description_6: []const u8 = "Tether";
const description_7: []const u8 = " aims to unite the fragmented hell of dependencies known as Web Development, by providing a toolkit that works as a complete framework out of the box yet remains fully modular and adaptable to your exact needs.";

const MenuItem = struct {
    title: []const u8,
    link: []const u8,
    icon: []const u8,
};

const menu_items: []const MenuItem = &.{
    MenuItem{
        .title = "Fabric",
        .link = "/docs/fabric",
        .icon = "bi bi-house", // Keep as is - perfect for home
    },
    MenuItem{
        .title = "Tether",
        .link = "/docs/tether",
        .icon = "bi bi-fire", // Keep as is - perfect for home
    },
    MenuItem{
        .title = "Treehouse",
        .link = "/docs/treehouse",
        .icon = "bi bi-leaf", // Book icon for introductory content
    },
    MenuItem{
        .title = "About",
        .link = "/about",
        .icon = "bi bi-user", // Graduation cap for learning basics
    },
};

pub fn init() void {
    Navbar.init();
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
                .width = .clamp_percent(50, 786, 100),
                .height = .percent(100),
                .direction = .column,
            })({
                Static.Column(.{
                    .child_alignment = .{ .x = .start, .y = .start },
                    .width = .percent(100),
                    .margin = .all(0),
                    .child_gap = 0,
                })({
                    Static.FlexBox(.{
                        .width = .percent(100),
                        .margin = .all(0),
                        .height = .px(100),
                    })({
                        Static.Svg(@embedFile("text.svg"), .{
                            .display = .InlineBlock,
                            .width = .px(270),
                            .margin = .{ .right = 20 },
                        });
                        Static.Text("all-in-one", .{
                            .display = .InlineBlock,
                            .font_weight = 900,
                            .font_size = 90,
                            .margin = .all(0),
                        });
                    });
                    Static.Text("app toolkit.", .{
                        .display = .InlineBlock,
                        .font_weight = 900,
                        .font_size = 90,
                        .margin = .all(0),
                    });
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
                    .height = .px(100),
                    .child_gap = 20,
                    .child_alignment = .start_center,
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
            });
        }
        Static.FlexBox(.{
            .width = .clamp_percent(40, 600, 100),
            .direction = .column,
            .child_alignment = .center,
        })({
            if (Fabric.isMobile()) {
                Static.Image("/assets/Logo.svg", .{
                    .width = .percent(70),
                    .display = .Center,
                    .margin = .{ .top = 80 },
                });
            } else {
                Static.Image("/assets/Logo.svg", .{
                    .width = .percent(100),
                });
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
        });
    });
}
