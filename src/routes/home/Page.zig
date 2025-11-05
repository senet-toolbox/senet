const std = @import("std");
const Vapor = @import("vapor");
const Navbar = @import("../components/Navbar.zig");
const Signal = Vapor.Signal;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Style = Vapor.Style;
const Custom = @import("../components/Custom.zig");
const root = @import("../main.zig");
const Chain = Vapor.Chain;
const ChainPure = Pure.Chain;
const Text = Chain.Text;
const Box = Chain.Box;
const Link = Chain.Link;
const Stack = Chain.Stack;
const HtmlText = Custom.Chain.HtmlText;
const Image = Chain.Image;
const Svg = Chain.Svg;
const Center = Chain.Center;
const Icon = Chain.Icon;
const Button = Chain.Button;
const ButtonCycle = Chain.ButtonCycle;
const Graphic = Chain.Graphic;
const AllocText = ChainPure.AllocText;
const VirtualList = Pure.VirtualList;
const Theme = @import("theme");

var random: std.Random.DefaultPrng = std.Random.DefaultPrng.init(14);
var rand_num: usize = undefined;
var buffer: [10]usize = undefined;
var counter: u32 = 0;
var text: []const u8 = "Hello World";
pub fn init() void {
    counter = Vapor.lib.getPersist(u32, "counter") orelse 0;
    text = Vapor.lib.getPersist([]const u8, "text") orelse "Default";
    for (0..10) |i| {
        buffer[i] = i;
    }
    Navbar.init();
    rand_num = random.random().intRangeAtMost(usize, 1, 5);
    random.random().shuffle(usize, &buffer);
    Vapor.lib.registerLayout("/", layout);
    Vapor.Page(@src(), render, null, &.{});
}

pub fn layout(page: *const fn () void) void {
    Navbar.render();
    page();
}

pub fn shuffle() void {
    // Vapor.println("Before", .{});
    // for (buffer[0..]) |i| {
    //     Vapor.println("elem: {d}", .{i});
    // }
    random.random().shuffle(usize, &buffer);
    // Vapor.println("After", .{});
    // for (buffer[0..]) |i| {
    //     Vapor.println("elem: {d}", .{i});
    // }

    rand_num = random.random().intRangeAtMost(usize, 1, 5);
}

pub fn increment() void {
    counter += 1;
    Vapor.lib.persist("counter", counter);
    Vapor.println("count: {any}", .{counter});
}

const blocks: []const struct { title: []const u8, description: []const u8 } = &.{
    .{
        .title = "Vapor",
        .description = "Vapor is a renderer agnostic framework, and compiles down to native. No Bloat, No Build. No Runtime.",
    },
    .{
        .title = "Reverb",
        .description = "Reverb is a simple, yet powerful, backend framework for Zig. Zero runtime allocations, no GC, and lock free.",
    },
    .{
        .title = "Treehouse",
        .description = "Treehouse runs as a in memory cache at the front and a persistent database at the back. All the while boasting throughput on par with Redis.",
    },
};

pub fn render() void {
    Box.style(&.{
        .size = .hw(.percent(100), .percent(100)),
        .scroll = .none(),
        .layout = .x_even_center,
        .visual = .{ .background = .palette(.background) },
    })({
        if (Vapor.isDesktop()) {
            Stack.style(&.{
                .size = .hw(.percent(100), .mobile_desktop_percent(100, 50)),
                .child_gap = 12,
                .z_index = 10,
                .layout = .left_center,
            })({
                Stack.style(&.{
                    .size = Styles.full_width.size,
                    .child_gap = 0,
                    .margin = .t(64),
                })({
                    Box.style(&.{ .size = .w(.percent(100)), .margin = .all(0) })({
                        Text("All-in-one toolkit.").style(&Styles.big_heading)({});
                    });
                });
                Stack.style(&.{
                    .child_gap = 6,
                    .margin = .t(12),
                    .size = .w(.percent(90)),
                })({
                    HtmlText(
                        \\<strong style="color: var(--tint)">Tether</strong>
                        \\works as a complete
                        \\<i><strong style="color: var(--text_color)">framework</strong></i> out of the box yet remains fully modular.
                        \\<i><strong style="color: var(--text_color)">Swap</strong></i> the renderer, reconciler, event loop, state management, or storage system without breaking the rest.
                    ).style(&Styles.body_text);
                    HtmlText(
                        \\<strong style="color: var(--tint)">Tether</strong> uses <strong style="color: var(--text_color)"><i>Zig</i></strong> to build performant fullstack solutions, and
                        \\includes a frontend, backend, and database. Yet ships with <strong style="color: var(--text_color)"><i>zero</i></strong> dependencies.
                    ).style(&Styles.body_text);
                    HtmlText(
                        \\<strong style="color: var(--tint)">Tether</strong> is <strong style="color: var(--text_color)"><i>boring</i></strong>, even if you come back 10 years later,
                        \\it'll still <strong style="color: var(--text_color)"><i>work</i></strong>.
                    ).style(&Styles.body_text);
                });
                Box.style(&.{
                    .size = .{ .height = .px(100), .width = .percent(100) },
                    .child_gap = 20,
                    .layout = .left_center,
                })({
                    Link(.{ .url = "/huh", .aria_label = "what is tether?" }).style(&link_style.style(.dark))({
                        Text("Huh?").style(&link_style.text(.dark))({});
                    });
                    Link(.{ .url = "/install", .aria_label = "download page for tether" }).style(&link_style.style(.light))({
                        Text("Install").style(&link_style.text(.light))({});
                        Icon("bi bi-cloud-download-fill").style(&link_style.text(.light))({});
                    });
                    // AllocText("{s}", .{text}).style(&.{
                    // })({});
                    // ButtonCycle(.{ .on_press = shuffle }).style(&.{
                    //     // .id = "swap-wasm",
                    //     .layout = .center,
                    //     .size = .hw(.px(45), .px(160)),
                    //     .visual = .pill(.hex("#000000")),
                    //     .transition = .transform(),
                    //     .interactive = .hover_scale(),
                    //     .text_decoration = .none,
                    //     .child_gap = 8,
                    // })({
                    //     Text("Shuffle").style(&link_style.text(.light))({});
                    // });
                    // ButtonCycle(.{ .on_press = increment }).style(&link_style.style(.light))({
                    //     AllocText("Increment {d}", .{counter}).style(&link_style.text(.light))({});
                    // });
                });
                // Stack.style(&.{
                //     // .size = .hw(.percent(100), .percent(100)),
                // })({
                //     for (buffer[0..]) |i| {
                //         AllocText("Content {d}", .{i}).style(&.{
                //             .id = Vapor.fmtln("elem-{d}", .{i}),
                //         })({});
                //     }
                // });
            });
        }

        Box.style(&.{
            .size = .{ .width = .mobile_desktop_percent(100, 32), .height = .percent(100) },
            .direction = .column,
            .layout = .center,
        })({
            if (Vapor.isMobile()) {
                Stack.style(&.{
                    .layout = .center,
                    .margin = .tb(30, 40),
                    .child_gap = 42,
                    .size = Styles.full_width.size,
                })({
                    Center.style(&.{
                        .child_gap = 12,
                        .size = .{ .width = .percent(45), .height = .px(48) },
                        .visual = .{ .border = .solid(.all(1), .hex("#EBEBEB"), .all(99)) },
                    })({
                        Text("version 1.0.0").style(&.{
                            .visual = .{ .font_size = 20, .font_weight = 300 },
                        })({});
                        Icon("bi bi-arrow-right").style(&.{ .visual = .{ .font_size = 20 } })({});
                    });
                    // Svg(.{ .svg = @embedFile("text.svg") }).style(&.{ .size = .{ .width = .px(220) } })({});
                    Graphic(.{ .src = "src/routes/text.svg" }).style(&.{ .size = .{ .width = .px(220) } })({});
                });
            } else {
                Box.style(&.{
                    .position = .tr(.percent(4), .percent(-38), .absolute),
                    .size = .hw_percent(100, 100),
                    .visual = .{
                        .transform = .rotateXYZ(30, 0, 12),
                    },
                    .z_index = 0,
                })({
                    // Svg(.{ .svg = @embedFile("../assets/Logo.svg") }).style(&.{
                    Graphic(.{ .src = "src/assets/Logo.svg" }).style(&.{
                        .size = .square_percent(100),
                        .position = .{ .type = .absolute, .left = .percent(4), .top = .percent(0) },
                        .visual = .{ .text_color = .palette(.logo) },
                    })({});
                    // Svg(.{ .svg = @embedFile("../assets/logo_normal_animate.svg") }).style(&.{
                    Graphic(.{ .src = "src/assets/logo_normal_animate.svg" }).style(&.{
                        .size = .square_percent(100),
                        .position = .{ .type = .absolute, .left = .percent(4), .top = .percent(0) },
                        .visual = .{ .text_color = .palette(.text_color) },
                    })({});
                });
            }

            if (Vapor.isMobile()) {
                Center.style(&.{
                    .direction = .column,
                    .padding = .horizontal(12),
                    .child_gap = 16,
                    .size = Styles.full_width.size,
                })({
                    HtmlText("The <i>Toolkit</i> for Fullstack Applications").style(&.{
                        .layout = .center,
                        .visual = .font(36, 900, .palette(.text_color)),
                    });
                    HtmlText(
                        \\<strong>Tether</strong> is a
                        \\toolkit that works as a complete framework out of the box yet remains fully modular and adaptable to your exact needs.
                    ).style(&.{
                        .layout = .center,
                        .visual = .font(20, 900, .palette(.text_color)),
                    });
                });

                Box.style(&.{
                    .child_gap = 20,
                    .layout = .center,
                    .size = .hw(.px(100), .percent(100)),
                })({
                    Link(.{ .url = "/huh", .aria_label = "what is tether?" }).style(&link_style.style(.dark))({
                        Text("Huh?").style(&link_style.text(.dark))({});
                    });
                    Link(.{ .url = "/download", .aria_label = "download page for tether" }).style(&link_style.style(.light))({
                        Text("Install").style(&link_style.text(.light))({});
                        Icon("bi bi-cloud-download-fill").style(&link_style.text(.light))({});
                    });
                });
            } else {
                // Box.style(&.{
                //     .position = .br(.percent(0), .percent(0), .absolute),
                //     .size = .{ .height = .percent(10), .width = .percent(100) },
                //     .layout = .bottom_right,
                //     .direction = .column,
                //     .padding = .r(32),
                //     .visual = .{ .border = .bottom(.hex("#E4E4E4")) },
                // })({
                //     Text("Trusted By").style(&Styles.muted_text)({});
                //     Box.style(&.{ .child_gap = 24 })({
                //         Text("NightWatch").style(&Styles.subheading)({});
                //         Text("Heights & Minds").style(&Styles.subheading)({});
                //     });
                // });
            }
        });
    });

    if (Vapor.isDesktop()) {
        Box.style(&.{
            .size = .w(.percent(100)),
            .padding = .tb(64, 64),
            .layout = .x_even,
        })({
            for (blocks) |block| {
                Stack.style(&.{
                    .size = .hw_percent(100, 16),
                    .child_gap = 12,
                    .layout = .left_center,
                })({
                    Text(block.title).style(&Styles.subheading)({});
                    Text(block.description).style(&Styles.body_text)({});
                });
            }
        });

        Box.style(&.{
            .size = .w(.percent(100)),
            .padding = .tb(64, 64),
            .layout = .x_even,
        })({
            Stack.style(&.{
                .size = .hw_percent(100, 40),
                .visual = .{ .background = .palette(.image_bg) },
            })({
                Text("From Here...").style(&Styles.subheading)({});
                Graphic(.{ .src = "src/assets/webdev.svg" }).style(&.{
                    .size = .hw(.percent(100), .percent(100)),
                    .visual = .{ .text_color = .palette(.text_color) },
                })({});
            });
            Stack.style(&.{
                .size = .hw_percent(100, 40),
                .visual = .{ .background = .palette(.image_bg) },
            })({
                Text("To Here...").style(&Styles.subheading)({});
                // Image(.{ .src = "src/assets/tether.svg" }).style(&.{
                //     .size = .hw(.percent(100), .percent(100)),
                //     .visual = .{ .text_color = .palette(.text_color) },
                // })({});
                // Svg(.{ .svg = @embedFile("../assets/tether.svg") }).style(&.{
                //     .size = .hw(.percent(100), .percent(85)),
                //     .visual = .{ .text_color = .palette(.text_color) },
                // })({});
                Graphic(.{ .src = "src/assets/tether.svg" }).style(&.{
                    .size = .hw(.percent(100), .percent(85)),
                    .visual = .{ .text_color = .palette(.text_color) },
                })({});
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
        .visual = .{ .font_size = 80, .font_weight = 900 },
        .margin = .all(0),
    };

    pub const subheading = Style{ .visual = .{ .font_size = 32, .font_weight = 700 } };

    pub const body_text = Style{ .visual = .{ .font_size = 18 } };

    pub const muted_text = Style{ .visual = .{ .font_size = 16 } };

    pub const pill_button_base = Style{
        .layout = .center,
        .size = .hw(.px(45), .px(160)),
        .visual = .pill(.hex("#000000")),
        .transition = .transform(),
        .interactive = .hover_scale(),
        .text_decoration = .none,
        .child_gap = 8,
    };
};

const link_style = struct {
    pub fn style(mode: Theme.Mode) Style {
        var base = Styles.pill_button_base;
        base.extend(.{
            .visual = .when(
                mode == .dark,
                .{ .border = .pill(.palette(.text_tint_color)), .background = .palette(.alternate_background) },
                .{ .border = .pill(.palette(.alternate_border_color)), .background = .palette(.background) },
            ),
        });
        return base;
    }

    pub fn text(mode: Theme.Mode) Style {
        return Style{
            .layout = .center,
            .visual = .when(mode == .dark, .font(18, 300, .palette(.text_tint_color)), .font(18, 300, .palette(.text_color))),
        };
    }
};

pub fn style(num: usize) Style {
    var base = Styles.pill_button_base;
    base.extend(.{
        .visual = .when(
            num == 1,
            .{ .border = .pill(.hex("#262626")), .background = .hex("#ffffff") },
            .{ .border = .pill(.hex("#ffffff")), .background = .hex("#262626") },
        ),
    });
    return base;
}
