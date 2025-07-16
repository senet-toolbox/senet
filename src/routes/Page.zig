const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Navbar = @import("../components/Navbar.zig");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Style = Fabric.Style;
const Custom = @import("../components/Custom.zig");
const root = @import("../main.zig");
const Comparison = @import("Comparison.zig");

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
    Comparison.init();
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
        .width = .percent(100),
        .height = .percent(100),
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
                    .child_gap = 0,
                    .margin = .{ .top = 64 },
                })({
                    Static.FlexBox(.{
                        .width = .percent(100),
                        .margin = .all(0),
                        .height = .px(100),
                    })({
                        Static.Svg(@embedFile("text.svg"), .{
                            .display = .InlineBlock,
                            .width = .px(280),
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
                Static.Column(.{
                    // .margin = .all(10),
                    .child_gap = 8,
                })({
                    Custom.HtmlText(
                        \\<strong style="color: #6439FF">Tether</strong> makes writing code more <strong style="color: #6439FF">cumbersome</strong> than <strong style="color: #6439FF">reading it!</strong>
                    , .{
                        .font_size = 18,
                    });

                    Custom.HtmlText(
                        \\<strong style="color: #6439FF">Tether</strong> is boring, even if you come back 10 years later, it'll still <strong style="color: #6439FF">work</strong>.
                    , .{
                        .font_size = 18,
                    });

                    Custom.HtmlText(
                        \\<strong style="color: #6439FF">Tether</strong> 
                        \\ aims to unite the fragmented hell of dependencies, by providing a toolkit that works as a complete framework out of the box yet remains fully modular.
                    , .{
                        .font_size = 18,
                    });
                });
                Static.FlexBox(.{
                    .height = .px(100),
                    .child_gap = 20,
                    .child_alignment = .left_center,
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
                        Static.Text("Install", .{
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
                Static.Column(.{
                    .child_alignment = .center,
                    .margin = .{ .top = 20, .bottom = 40 },
                    .child_gap = 48,
                    .width = .percent(100),
                })({
                    Static.Center(.{
                        .child_gap = 12,
                        .width = .percent(45),
                        .height = .px(48),
                        .border_radius = .all(99),
                        .border_thickness = .all(1),
                        .border_color = .hex("#EBEBEB"),
                    })({
                        // Static.Text("Tether v1.0", .{
                        //     .font_size = 20,
                        // });
                        Static.Text("version 1.0.0", .{
                            .font_size = 20,
                            .gradient = &.{},
                            .font_weight = 300,
                        });
                        Static.Icon("bi bi-arrow-right", .{
                            .font_size = 20,
                        });
                    });
                    Static.Svg(@embedFile("text.svg"), .{
                        .width = .px(270),
                    });
                    // Static.Image("/assets/Logo.svg", .{
                    //     .width = .percent(40),
                    //     .display = .Center,
                    // });
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
                    // Static.FlexBox(.{
                    //     .child_gap = 32,
                    // })({
                    //     Static.Link(.{ .url = "https://github.com/vic-Rokx/fabric", .aria_label = "redirect link to tether github repo" }, .{
                    //         .text_decoration = .none,
                    //         .height = .px(56),
                    //         .width = .px(56),
                    //         .border_thickness = .all(1),
                    //         .border_color = .hex("#EFEFEF"),
                    //         .border_radius = .all(8),
                    //         .display = .Center,
                    //     })({
                    //         Static.Icon("bi bi-github", .{
                    //             .font_size = 28,
                    //             .text_color = .hex("#252525"),
                    //         });
                    //     });
                    //     Static.Link(.{ .url = "https://github.com/vic-Rokx/fabric", .aria_label = "redirect link to discord" }, .{
                    //         .text_decoration = .none,
                    //         .height = .px(56),
                    //         .width = .px(56),
                    //         .border_thickness = .all(1),
                    //         .border_radius = .all(8),
                    //         .border_color = .hex("#EFEFEF"),
                    //         .display = .Center,
                    //     })({
                    //         Static.Icon("bi bi-discord", .{
                    //             .font_size = 28,
                    //             .text_color = .hex("#252525"),
                    //         });
                    //     });
                    // });

                    Custom.HtmlText(
                        \\The <i>Toolkit</i> for Fullstack Applications
                    , .{
                        .display = .Center,
                        .font_size = 36,
                        .font_weight = 900,
                        .text_color = .hex("#202020"),
                    });
                    Custom.HtmlText(
                        \\<strong>Tether</strong> is a  
                        \\toolkit that works as a complete framework out of the box yet remains fully modular and adaptable to your exact needs.
                    , .{
                        .display = .Center,
                        .font_size = 20,
                        .font_weight = 300,
                        .text_color = .hex("#202020"),
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
            Static.Box(.{
                .position = .{ .type = .absolute, .bottom = .percent(0), .right = .percent(0) },
                .height = .percent(10),
                .width = .percent(100),
                .child_alignment = .bottom_right,
                .direction = .column,
                .padding = .{ .right = 32 },
                .border_thickness = .{ .bottom = 1 },
                .border_color = .hex("#E4E4E4"),
            })({
                Static.Text("Trusted By", .{ .font_size = 16 });
                Static.Box(.{
                    .child_gap = 24,
                })({
                    Static.Text("NightWatch", .{ .font_size = 24 });
                    Static.Text("Heights & Minds", .{ .font_size = 24 });
                });
            });
        });
    });
    Static.Box(.{
        // .height = .percent(100),
        .width = .percent(100),
        .margin = .{ .top = 64 },
        .padding = .{ .bottom = 64 },
        .child_alignment = .{ .x = .even, .y = .start },
    })({
        Static.Column(.{
            .height = .percent(100),
            .width = .percent(40),
            .display = .Center,
        })({
            Static.Text("From Here...", .{ .font_size = 32, .font_weight = 700 });
            Static.Image("/assets/webdev.webp", .{
                .width = .percent(100),
            });
        });
        Static.Column(.{
            .height = .percent(100),
            .width = .percent(40),
            .display = .Center,
        })({
            Static.Text("To Here...", .{ .font_size = 32, .font_weight = 700 });
            Static.Image("/assets/tether.webp", .{
                .width = .percent(85),
            });
        });

        // Comparison.render();
    });
    // });
}
