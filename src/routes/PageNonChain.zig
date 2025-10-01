const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Navbar = @import("../components/Navbar.zig");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Style = Fabric.Style;
const Custom = @import("../components/Custom.zig");
// const Chain = Custom.Component;
const Chain = Fabric.Chain;
const root = @import("../main.zig");
const Text = Static.Text;
const Box = Static.Box;
const Link = Static.Link;
const Column = Static.Column;
const Image = Static.Image;
const Svg = Static.Svg;
const Center = Static.Center;
const Icon = Static.Icon;

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
    Fabric.Page(@src(), render, null, &Style.override(.{
        .size = .{ .width = .percent(100), .height = .percent(100) },
        .direction = .column,
        .child_alignment = .{ .y = .center, .x = .start },
    }));
}

pub fn render() void {
    Center(.{ .style = &Styles.full_size })({
        if (!Fabric.isMobile()) {
            Center(.{ .style = &.{
                .size = .{ .width = .mobile_desktop_percent(100, 50), .height = .percent(100) },
                .direction = .column,
                .child_gap = 12,
            } })({
                Column(.{ .style = &.{
                    .child_alignment = .{ .x = .start, .y = .start },
                    .size = Styles.full_width.size,
                    .child_gap = 0,
                    .margin = .{ .top = 64 },
                } })({
                    Box(.{ .style = &.{
                        .size = .{ .width = .percent(100), .height = .px(100) },
                        .margin = .all(0),
                    } })({
                        Svg(.{ .svg = @embedFile("text.svg"), .style = &.{
                            .size = .{ .width = .px(280) },
                            .margin = .{ .right = 20 },
                        } });
                        Text(.{ .text = "all-in-one", .style = &Styles.big_heading });
                    });
                    Text(.{ .text = "app toolkit.", .style = &Styles.big_heading });
                });
                Column(.{ .style = &.{
                    .child_gap = 8,
                    .margin = .{ .top = 12 },
                } })({
                    Custom.HtmlText(.{ .text = 
                        \\<strong style="color: #6439FF">Tether</strong>
                        \\ aims to unite the fragmented hell of dependencies, by providing a toolkit that works as a complete framework out of the box yet remains fully modular.
                    , .style = &Styles.body_text });
                    Custom.HtmlText(.{ .text = 
                        \\<strong style="color: #6439FF">Tether</strong> is a fullstack solution for building applications, including a frontend, backend, and database.
                    , .style = &Styles.body_text });
                    Custom.HtmlText(.{ .text = 
                        \\<strong style="color: #6439FF">Tether</strong> is boring, even if you come back 10 years later, it'll still <strong style="color: #6439FF">work</strong>.
                    , .style = &Styles.body_text });
                });
                Box(.{ .style = &.{
                    .size = .{ .height = .px(100), .width = .percent(100) },
                    .child_gap = 20,
                    .child_alignment = .left_center,
                } })({
                    Link(.{ .url = "/huh", .aria_label = "what is tether?", .style = &link_style.style(0) })({
                        Text(.{ .text = "Huh?", .style = &link_style.text(0) });
                    });
                    Link(.{ .url = "/download", .aria_label = "download page for tether", .style = &link_style.style(1) })({
                        Text(.{ .text = "Install", .style = &link_style.text(1) });
                        Icon(.{ .icon_name = "bi bi-cloud-download-fill", .style = &link_style.text(1) });
                    });
                });
            });
        }

        Box(.{ .style = &.{
            .size = .{ .width = .mobile_desktop_percent(100, 40) },
            .direction = .column,
            .child_alignment = .center,
        } })({
            if (Fabric.isMobile()) {
                Column(.{ .style = &.{
                    .child_alignment = .center,
                    .margin = .{ .top = 20, .bottom = 40 },
                    .child_gap = 48,
                    .size = Styles.full_width.size,
                } })({
                    Center(.{ .style = &.{
                        .child_gap = 12,
                        .size = .{ .width = .percent(45), .height = .px(48) },
                        .visual = .{
                            .border_radius = .all(99),
                            .border_thickness = .all(1),
                            .border_color = .hex("#EBEBEB"),
                        },
                    } })({
                        Text(.{ .text = "version 1.0.0", .style = &.{
                            .visual = .{
                                .font_size = 20,
                                .gradient = &.{},
                                .font_weight = 300,
                            },
                        } });
                        Icon(.{ .icon_name = "bi bi-arrow-right", .style = &.{
                            .visual = .{ .font_size = 20 },
                        } });
                    });
                    Svg(.{ .svg = @embedFile("text.svg"), .style = &.{
                        .size = .{ .width = .px(270) },
                    } });
                });
            } else {
                Image(.{ .src = "/assets/Logo.svg", .style = &Styles.full_size });
            }

            if (Fabric.isMobile()) {
                Center(.{ .style = &.{
                    .direction = .column,
                    .padding = .horizontal(12),
                    .child_gap = 16,
                    .size = Styles.full_width.size,
                } })({
                    Custom.HtmlText(.{ .text = 
                        \\The <i>Toolkit</i> for Fullstack Applications
                    , .style = &.{
                        .layout = .Center,
                        .visual = .{
                            .font_size = 36,
                            .font_weight = 900,
                            .text_color = .hex("#202020"),
                        },
                    } });
                    Custom.HtmlText(.{ .text = 
                        \\<strong>Tether</strong> is a
                        \\toolkit that works as a complete framework out of the box yet remains fully modular and adaptable to your exact needs.
                    , .style = &.{
                        .layout = .Center,
                        .visual = .{
                            .font_size = 20,
                            .font_weight = 300,
                            .text_color = .hex("#202020"),
                        },
                    } });
                });

                Box(.{ .style = &.{
                    .child_gap = 20,
                    .child_alignment = .center,
                    .size = .{ .width = .percent(100), .height = .px(100) },
                } })({
                    Link(.{ .url = "/huh", .aria_label = "what is tether?", .style = &link_style.style(0) })({
                        Text(.{ .text = "Huh?", .style = &link_style.text(0) });
                    });
                    Link(.{ .url = "/download", .aria_label = "download page for tether", .style = &link_style.style(1) })({
                        Text(.{ .text = "Install", .style = &link_style.text(1) });
                        Icon(.{ .icon_name = "bi bi-cloud-download-fill", .style = &link_style.text(1) });
                    });
                });
            }

            if (!Fabric.isMobile()) {
                Box(.{ .style = &.{
                    .position = .{ .type = .absolute, .bottom = .percent(0), .right = .percent(0) },
                    .size = .{ .height = .percent(10), .width = .percent(100) },
                    .child_alignment = .bottom_right,
                    .direction = .column,
                    .padding = .{ .right = 32 },
                    .visual = .{
                        .border_thickness = .{ .bottom = 1 },
                        .border_color = .hex("#E4E4E4"),
                    },
                } })({
                    Text(.{ .text = "Trusted By", .style = &Styles.muted_text });
                    Box(.{ .style = &.{
                        .child_gap = 24,
                    } })({
                        Text(.{ .text = "NightWatch", .style = &Styles.subheading });
                        Text(.{ .text = "Heights & Minds", .style = &Styles.subheading });
                    });
                });
            }
        });
    });

    if (!Fabric.isMobile()) {
        Box(.{ .style = &.{
            .size = Styles.full_width.size,
            .margin = .{ .top = 64 },
            .padding = .{ .bottom = 64 },
            .child_alignment = .x_even,
        } })({
            Column(.{ .style = &.{
                .size = .{ .height = .percent(100), .width = .percent(40) },
                .layout = .Center,
            } })({
                Text(.{ .text = "From Here...", .style = &Styles.subheading });
                Image(.{ .src = "/assets/webdev.webp", .style = &Styles.full_width });
            });
            Column(.{ .style = &.{
                .size = .{ .height = .percent(100), .width = .percent(40) },
                .layout = .Center,
            } })({
                Text(.{ .text = "To Here...", .style = &Styles.subheading });
                Image(.{ .src = "/assets/tether.webp", .style = &.{
                    .size = .{ .width = .percent(85) },
                } });
            });
        });
    }
}

const Styles = struct {
    pub const full_size = Style{
        .size = .{ .width = .percent(100), .height = .percent(100) },
    };

    pub const full_width = Style{
        .size = .{ .width = .percent(100) },
    };

    pub const col_center = Style{
        .direction = .column,
        .child_alignment = .center,
    };

    pub const row_center = Style{
        .direction = .row,
        .child_alignment = .center,
    };

    pub const big_heading = Style{
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
        .layout = .Center,
        .size = .{ .width = .px(160), .height = .px(45) },
        .visual = .{
            .border = .{
                .radius = .all(99),
                .thickness = .all(1),
            },
        },
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
