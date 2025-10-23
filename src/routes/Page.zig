const std = @import("std");
const Fabric = @import("fabric");
const Navbar = @import("../components/Navbar.zig");
const Signal = Fabric.Signal;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Style = Fabric.Style;
const Custom = @import("../components/Custom.zig");
const root = @import("../main.zig");
const Text = Static.Text;
const Box = Static.Box;
const Link = Static.Link;
const Stack = Static.Stack;
const HtmlText = Custom.Chain.HtmlText;
const Image = Static.Image;
const Svg = Static.Svg;
const Center = Static.Center;
const Icon = Static.Icon;
const Button = Static.Button;
const ButtonCycle = Static.ButtonCycle;
const Graphic = Static.Graphic;
const RedirectLink = Static.RedirectLink;
const TextFmt = Pure.TextFmt;
const List = Static.List;
const ListItem = Static.ListItem;
const VirtualList = Pure.VirtualList;
const Theme = @import("theme");
const CodeEditor = @import("../components/CodeEditor.zig");
const Animation = Fabric.lib.Animation;
//
// var random: std.Random.DefaultPrng = std.Random.DefaultPrng.init(14);
// var rand_num: usize = undefined;
// var buffer: [10]usize = undefined;
var counter: u32 = 0;
// var text: []const u8 = "Hello World";
var code_view_loc: CodeEditor = undefined;

// const slide_in: Animation = Animation.init("fadeIn", .translateY)
//     .from(100)
//     .to(0)
//     .duration(500)
//     .easing(.easeOut);
//
// const slide_out: Animation = Animation.init("fadeOut", .translateY)
//     .from(0)
//     .to(-100)
//     .duration(500)
//     .easing(.easeOut);

pub fn init() void {
    // slide_in.build();
    // slide_out.build();
    code_view_loc.init(&Fabric.lib.allocator_global, @embedFile("Component.zig"));
    // counter = Fabric.lib.getPersist(u32, "counter") orelse 0;
    // text = Fabric.lib.getPersist([]const u8, "text") orelse "Default";
    // for (0..10) |i| {
    //     buffer[i] = i;
    // }
    // // Navbar.init();
    // rand_num = random.random().intRangeAtMost(usize, 1, 5);
    // random.random().shuffle(usize, &buffer);
    Fabric.Page(@src(), render, null);
}
//
// pub fn shuffle() void {
//     // Fabric.println("Before", .{});
//     // for (buffer[0..]) |i| {
//     //     Fabric.println("elem: {d}", .{i});
//     // }
//     random.random().shuffle(usize, &buffer);
//     // Fabric.println("After", .{});
//     // for (buffer[0..]) |i| {
//     //     Fabric.println("elem: {d}", .{i});
//     // }
//
//     rand_num = random.random().intRangeAtMost(usize, 1, 5);
// }
//
pub fn increment() void {
    counter += 1;
    // Fabric.lib.persist("counter", counter);
    Fabric.printlnSrc("count: {any}", .{counter}, @src());
}
//
const blocks: []const struct { title: []const u8, description: []const u8 } = &.{
    .{
        .title = "Vapor",
        .description = "Vapor is a comptime UI framework, which compiles down to native. No Deps, No Bloat. Just one file.",
    },
    .{
        .title = "Reverb",
        .description = "Reverb is a simple, yet powerful, backend framework for Zig. Zero runtime allocations, High performance, Express like.",
    },
    .{
        .title = "Treehouse",
        .description = "Treehouse runs as a in memory cache at the front and a persistent database at the back. All the while boasting throughput on par with Redis.",
    },
};

fn boxes() void {
    // =========================================================================
    // 1. Configuration
    // =========================================================================
    const unit: f32 = 14;

    // =========================================================================
    // 2. Base Styles
    // =========================================================================
    const visual_base = Fabric.Types.Visual{
        .border = .simple(.palette(.border_color_light)),
        .font_size = 22,
        .text_color = .palette(.text_color),
        .background = .palette(.background),
        .cursor = .pointer,
    };

    const box_style_base = Style{
        .size = .hw(.px(unit * 4), .px(unit * 4)),
        .visual = visual_base,
        .layout = .center,
        .transition = .{ .duration = 100 },
        .interactive = .{
            .hover = .{
                .transform = .direction_scale(.up, 4, 1.05),
                .border = .simple(.palette(.tint)),
                .text_color = .palette(.tint),
            },
        },
    };

    const mono_text_style: Fabric.Types.Style = .{ .font_family = "IBM Plex Mono,monospace" };

    // =========================================================================
    // 3. Component-Specific Data
    // =========================================================================

    // ## Box 01 Data
    const box_1_style = box_style_base.merge(.{
        .position = .tl(.px(-unit * 4), .px(-1), .absolute),
    });
    // ## Box 02 Data
    var box_2_style = box_style_base.merge(.{
        .position = .tr(.px(unit * 28), .px(-unit * 4), .absolute),
    });
    box_2_style.interactive.?.hover.?.transform = .direction_scale(.right, 4, 1.05);
    // ## Box 03 Data
    var box_3_style = box_style_base.merge(.{
        .position = .bl(.px(-unit * 4), .px(unit * 22), .absolute),
    });
    box_3_style.interactive.?.hover.?.transform = .direction_scale(.down, 4, 1.05);

    // =========================================================================
    // 4. Render
    // =========================================================================
    Box.style(&box_1_style)({
        Text("01").style(&mono_text_style);
    });

    Box.style(&box_2_style)({
        Text("02").style(&mono_text_style);
    });

    Box.style(&box_3_style)({
        Text("03").style(&mono_text_style);
    });
}

pub fn render() void {
    // Box.style(&.{
    //     .size = .hw(.percent(100), .percent(100)),
    //     .layout = .center,
    // })({
    //     Text("Hello World").style(&.{ .visual = .font(18, 500, .palette(.text_color)), .layout = .center });
    // });
    // Box.alignment(.center).size(.hw(.percent(100), .percent(100)))
    //     .body()({
    //     Text("Hello World").font(18, 500, .palette(.text_color)).alignment(.center).close();
    // });

    // Icon(.cloud_download_fill).style(&link_style.text(.light));
    // Text("Hello World").style(&.{
    //     .visual = .font(18, 500, .palette(.text_color)),
    //     .layout = .center,
    // });
    Box.style(&.{
        .size = .hw(.percent(100), .percent(100)),
        .scroll = .none(),
        .layout = .center,
    })({
        if (Fabric.isDesktop()) {
            Stack.style(&.{
                .position = .{ .type = .relative },
                .size = .hw(.percent(60), .mobile_desktop_percent(100, 70)),
                .child_gap = 12,
                .z_index = 10,
                .layout = .center,
                .visual = .{
                    .background = .grid(14, 1, .palette(.grid_color)),
                    .border = .simple(.palette(.border_color_light)),
                },
                .padding = .horizontal(12),
            })({
                boxes();

                Text(".layout = .center, .background = .grid(14, 1, .palette(.grid_color))").style(&.{
                    .position = .{ .type = .absolute, .right = .percent(0), .top = .percent(-4) },
                    // .visual = .font(12, 500, .hex("#6f6f6f")),
                    .visual = .font(12, 500, .hex("#6f6f6f")),
                    .font_family = "IBM Plex Mono,monospace",
                });

                Text(".transform = .direction_scale(.down, .px(4), 1.05), .border = .simple(.palette(.tint)))").style(&.{
                    .position = .{ .type = .absolute, .left = .percent(32), .bottom = .percent(-4) },
                    // .visual = .font(12, 500, .hex("#6f6f6f")),
                    .visual = .font(12, 500, .hex("#6f6f6f")),
                    .font_family = "IBM Plex Mono,monospace",
                });

                Stack.style(&.{
                    .size = Styles.full_width.size,
                    .child_gap = 0,
                    .margin = .t(64),
                    .layout = .center,
                })({
                    HtmlText("<code>v1.0.0 render to web or macos</code>").style(&.{
                        .layout = .center,
                        // .visual = .font(16, 500, .hex("#6f6f6f")),
                        .visual = .font(12, 500, .hex("#6f6f6f")),
                    });
                    Box.style(&.{ .size = .w(.percent(100)), .margin = .all(0), .layout = .center })({
                        Text("All-in-one Toolkit.").style(&Styles.big_heading);
                    });
                });
                Stack.style(&.{
                    .child_gap = 16,
                    .margin = .t(12),
                    .size = .w(.percent(80)),
                    .layout = .center,
                })({
                    HtmlText(
                        \\<strong style="color: rgb(var(--tint))">Tether</strong>
                        \\includes a Frontend, Backend, and Database.
                        \\Yet ships with <strong style="color: rgb(var(--text_color))"><i>zero</i></strong> dependencies.
                    ).style(&Styles.body_text.merge(.{
                        .layout = .center,
                        .visual = .font(22, 500, .palette(.text_color)),
                    }));
                    HtmlText(
                        \\<strong style="color: rgb(var(--tint))">Build</strong> fullstack applications with just
                        \\<strong style="color: rgb(var(--text_color))"><i>Zig.</i></strong>
                    ).style(&Styles.body_text.merge(.{
                        .layout = .center,
                        .visual = .font(22, 500, .palette(.text_color)),
                    }));
                });
                Box.style(&.{
                    .size = .{ .height = .px(100), .width = .percent(100) },
                    .child_gap = 20,
                    .layout = .center,
                })({
                    Link(.{ .url = "/huh", .aria_label = "what is tether?" }).style(&link_style.style(.light))({
                        Text("Huh?").style(&link_style.text(.light));
                    });
                    Link(.{ .url = "/install", .aria_label = "download page for tether" }).style(&link_style.style(.dark).merge(.{
                        .interactive = .{ .hover = .{ .background = .palette(.tint), .transform = .scale(), .text_color = .palette(.background) } },
                    }))({
                        Text("Install").style(&link_style.text(.dark));
                        Icon(.cloud_download_fill).style(&link_style.text(.dark));
                    });
                    ButtonCycle(.{ .on_press = increment, .aria_label = "increment" }).style(&link_style.style(.light))({
                        Icon(.plus).style(&link_style.text(.light));
                        TextFmt("{d}", .{counter}).id("counter").style(&.{
                            .visual = .font(18, 700, if (counter % 2 == 0) .red else .palette(.text_color)),
                        });
                    });
                });
            });
        }
        if (counter % 2 == 0) {
            Box
                .id("box")
                // .animationEnter(&slide_in).animationExit(&slide_out)
                .pos(.{ .type = .absolute, .left = .percent(0), .bottom = .percent(0) })
                .size(.square_px(100))
                .border(.simple(.palette(.tint)))
                .body()({});
        }

        // Box.style(&.{
        //     .size = .{ .width = .mobile_desktop_percent(100, 32), .height = .percent(100) },
        //     .direction = .column,
        //     .layout = .center,
        // })({
        if (Fabric.isMobile()) {
            Stack.style(&.{
                .layout = .center,
                .margin = .t(60),
                .child_gap = 24,
                .size = .hw(.percent(100), .percent(100)),
            })({
                Center.style(&.{
                    .child_gap = 12,
                    .size = .{ .width = .percent(45), .height = .px(48) },
                    .visual = .{ .border = .solid(.all(1), .hex("#EBEBEB"), .all(99)) },
                })({
                    Text("version 1.0.0").style(&.{
                        .visual = .{ .font_size = 20, .font_weight = 300 },
                    });
                    Icon(.arrow_right).style(&.{ .visual = .{ .font_size = 20 } });
                });
                Graphic(.{ .src = "src/routes/text.svg" }).style(&.{ .size = .{ .width = .px(220) } });

                Center.style(&.{
                    .direction = .column,
                    .padding = .horizontal(12),
                    .child_gap = 16,
                    .size = .hw(.percent(40), .percent(100)),
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
                        Text("Huh?").style(&link_style.text(.dark));
                    });
                    Link(.{ .url = "/download", .aria_label = "download page for tether" }).style(&link_style.style(.light))({
                        Text("Install").style(&link_style.text(.light));
                        Icon(.cloud_download_fill).style(&link_style.text(.light));
                    });
                });
            });
        } else {
            // Box.style(&.{
            //     .position = .tr(.percent(44), .percent(-6), .absolute),
            //     .size = .hw_percent(100, 100),
            //     .visual = .{
            //         // .opacity = 0.3,
            //         // .transform = .rotateXYZ(30, 0, 12),
            //         .transform = .rotateXYZ(0, 0, 90),
            //     },
            //     .z_index = 0,
            // })({
            //     // Graphic(.{ .src = "src/assets/weird.svg" }).style(&.{
            //     //     .size = .square_percent(100),
            //     //     .position = .{ .type = .absolute, .left = .percent(4), .top = .percent(0) },
            //     //     .visual = .{ .text_color = .palette(.logo) },
            //     // })({});
            //     // Graphic(.{ .src = "src/assets/weirdcolumn.svg" }).style(&.{
            //     //     .size = .hw(.percent(8), .percent(25)),
            //     //     .position = .{ .type = .absolute, .left = .percent(0), .top = .percent(100) },
            //     //     .visual = .{ .text_color = .palette(.logo) },
            //     // })({});
            //     // Graphic(.{ .src = "src/assets/weirdcolumn.svg" }).style(&.{
            //     //     .size = .hw(.percent(8), .percent(25)),
            //     //     .position = .{ .type = .absolute, .left = .percent(30), .top = .percent(-100) },
            //     //     .visual = .{ .text_color = .palette(.logo) },
            //     // })({});
            //     // Graphic(.{ .src = "src/assets/weirdcolumnanimated.svg" }).style(&.{
            //     //     .size = .hw(.percent(8), .percent(25)),
            //     //     .position = .{ .type = .absolute, .left = .percent(0), .top = .percent(103) },
            //     //     .visual = .{ .text_color = .palette(.text_color) },
            //     // })({});
            //     // Graphic(.{ .src = "src/assets/logo_normal_animate.svg" }).style(&.{
            //     //     .size = .square_percent(100),
            //     //     .position = .{ .type = .absolute, .left = .percent(4), .top = .percent(0) },
            //     //     .visual = .{ .text_color = .palette(.text_color) },
            //     // })({});
            // });
        }

        if (Fabric.isDesktop()) {
            Box.style(&.{
                .position = .br(.percent(0), .percent(0), .absolute),
                .size = .{ .height = .percent(10), .width = .percent(100) },
                .layout = .x_between_bottom,
                .padding = .horizontal(24),
                .visual = .{ .border = .bottom(.hex("#E4E4E4")) },
            })({
                Stack.style(&.{ .layout = .bottom_left })({
                    Text("Powered By").style(&Styles.muted_text);
                    Box.style(&.{ .margin = .t(12), .layout = .x_even_center })({
                        Graphic(.{ .src = "src/assets/zig.svg" }).style(&.{
                            .size = .{ .height = .px(28), .width = .px(64) },
                            .visual = .{ .fill = .palette(.text_color), .stroke = .palette(.text_color) },
                        });
                    });
                });
                Stack.style(&.{ .layout = .bottom_right })({
                    Text("Used By").style(&Styles.muted_text);
                    Box.style(&.{ .child_gap = 12, .layout = .x_even_center })({
                        if (Theme.mode == .light) {
                            Image(.{ .src = "/assets/acorn.png" }).style(&.{
                                .id = "acorn-image-light",
                                .size = .{ .height = .px(32), .width = .percent(100) },
                            });
                        } else {
                            Image(.{ .src = "/assets/acornwhite.png" }).style(&.{
                                .id = "acorn-image-dark",
                                .size = .{ .height = .px(32), .width = .percent(100) },
                            });
                        }

                        Text("Acorn").style(&.{ .visual = .font(28, 500, .palette(.text_color)) });
                    });
                });
            });
        }
    });

    if (Fabric.isDesktop()) {
        Box.style(&.{
            .size = .w(.percent(100)),
            .padding = .tb(64, 64),
            .layout = .x_even,
        })({
            Stack.style(&.{
                .size = .hw_percent(100, 40),
                .visual = .{ .background = .palette(.image_bg) },
            })({
                Text("From Here...").style(&Styles.subheading);
                Graphic(.{ .src = "src/assets/webdev.svg" }).style(&.{
                    .size = .hw(.percent(100), .percent(100)),
                    .visual = .{ .fill = .palette(.text_color), .stroke = .palette(.text_color) },
                });
            });
            Stack.style(&.{
                .size = .hw_percent(100, 40),
                .visual = .{ .background = .palette(.image_bg) },
            })({
                Text("To Here...").style(&Styles.subheading);
                Graphic(.{ .src = "src/assets/tether.svg" }).style(&.{
                    .size = .hw(.percent(100), .percent(85)),
                    .visual = .{ .fill = .palette(.text_color), .stroke = .palette(.text_color) },
                });
            });
        });
        Box.style(&.{
            .size = .w(.percent(100)),
            .padding = .tb(64, 64),
            .layout = .x_even,
            .visual = .{ .border = .top(.hex("#E4E4E4")) },
        })({
            for (blocks) |block| {
                Stack.style(&.{
                    .size = .hw_percent(100, 16),
                    .child_gap = 12,
                    .layout = .left_center,
                })({
                    Text(block.title).style(&Styles.subheading);
                    Text(block.description).style(&Styles.body_text);
                });
            }
        });
    }

    Stack.style(&.{
        .size = .hw(.percent(30), .percent(100)),
        .layout = .center,
        .child_gap = 24,
        .visual = .{ .border = .bottom(.hex("#E4E4E4")) },
    })({
        Text("Compressed Sizes (Brotli))").style(&Styles.subheading);
        Box.style(&.{
            .size = .hw(.fit, .percent(50)),
            .layout = .x_even_center,
            .child_gap = 64,
        })({
            Box.style(&.{ .layout = .x_even_center, .size = .hw(.fit, .percent(100)) })({
                Graphic(.{ .src = "src/assets/logonormal.svg" }).style(&.{
                    .size = .w(.px(60)),
                    .visual = .{ .text_color = .palette(.text_color), .background = .transparent },
                    .transition = .{ .duration = 100 },
                    .interactive = .{ .hover = .{
                        .transform = .scale(),
                        .background = .transparent,
                        .fill = .palette(.tint),
                        .stroke = .palette(.tint),
                    } },
                });
                Text("18.6KB").style(Styles.miniheading);
            });
            Box.style(&.{ .layout = .x_even_center, .size = .hw(.fit, .percent(100)) })({
                Graphic(.{ .src = "src/assets/react.svg" }).style(&.{
                    .size = .w(.px(56)),
                });
                Text("51KB").style(Styles.miniheading);
            });
            Box.style(&.{ .layout = .x_even_center, .size = .hw(.fit, .percent(100)) })({
                Image(.{ .src = "https://dioxuslabs.com/assets/smalllogo-dxhd57fd7a7f3d2eb38.png" }).style(&.{
                    .size = .w(.px(60)),
                });
                Text("234KB").style(Styles.miniheading);
            });
            Box.style(&.{ .layout = .x_even_center, .size = .hw(.fit, .percent(100)) })({
                Image(.{ .src = "src/assets/svelte.png" }).style(&.{
                    .size = .w(.px(40)),
                });
                Text("15KB").style(Styles.miniheading);
            });
        });
    });

    Box.style(&.{
        // .size = .hw(.percent(85), .percent(100)),
        .size = .{ .width = .percent(100), .height = .fit },
        .margin = .tb(64, 64),
        .layout = if (Fabric.isMobile()) .top_center else .x_even_center,
        .direction = if (Fabric.isMobile()) .column else .row,
        .child_gap = 16,
    })({
        Box.style(&.{
            .padding = .horizontal(12),
            .size = .hw(.mobile_desktop(.fit, .percent(60)), .mobile_desktop_percent(100, 50)),
        })({
            code_view_loc.render(0);
        });
        Stack.style(&.{
            // .size = .{ .width = .mobile_desktop_percent(100, 30), .height = .fit },
            .size = .hw(.mobile_desktop(.fit, .percent(60)), .percent(40)),
            .child_gap = 24,
            .layout = .left_center,
            .padding = .horizontal(12),
        })({
            Text("Vapor Code Sample").style(&Styles.subheading);
            HtmlText(
                \\Vapor introduces <strong>no new syntax</strong> — everything you see is valid Zig.
                \\In Vapor, functions expect children and styles as arguments. We pass them with normal Zig literals
            ).style(&Styles.body_text);
            List.style(&.{
                .list_style = .circle,
            })({
                ListItem.style(&.{})({
                    HtmlText(
                        \\Empty struct literal <i style="color: rgb(var(--tint))"><code>{}</code></i> used for children.
                    ).style(&Styles.body_text);
                });
                ListItem.style(&.{})({
                    HtmlText(
                        \\Pointer to struct literal <i style="color: rgb(var(--tint))"><code>&.{}</code></i> used for styles.
                    ).style(&Styles.body_text);
                });
            });

            HtmlText(
                \\For my JS devs <i style="color: rgb(var(--tint))"><code>struct</code></i> is an enhanced object or class, we can attach functions and default values to it.
                \\In comparison to raw CSS or Tailwind, which is just strings. Here <i style="color: rgb(var(--tint))"><code>&.{}</code></i> has defaults of
                \\<i style="color: rgb(var(--tint))"><code>.layout = .top_left</code></i>, and <i style="color: rgb(var(--tint))"><code>.font_size = 16</code></i>.
            ).style(&Styles.body_text);
            HtmlText(
                \\This creates a <strong>powerful pattern</strong>, since now our <i style="color: rgb(var(--tint))">Style</i> structs can be passed to functions, instantiated with default values, and modified.
                \\We can also <i>extend</i> or <i>merge</i> two or more styles together, and they can be passed from <strong>UI</strong> to <strong>Function</strong>.
            ).style(&Styles.body_text);
        });
    });
    Box.style(&.{
        .visual = .{ .border = .top(.hex("#E4E4E4")), .background = .palette(.dark_text) },
        .size = .hw(.mobile_desktop(.fit, .percent(50)), .percent(100)),
        .layout = if (Fabric.isMobile()) .x_even else .x_even_center,
        .flex_wrap = .wrap,
        .padding = .all(12),
    })({
        Stack.style(&.{
            .child_gap = 24,
            .size = .hw(.mobile_desktop(.fit, .percent(50)), .mobile_desktop(.percent(40), .fit)),
            .padding = .vertical(12),
        })({
            Text("Community").style(Styles.miniheading);
            Stack.style(&.{ .child_gap = 16, .size = .hw(.mobile_desktop_percent(100, 50), .percent(100)) })({
                RedirectLink(.{ .url = "https://github.com/tether-labs", .aria_label = "github page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Github").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://discord.gg/tether", .aria_label = "discord page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Discord").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://youtube.com/tetherlabs", .aria_label = "youtube page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Youtube").style(&Styles.muted_text);
                });
            });
        });
        Stack.style(&.{
            .child_gap = 24,
            .size = .hw(.mobile_desktop(.fit, .percent(50)), .mobile_desktop(.percent(40), .fit)),
            .padding = .vertical(12),
        })({
            Text("Resources").style(Styles.miniheading);
            Stack.style(&.{ .child_gap = 16 })({
                RedirectLink(.{ .url = "https://docs.tether.sh", .aria_label = "docs page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Vapor Docs").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://docs.tether.sh", .aria_label = "docs page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Reverb Docs").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://docs.tether.sh", .aria_label = "docs page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Treehouse Docs").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://blog.tether.sh", .aria_label = "blog page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Blog").style(&Styles.muted_text);
                });
            });
        });
        Stack.style(&.{
            .child_gap = 24,
            .size = .hw(.mobile_desktop(.fit, .percent(50)), .mobile_desktop(.percent(40), .fit)),
            .padding = .vertical(12),
        })({
            Text("Projects").style(Styles.miniheading);
            Stack.style(&.{ .child_gap = 16 })({
                RedirectLink(.{ .url = "/acorn", .aria_label = "nightwatch page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Acorn").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://heightsandminds.org", .aria_label = "heights and minds page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Heights & Minds").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://metal.tether.sh", .aria_label = "metal page of tether" }).style(&.{
                    .visual = .{ .text_color = .palette(.text_color), .text_decoration = .none },
                    .interactive = .hover_text(.palette(.tint)),
                })({
                    Text("Metal").style(&Styles.muted_text);
                });
            });
        });

        Stack.style(&.{
            .child_gap = 24,
            .size = .hw(.mobile_desktop(.fit, .percent(50)), .mobile_desktop(.percent(40), .fit)),
            .padding = .vertical(12),
        })({
            Box.style(&.{ .child_gap = 8, .layout = .left_center })({
                Text("TETHER").style(Styles.miniheading);
                Graphic(.{ .src = "src/assets/logonormal.svg" }).style(&.{
                    .size = .{ .width = .px(38) },
                    .visual = .{ .text_color = .palette(.text_color) },
                    .layout = .center,
                });
            });
            Text("Lace up 🤘").style(&.{ .visual = .{ .font_size = 14 } });
        });
    });
}

const Styles = struct {
    pub const footer = &Style{
        .visual = .{ .border = .top(.hex("#E4E4E4")), .background = .palette(.dark_text) },
        .size = .hw(.percent(50), .percent(100)),
        .layout = if (Fabric.isMobile()) .top_center else .x_even_center,
    };

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

    pub const miniheading = &Style{ .visual = .{ .font_size = 20, .font_weight = 500 } };

    pub const body_text = Style{ .visual = .{ .font_size = 18 } };

    pub const muted_text = Style{ .visual = .{ .font_size = 16 } };

    pub const pill_button_base = Style{
        .layout = .center,
        .size = .hw(.px(45), .px(160)),
        .visual = .pill(.hex("#000000")),
        .transition = .{ .duration = 100 },
        .interactive = .hover_scale(),
        .child_gap = 8,
    };
};

const link_style = struct {
    pub fn style(mode: Theme.Mode) Style {
        var base = Styles.pill_button_base;
        base.extend(.{
            .visual = .when(
                mode == .dark,
                .{ .border = .simple(.palette(.text_tint_color)), .background = .palette(.alternate_background), .text_color = .palette(.alternate_text_color), .text_decoration = .none },
                .{ .border = .simple(.palette(.alternate_border_color)), .background = .palette(.background), .text_color = .palette(.text_color), .text_decoration = .none },
            ),
        });
        return base;
    }

    pub fn text(_: Theme.Mode) Style {
        return Style{
            .layout = .center,
            // .visual = .when(mode == .dark, .font(18, 300, .palette(.text_tint_color)), .font(18, 300, .palette(.text_color))),
        };
    }
};
