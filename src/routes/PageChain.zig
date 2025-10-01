const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Style = Fabric.Style;
const Custom = @import("../components/Custom.zig");
const Chain = Fabric.Chain;
const ChainClose = Fabric.ChainClose;
const root = @import("../main.zig");
const Text = ChainClose.Text;
const Box = Chain.Box;
const Link = Chain.Link;
const Stack = Chain.Stack;
const HtmlText = Custom.Chain.HtmlText;
const Image = Chain.Image;
const Svg = Chain.Svg;
const Center = Chain.Center;
const Icon = Chain.Icon;

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
    Fabric.Page(@src(), render, null, &Style.override(.{
        .size = .{ .width = .percent(100), .height = .percent(100) },
        .direction = .column,
        .layout = .left_center,
    }));
}

pub fn render() void {
    Center.style(&Styles.full_size)({
        if (!Fabric.isMobile()) {
            Center.style(&.{
                .size = .hw(.percent(100), .mobile_desktop_percent(100, 50)),
                .direction = .column,
                .child_gap = 12,
            })({
                Stack.style(&.{
                    .size = Styles.full_width.size,
                    .child_gap = 0,
                    .margin = .t(64),
                })({
                    Box.style(&.{ .size = .hw(.px(100), .percent(100)), .margin = .all(0) })({
                        Svg(.{ .svg = @embedFile("text.svg") }).style(&.{ .size = .w(.px(280)), .margin = .r(20) })({});
                        Text("all-in-one").style(&Styles.big_heading);
                    });
                    Text("app toolkit.").style(&Styles.big_heading);
                });
                Stack.style(&.{
                    .child_gap = 8,
                    .margin = .t(12),
                })({
                    HtmlText(
                        \\<strong style="color: #6439FF">Tether</strong> 
                        \\aims to unite the fragmented hell of dependencies, by providing a toolkit that works as a complete 
                        \\framework out of the box yet remains fully modular.
                    ).style(&Styles.body_text);
                    HtmlText(
                        \\<strong style="color: #6439FF">Tether</strong> uses Zig to build performant fullstack solutions, and
                        \\includes a frontend, backend, and database.
                    ).style(&Styles.body_text);
                    HtmlText(
                        \\<strong style="color: #6439FF">Tether</strong> is boring, even if you come back 10 years later, 
                        \\it'll still <strong style="color: #6439FF">work</strong>.
                    ).style(&Styles.body_text);
                });
                Box.style(&.{
                    .size = .{ .height = .px(100), .width = .percent(100) },
                    .child_gap = 20,
                    .layout = .left_center,
                })({
                    Link(.{ .url = "/huh", .aria_label = "what is tether?" }).style(&link_style.style(0))({
                        Text("Huh?").style(&link_style.text(0));
                    });
                    Link(.{ .url = "/download", .aria_label = "download page for tether" }).style(&link_style.style(1))({
                        Text("Install").style(&link_style.text(1));
                        Icon("bi bi-cloud-download-fill").style(&link_style.text(1))({});
                    });
                });
            });
        }

        Box.style(&.{
            .size = .{ .width = .mobile_desktop_percent(100, 40) },
            .direction = .column,
            .layout = .center,
        })({
            if (Fabric.isMobile()) {
                Stack.style(&.{
                    .layout = .center,
                    .margin = .tb(20, 40),
                    .child_gap = 48,
                    .size = Styles.full_width.size,
                })({
                    Center.style(&.{
                        .child_gap = 12,
                        .size = .{ .width = .percent(45), .height = .px(48) },
                        .visual = .{
                            .border_radius = .all(99),
                            .border_thickness = .all(1),
                            .border_color = .hex("#EBEBEB"),
                        },
                    })({
                        Text("version 1.0.0").style(&.{ .visual = .{ .font_size = 20, .gradient = &.{}, .font_weight = 300 } });
                        Icon("bi bi-arrow-right").style(&.{ .visual = .{ .font_size = 20 } })({});
                    });
                    Svg(.{ .svg = @embedFile("text.svg") }).style(&.{
                        .size = .{ .width = .px(270) },
                    })({});
                });
            } else {
                Image(.{ .src = "/assets/Logo.svg" }).style(&Styles.full_size)({});
            }

            if (Fabric.isMobile()) {
                Center.style(&.{
                    .direction = .column,
                    .padding = .horizontal(12),
                    .child_gap = 16,
                    .size = Styles.full_width.size,
                })({
                    HtmlText("The <i>Toolkit</i> for Fullstack Applications").style(&.{
                        .layout = .center,
                        .visual = .{
                            .font_size = 36,
                            .font_weight = 900,
                            .text_color = .hex("#202020"),
                        },
                    });
                    HtmlText(
                        \\<strong>Tether</strong> is a
                        \\toolkit that works as a complete framework out of the box yet remains fully modular and adaptable to your exact needs.
                    ).style(&.{
                        .layout = .center,
                        .visual = .{
                            .font_size = 20,
                            .font_weight = 300,
                            .text_color = .hex("#202020"),
                        },
                    });
                });

                Box.style(&.{
                    .child_gap = 20,
                    .layout = .center,
                    .size = .{ .width = .percent(100), .height = .px(100) },
                })({
                    Link(.{ .url = "/huh", .aria_label = "what is tether?" }).style(&link_style.style(0))({
                        Text("Huh?").style(&link_style.text(0));
                    });
                    Link(.{ .url = "/download", .aria_label = "download page for tether" }).style(&link_style.style(1))({
                        Text("Install").style(&link_style.text(1));
                        Icon("bi bi-cloud-download-fill").style(&link_style.text(1))({});
                    });
                });
            }

            if (!Fabric.isMobile()) {
                Box.style(&.{
                    .position = .br(.percent(0), .percent(0), .absolute),
                    .size = .{ .height = .percent(10), .width = .percent(100) },
                    .layout = .bottom_right,
                    .direction = .column,
                    .padding = .r(32),
                    .visual = .{ .border = .bottom(.hex("#E4E4E4")) },
                })({
                    Text("Trusted By").style(&Styles.muted_text);
                    Box.style(&.{ .child_gap = 24 })({
                        Text("NightWatch").style(&Styles.subheading);
                        Text("Heights & Minds").style(&Styles.subheading);
                    });
                });
            }
        });
    });

    if (!Fabric.isMobile()) {
        Box.style(&.{
            .size = .w(.percent(100)),
            .padding = .tb(64, 64),
            .layout = .x_even,
        })({
            Stack.style(&.{ .size = .hw_percent(100, 40) })({
                Text("From Here...").style(&Styles.subheading);
                Image(.{ .src = "/assets/webdev.webp" }).style(&.{ .size = .{ .width = .percent(100) } })({});
            });
            // Stack.style(&.{ .size = .hw_percent(100, 40) })({
            //     Text("From Here...").style(&Styles.subheading)({});
            //     Image(.{ .src = "/assets/webdev.webp" }).style(&.{ .size = .hw(.percent(100), .percent(100)) })({});
            // });
            Stack.style(&.{ .size = .hw_percent(100, 40) })({
                Text("To Here...").style(&Styles.subheading);
                Image(.{ .src = "/assets/tether.webp" }).style(&.{ .size = .{ .width = .percent(85) } })({});
            });
        });
    }
}

const Styles = struct {
    pub const full_size = Style{
        .size = .hw(.percent(100), .percent(100)),
    };

    pub const full_width = Style{
        .size = .w(.percent(100)),
    };

    pub const big_heading = Style{
        .style_id = "big-heading",
        .visual = .{ .font_weight = 900, .font_size = 90 },
        .margin = .all(0),
    };

    pub const subheading = Style{
        .visual = .{ .font_size = 32, .font_weight = 700 },
    };

    pub const body_text = Style{
        .visual = .{ .font_size = 18 },
    };

    pub const muted_text = Style{
        .visual = .{ .font_size = 16 },
    };

    pub const pill_button_base = Style{
        .layout = .center,
        .size = .hw(.px(45), .px(160)),
        .visual = .{ .border = .pill(.hex("#000000")) },
        .transition = .{
            .duration = 300,
            .properties = &.{.transform},
            .timing = .ease,
        },
        .hover = .{
            .transform = .{ .scale_size = 1.05, .type = .scale },
        },
        .text_decoration = .none,
        .child_gap = 8,
    };
};

const link_style = struct {
    pub fn style(num: usize) Style {
        var base = Styles.pill_button_base;
        base.visual.?.border.?.color = if (num == 1) .hex("#262626") else .hex("#ffffff");
        base.visual.?.background = if (num == 0) .hex("#262626") else .hex("#ffffff");
        return base;
    }

    pub fn text(num: usize) Style {
        return Style{
            .visual = .{
                .font_weight = 300,
                .font_size = 18,
                .text_color = if (num == 0) .hex("#ffffff") else .hex("#262626"),
            },
        };
    }
};

