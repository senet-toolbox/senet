const std = @import("std");
const Vapor = @import("vapor");
const Navbar = @import("../components/Navbar.zig");
const Signal = Vapor.Signal;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Style = Vapor.Style;
const Custom = @import("../components/Custom.zig");
const root = @import("../main.zig");
const Text = Static.Text;
const Box = Static.Box;
const Link = Static.Link;
const Stack = Static.Stack;
const Html = Vapor.Html;
const Image = Static.Image;
const Center = Static.Center;
const Icon = Static.Icon;
const Button = Static.Button;
const Graphic = Static.Graphic;
const RedirectLink = Static.RedirectLink;
const TextFmt = Static.TextFmt;
const List = Static.List;
const ListItem = Static.ListItem;
const Hooks = Static.Hooks;
const VirtualList = Pure.VirtualList;
const Theme = @import("theme");
const CodeEditor = @import("../components/CodeEditor.zig");
const Animation = Vapor.lib.Animation;
const Video = Vapor.Video;
const CtxButton = Static.CtxButton;
const Compiler = @import("../main.zig");
const Vaporize = @import("vaporize");
const SyntaxHighlighter = Vaporize.SyntaxHighlighter;
const ComplexForm = @import("VaporizeComplexForm.zig");

var counter: i32 = 0;
var code_view_loc: CodeEditor = undefined;
var highlighter: SyntaxHighlighter = undefined;
var form_highlighter: SyntaxHighlighter = undefined;
var reverb_highlighter: SyntaxHighlighter = undefined;
var reverb_middleware_highlighter: SyntaxHighlighter = undefined;
var canopy_highlighter: SyntaxHighlighter = undefined;
var websocket_highlighter: SyntaxHighlighter = undefined;
var complex_form_highlighter: SyntaxHighlighter = undefined;
var react_form_highlighter: SyntaxHighlighter = undefined;
var react_form_highlighter_modern: SyntaxHighlighter = undefined;

fn decrement() void {
    counter -= 1;
}

// Render
pub fn sample() void {
    Stack()
        .layout(.center)
        .width(.percent(80)).height(.percent(100))
        .spacing(16)
        .children({
        Box()
            .layout(.x_even_center)
            .width(.percent(100)).height(.percent(30)).children({
            // Chaining styles
            Button(.{ .on_press = increment })
                .border(.simple(.palette(.text_color)))
                .duration(100)
                .hoverScale()
                .padding(.all(8))
                .width(.percent(30))
                .layer(.dot(0.5, 8, .palette(.text_color)))
                .height(.fit)
                .shadow(.card(.palette(.text_color)))
                .children({
                Text("+").font(36, 300, .palette(.text_color)).end();
            });
            Text(counter)
                .font(72, 700, .palette(.tint))
                .center()
                .width(.percent(40))
                .fontFamily("IBM Plex Mono,monospace")
                .end();
            Button(.{ .on_press = decrement })
                .border(.simple(.palette(.text_color)))
                .duration(100)
                .hoverScale()
                .padding(.all(8))
                .layer(.dot(0.5, 8, .palette(.text_color)))
                .width(.percent(30))
                .height(.fit)
                .shadow(.card(.palette(.text_color)))
                .children({
                Text("-").font(36, 300, .palette(.text_color)).end();
            });
        });
    });
}

pub fn init() void {
    const allocator = Vapor.arena(.persist);

    highlighter = SyntaxHighlighter.init(allocator);
    highlighter.use_cpy_btn = false;
    highlighter.parse(@embedFile("Component.zig")) catch unreachable;

    form_highlighter = SyntaxHighlighter.init(allocator);
    form_highlighter.use_cpy_btn = false;
    form_highlighter.parse(@embedFile("Form.zig")) catch unreachable;

    reverb_highlighter = SyntaxHighlighter.init(allocator);
    reverb_highlighter.use_cpy_btn = false;
    reverb_highlighter.parse(@embedFile("Reverb.zig")) catch unreachable;

    reverb_middleware_highlighter = SyntaxHighlighter.init(allocator);
    reverb_middleware_highlighter.use_cpy_btn = false;
    reverb_middleware_highlighter.parse(@embedFile("ReverbMiddleware.zig")) catch unreachable;

    websocket_highlighter = SyntaxHighlighter.init(allocator);
    websocket_highlighter.use_cpy_btn = false;
    websocket_highlighter.parse(@embedFile("Websocket.zig")) catch unreachable;

    complex_form_highlighter = SyntaxHighlighter.init(allocator);
    complex_form_highlighter.use_cpy_btn = false;

    react_form_highlighter = SyntaxHighlighter.init(allocator);
    react_form_highlighter.use_cpy_btn = false;

    react_form_highlighter_modern = SyntaxHighlighter.init(allocator);
    react_form_highlighter_modern.use_cpy_btn = false;

    Vapor.Kit.fetch("/src/routes/VaporizeComplexForm.zig", handlePageForm, .{ .method = .GET });
    Vapor.Kit.fetch("/src/routes/ReactComplexForm.tsx", handlePageReactForm, .{ .method = .GET });
    Vapor.Kit.fetch("/src/routes/ReactComplexFormModern.tsx", handlePageReactFormModern, .{ .method = .GET });

    ComplexForm.init();
    login_form.compile() catch unreachable;
}

fn handlePageForm(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .ok => |data| {
            complex_form_highlighter.parse(data.body) catch unreachable;
        },
        .err => |err| {
            Vapor.printErr("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.cycle();
}

fn handlePageReactForm(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .ok => |data| {
            react_form_highlighter.parse(data.body) catch unreachable;
        },
        .err => |err| {
            Vapor.printErr("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.cycle();
}

fn handlePageReactFormModern(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .ok => |data| {
            react_form_highlighter_modern.parse(data.body) catch unreachable;
        },
        .err => |err| {
            Vapor.printErr("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.cycle();
}

pub fn increment() void {
    counter += 1;
    Vapor.printlnSrc("count: {any}", .{counter}, @src());
}

const blocks: []const struct { title: []const u8, description: []const u8 } = &.{
    .{
        .title = "Vapor",
        .description = "Is a Comptime UI Engine in Zig. Vapor generates native HTML, Objc, from one codebase. <div>ZIG → WASM → UI</div>",
    },
    .{
        .title = "Reverb",
        .description = "Is a simple, yet powerful, backend framework for Zig. Zero runtime allocations, High performance, Express like.",
    },
    .{
        .title = "Canopy",
        .description = "Runs as a in memory cache at the front and a persistent database at the back. All the while boasting throughput on par with Redis.",
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
    const visual_base = Vapor.Types.Visual{
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

    const mono_text_style: Vapor.Types.Style = .{ .font_family = "IBM Plex Mono,monospace" };

    // =========================================================================
    // 3. Component-Specific Data
    // =========================================================================

    // ## Box() 01 Data
    const box_1_style = box_style_base.merge(.{
        .position = .tl(.px(-unit * 4), .px(-1), .absolute),
    });
    // ## Box() 02 Data
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
    Box().style(&box_1_style)({
        Text("01").style(&mono_text_style);
    });

    Box().style(&box_2_style)({
        Text("02").style(&mono_text_style);
    });

    Box().style(&box_3_style)({
        Text("03").style(&mono_text_style);
    });
}

var text: []const u8 = "";

var binded_textfield: Vapor.Binded = .{};

fn log(evt: *Vapor.Event) void {
    Vapor.println("From binded Text: {s}", .{evt.text()});
}
var likes: usize = 0;
fn like() void {
    likes += 1;
}
pub fn render() void {
    Box().style(&.{
        .size = .hw(.percent(100), .percent(100)),
        .scroll = .none(),
        .layout = .center,
    })({
        if (Vapor.isDesktop()) {
            Stack().style(&.{
                .position = .{ .type = .relative, .z_index = 10 },
                .size = .hw(.percent(60), .mobile_desktop_percent(100, 70)),
                .child_gap = 12,
                .layout = .center,
                .visual = .{
                    .layer = .grid(14, 1, .palette(.grid_color)),
                    .border = .simple(.palette(.border_color_light)),
                },
                .padding = .horizontal(12),
            })({
                boxes();

                Text(".layout = .center, .layer = .grid(14, 1, .palette(.grid_color))").style(&.{
                    .position = .{ .type = .absolute, .right = .percent(0), .top = .percent(-4) },
                    .visual = .font(12, 500, .hex("#6f6f6f")),
                    .font_family = "IBM Plex Mono,monospace",
                });

                Text(".transform = .direction_scale(.down, .px(4), 1.05), .border = .simple(.palette(.tint)))").style(&.{
                    .position = .{ .type = .absolute, .left = .percent(32), .bottom = .percent(-4) },
                    .visual = .font(12, 500, .hex("#6f6f6f")),
                    .font_family = "IBM Plex Mono,monospace",
                });

                Stack().style(&.{
                    .size = Styles.full_width.size,
                    .child_gap = 0,
                    .margin = .t(64),
                    .layout = .center,
                })({
                    Html("<code>vapor rendered in 0.6ms</code>").style(&.{
                        .layout = .center,
                        .visual = .font(12, 500, .hex("#6f6f6f")),
                    });
                    Box().style(&.{ .size = .w(.percent(100)), .margin = .all(0), .layout = .center })({
                        Html("A <i style=\"color: rgb(var(--tint))\">toolbox</i> for the Web").style(&Styles.big_heading);
                    });
                });
                Stack().style(&.{
                    .child_gap = 16,
                    .margin = .t(12),
                    .size = .w(.percent(80)),
                    .layout = .center,
                })({
                    Html(
                        \\<strong style="color: rgb(var(--tint))">Tether</strong>
                        \\includes a <a style="text-decoration: none; color: rgb(var(--text_color));" href="/docs/vapor"><i>Frontend [0]</i></a>, 
                        \\<a style="text-decoration: none; color: rgb(var(--text_color)); "href="/docs/vapor"><i>Backend [1]</i></a>, and 
                        \\<a style="text-decoration: none; color: rgb(var(--text_color)); "href="/docs/vapor"><i>Database [2]</i></a>.
                        \\Yet ships with <strong style="color: rgb(var(--text_color))"><i>zero</i></strong> dependencies.
                    ).style(&Styles.body_text.merge(.{
                        .layout = .center,
                        .visual = .font(20, 500, .palette(.text_color)),
                    }));
                    Html(
                        \\<strong style="color: rgb(var(--tint))">Out the Box</strong> production defaults, and
                        \\<strong style="color: rgb(var(--text_color))"><i>+100 UI Components</i></strong>.
                    ).style(&Styles.body_text.merge(.{
                        .layout = .center,
                        .visual = .font(20, 500, .palette(.text_color)),
                    }));
                });
                Box().style(&.{
                    .size = .{ .height = .px(100), .width = .percent(100) },
                    .child_gap = 20,
                    .layout = .center,
                })({
                    Link(.{ .url = "/huh", .aria_label = "what is tether?" })
                        .style(&link_style.style(.light))({
                        Text("Huh?").style(&link_style.text(.light));
                    });
                    Link(.{ .url = "/install", .aria_label = "download page for tether" }).style(&link_style.style(.dark).merge(.{
                        .interactive = .{ .hover = .{ .background = .palette(.tint), .transform = .scale(), .text_color = .palette(.background) } },
                    }))({
                        Text("Install").style(&link_style.text(.dark));
                        Icon(.cloud_download_fill).style(&link_style.text(.dark));
                    });
                });
                Html(
                    \\<strong style="color: rgb(var(--text_color))">THIS</strong>
                    \\entire website, is just a mere
                    \\<strong style="color: rgb(var(--text_color))"><i>180kb</i></strong>
                    \\.
                ).style(&Styles.body_text.merge(.{
                    .layout = .center,
                    .visual = .font(14, 500, .hex("#6f6f6f")),
                }));
            });
        }
        if (Vapor.isMobile()) {
            Stack().style(&.{
                .layout = .center,
                .margin = .t(60),
                .child_gap = 24,
                .size = .hw(.percent(100), .percent(100)),
            })({
                Center().style(&.{
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

                Center().style(&.{
                    .direction = .column,
                    .padding = .horizontal(12),
                    .child_gap = 16,
                    .size = .hw(.percent(40), .percent(100)),
                })({
                    Html("The <i>Toolkit</i> for Fullstack Applications").style(&.{
                        .layout = .center,
                        .visual = .font(36, 900, .palette(.text_color)),
                    });
                    Html(
                        \\<strong>Tether</strong> is a
                        \\toolkit that works as a complete framework out of the box yet remains fully modular and adaptable to your exact needs.
                    ).style(&.{
                        .layout = .center,
                        .visual = .font(20, 900, .palette(.text_color)),
                    });
                });

                Box().style(&.{
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
        }

        if (Vapor.isDesktop()) {
            Box().style(&.{
                .position = .br(.percent(0), .percent(0), .absolute),
                .size = .{ .height = .percent(10), .width = .percent(100) },
                .layout = .x_between_bottom,
                .padding = .horizontal(24),
                .visual = .{ .border = .bottom(.hex("#E4E4E4")) },
            })({
                Stack().style(&.{ .layout = .bottom_left })({
                    Text("Powered By").style(&Styles.muted_text);
                    Box().style(&.{ .margin = .t(12), .layout = .x_even_center })({
                        Graphic(.{ .src = "src/assets/zig.svg" }).style(&.{
                            .size = .{ .height = .px(28), .width = .px(64) },
                            .visual = .{ .fill = .palette(.text_color), .stroke = .palette(.text_color) },
                        });
                    });
                });
                Stack().style(&.{ .layout = .bottom_right })({
                    Text("Used By").style(&Styles.muted_text);
                    Box().style(&.{ .child_gap = 12, .layout = .x_even_center })({
                        if (Theme.mode == .light) {
                            Image(.{ .src = "/assets/acorn.png", .alt = "acorn" })
                                .style(&.{
                                .id = "acorn-image-light",
                                .size = .{ .height = .px(32), .width = .percent(100) },
                            });
                        } else {
                            Image(.{ .src = "/assets/acornwhite.png", .alt = "acorn" }).style(&.{
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

    if (Vapor.isDesktop()) {
        Box().style(&.{
            .size = .hw(.percent(100), .percent(100)),
            .layout = .center,
            .visual = .{
                .layer = .grid(14, 1, .palette(.grid_color)),
            },
            // .layout = .x_even,
        })({
            Stack().style(&.{
                .size = .hw_percent(60, 60),
            })({
                Graphic(.{ .src = "/src/assets/tether.svg" }).style(&.{
                    .size = .hw(.percent(100), .percent(100)),
                });
            });
        });
        Box().style(&.{
            .size = .hw(.percent(70), .percent(100)),
            .padding = .tb(64, 64),
            .layout = .x_even_center,
            .position = .relative,
            .visual = .{
                .border = .tb(.palette(.border_color_light)),
            },
        })({
            Text(".width(.percent(100)).padding(.tb(64, 64)).layout(.x_even).border(.top(.hex(\"#E4E4E4\")))").style(&.{
                .position = .{ .type = .absolute, .left = .percent(1), .top = .percent(1) },
                .visual = .font(12, 500, .hex("#6f6f6f")),
                .font_family = "IBM Plex Mono,monospace",
            });

            for (blocks) |block| {
                Stack().style(&.{
                    .size = .hw(.percent(40), .percent(16)),
                    .child_gap = 12,
                    // .layout = .left_center,
                })({
                    Text(block.title).font(72, 700, .palette(.text_color)).end();
                    Html(block.description).style(&.{
                        .visual = .font(18, 500, .palette(.text_color)),
                    });
                });
            }
        });
    }

    // ---------------------------------------------------------------------------------------------
    // Content
    // ---------------------------------------------------------------------------------------------
    Box().style(&.{
        .size = .{ .width = .percent(100), .height = .percent(90) },
        .margin = .tb(64, 64),
        .layout = if (Vapor.isMobile()) .top_center else .x_even_center,
        .direction = if (Vapor.isMobile()) .column else .row,
        .child_gap = 16,
        .position = .relative,
    })({
        Text(".dots(0.5, 8, .black).shadow(.card(.black))").style(&.{
            .position = .br(.px(-60), .percent(1), .absolute),
            .visual = .font(12, 500, .hex("#6f6f6f")),
            .font_family = "IBM Plex Mono,monospace",
        });
        Box()
            .scroll(.scroll_y())
            .padding(.horizontal(12))
            .size(.hw(.mobile_desktop(.fit, .percent(60)), .mobile_desktop_percent(100, 40)))
            .border(.simple(.palette(.text_color)))
            .children({
            highlighter.render() catch unreachable;
        });
        Stack().style(&.{
            .size = .hw(.mobile_desktop(.fit, .percent(60)), .percent(40)),
            .child_gap = 24,
            .layout = .left_center,
            .padding = .horizontal(12),
        })({
            Box().spacing(16).width(.percent(100)).layout(.center).children({
                Text("Vapor Code Sample").style(&Styles.subheading);
            });
            Html(
                \\Vapor lets you build user interfaces using a simple, <strong>what you see is what you get</strong> approach. 
                \\The code on the left shows two core concepts that make Vapor special: <i style="color: rgb(var(--tint))">automatic UI updates</i>
                \\ and <i style="color: rgb(var(--tint))">flexible styling</i>.
            ).style(&Styles.body_text);
            List().style(&.{
                .list_style = .circle,
            })({
                ListItem().style(&.{})({
                    Html(
                        \\Notice how the counter updates? 
                        \\We use a plain variable <i style="color: rgb(var(--tint))"><code>counter</code></i> 
                        \\for the state, <strong>no special hooks or functions.</strong> <i style="color: rgb(var(--tint))"><code>Text</code></i>
                        \\automatically updates when <i style="color: rgb(var(--tint))"><code>counter</code></i> changes.
                    ).style(&Styles.body_text);
                });
            });

            Html(
                \\The <i style="color: rgb(var(--tint))"><code>Inline Style</code></i> Method (Chaining) For quick or unique styles, you can "chain" 
                \\modifiers directly onto the component. This is fast, readable, and keeps the styles right next to the component they affect.
            ).style(&Styles.body_text);

            Center().width(.percent(100)).height(.percent(30)).children({
                sample();
            });
        });
    });

    // ---------------------------------------------------------------------------------------------
    // Vaporization
    // ---------------------------------------------------------------------------------------------
    Stack().style(&.{
        .size = .{ .width = .percent(100), .height = .percent(90) },
        .visual = .{ .border = .top(.palette(.border_color_light)) },
        .layout = .center,
        .child_gap = 32,
    })({
        Stack().width(.percent(80)).spacing(16).layout(.center).children({
            Text("Vaporization").font(64, 700, .palette(.text_color)).end();
            Html(
                \\Vaporization is a tool that allows you to generate UI from a 
                \\<i style="color: rgb(var(--tint))"><code>struct</code></i>
                \\or other data types, like 
                \\<i style="color: rgb(var(--tint))"><code>strings</code></i>,
                \\<i style="color: rgb(var(--tint))"><code>numbers</code></i>, and
                \\<i style="color: rgb(var(--tint))"><code>arrays</code></i>, or even
                \\<i style="color: rgb(var(--tint))"><code>markdown</code></i>.
            ).style(&Styles.body_text);
        });

        Box().style(&.{
            .size = .{ .width = .percent(100), .height = .percent(60) },
            .layout = if (Vapor.isMobile()) .top_center else .x_even_center,
            .direction = if (Vapor.isMobile()) .column else .row,
        })({
            Center().width(.percent(40)).height(.percent(100))
                .scroll(.scroll_y())
                .border(.simple(.palette(.text_color)))
                .children({
                form_highlighter.render() catch unreachable;
            });
            Center().width(.percent(40)).height(.fit).children({
                form();
            });
        });
    });
    // ---------------------------------------------------------------------------------------------
    // Reverb
    // ---------------------------------------------------------------------------------------------
    Stack().style(&.{
        .size = .{ .width = .percent(100), .height = .percent(60) },
        .visual = .{ .border = .top(.palette(.border_color_light)) },
        .layout = .center,
        .child_gap = 32,
    })({
        Box().style(&.{
            .size = .{ .width = .percent(100), .height = .percent(80) },
            .layout = if (Vapor.isMobile()) .top_center else .x_even_center,
            .direction = if (Vapor.isMobile()) .column else .row,
        })({
            Center().width(.percent(40)).height(.percent(100)).children({
                Stack().width(.percent(100)).spacing(16).layout(.center).children({
                    Text("Reverb")
                        .font(64, 700, .palette(.text_color))
                        .end();
                    Html(
                        \\Reverb is a backend web framework that is built on top of
                        \\<i style="color: rgb(var(--tint))"><code>Loom</code></i>.
                    ).style(&Styles.body_text);
                    Html(
                        \\<i style="color: rgb(var(--tint))"><code>Reverb</code></i>,
                        \\has a focus on performance, built-in defaults, and a simple API.
                    ).style(&Styles.body_text);
                    Graphic(.{ .src = "/assets/website.svg" }).style(&.{
                        .size = .{ .width = .percent(80), .height = .percent(100) },
                        .visual = .{ .fill = .palette(.text_color) },
                        .transition = .{ .duration = 100 },
                        .interactive = .{ .hover = .{ .fill = .palette(.tint) } },
                    });
                });
            });
            Center().width(.percent(40)).height(.percent(100))
                .scroll(.scroll_y())
                .border(.simple(.palette(.text_color)))
                .children({
                reverb_highlighter.render() catch unreachable;
            });
        });
    });
    Stack().style(&.{
        .size = .{ .width = .percent(100), .height = .percent(90) },
        .visual = .{ .border = .top(.palette(.border_color_light)) },
        .layout = .center,
        .child_gap = 32,
    })({
        Box().style(&.{
            .size = .{ .width = .percent(100), .height = .percent(80) },
            .layout = if (Vapor.isMobile()) .top_center else .x_even_center,
            .direction = if (Vapor.isMobile()) .column else .row,
        })({
            Center().width(.percent(40)).height(.percent(100)).children({
                Stack().width(.percent(100)).spacing(16).layout(.center).children({
                    Text("Simple Routing & Powerful Middleware").font(64, 700, .palette(.text_color)).end();
                    Html(
                        \\Send data to client, and database with one liners. Automatic handling of errors, middleware, and more.
                    ).style(&Styles.body_text);
                });
            });
            Center().width(.percent(40)).height(.percent(100))
                .scroll(.scroll_y())
                .border(.simple(.palette(.text_color)))
                .children({
                reverb_middleware_highlighter.render() catch unreachable;
            });
        });
    });

    Stack().style(&.{
        .size = .{ .width = .percent(100), .height = .percent(90) },
        .visual = .{ .border = .top(.palette(.border_color_light)) },
        .layout = .center,
        .child_gap = 32,
    })({
        Box().style(&.{
            .size = .{ .width = .percent(100), .height = .percent(80) },
            .layout = if (Vapor.isMobile()) .top_center else .x_even_center,
            .direction = if (Vapor.isMobile()) .column else .row,
        })({
            Center().width(.percent(40)).height(.percent(100)).children({
                Stack().width(.percent(100)).spacing(16).layout(.center).children({
                    Text("Builtin WebSockets").font(64, 700, .palette(.text_color)).end();
                    Html(
                        \\Setup websockets with ease, and use them to communicate with anyone.
                    ).style(&Styles.body_text);
                });
            });
            Center().width(.percent(40)).height(.percent(100))
                .scroll(.scroll_y())
                .border(.simple(.palette(.text_color)))
                .children({
                websocket_highlighter.render() catch unreachable;
            });
        });
    });

    Stack()
        .layout(.center)
        .width(.percent(100))
        .spacing(64)
        .height(.percent(100))
        .pos(.relative)
        .layer(.grid(14, 1, .palette(.grid_color)))
        .baseStyle(&Vapor.Types.Style{
            .visual = .{
                .border = .solid(.tb(1), .palette(.border_color_light), .all(0)),
            },
        })
        .children({
        Stack().width(.percent(80)).spacing(16).layout(.center).children({
            Text("Vapor/React Form Comparison").font(64, 700, .palette(.text_color)).end();
            Html(
                \\Below is a code line comparison of a Vapor form, and a React form.
                \\The React version uses Zod, React-Hook Form, and shadcn/ui.
            ).style(&Styles.body_text);
        });
        Box()
            .width(.percent(100))
            .height(.percent(60))
            .layout(.x_even_center)
            .children({
            Stack().width(.percent(40)).height(.percent(100))
                .layout(.center)
                .spacing(16)
                .children({
                Text("Vaporize ~120 lines").font(20, 700, .palette(.text_color)).end();
                Center().width(.percent(100)).height(.percent(100))
                    .scroll(.scroll_y())
                    .border(.simple(.palette(.text_color)))
                    .children({
                    complex_form_highlighter.render() catch unreachable;
                });
            });

            Stack().width(.percent(40)).height(.percent(100))
                .layout(.center)
                .spacing(16)
                .children({
                Text("React, Shadcn, Zod, React-Hook Form, ~450 Lines").font(20, 700, .palette(.text_color)).end();
                Center().width(.percent(100)).height(.percent(100))
                    .scroll(.scroll_y())
                    .border(.simple(.palette(.text_color)))
                    .children({
                    react_form_highlighter_modern.render() catch unreachable;
                });
            });
        });
    });

    Stack()
        .layout(.center)
        .width(.percent(100))
        .spacing(16)
        .margin(.tb(64, 64))
        .pos(.relative)
        .children({
        Stack().width(.percent(80)).spacing(16).layout(.center).children({
            Text("Resulting UI").font(64, 700, .palette(.text_color)).end();
            Html(
                \\Below is the resulting UI, of the React and Vapor forms.
            ).style(&Styles.body_text);
        });
        Stack()
            // .layout(.top_center)
            .width(.percent(40))
            .children({
            ComplexForm.LoginComponent();
        });
    });

    // ---------------------------------------------------------------------------------------------
    // Footer
    // ---------------------------------------------------------------------------------------------
    Box().style(&.{
        .visual = .{
            .border = .top(.palette(.border_color_light)),
            .layers = &.{
                .grid(14, 1, .hex("262626")),
                .gradient(.linear, .deg(145), &.{ .hex("#0d0d0d"), .hex("#0d0d0d"), .hex("#1a1a1a"), .hex("#0a0a0a") }),
            },
        },
        .size = .hw(.mobile_desktop(.fit, .percent(50)), .percent(100)),
        .layout = if (Vapor.isMobile()) .x_even else .x_even_center,
        .flex_wrap = .wrap,
        .padding = .all(12),
    })({
        Stack().style(&.{
            .child_gap = 24,
            .size = .hw(.mobile_desktop(.fit, .percent(50)), .mobile_desktop(.percent(40), .fit)),
            .padding = .vertical(12),
        })({
            Text("Community").font(18, 100, .white).end();
            Stack().style(&.{ .child_gap = 16, .size = .hw(.mobile_desktop_percent(100, 50), .percent(100)) })({
                RedirectLink(.{ .url = "https://github.com/tether-labs", .aria_label = "github page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Github").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://discord.gg/tether", .aria_label = "discord page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Discord").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://youtube.com/tetherlabs", .aria_label = "youtube page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Youtube").style(&Styles.muted_text);
                });
            });
        });
        Stack().style(&.{
            .child_gap = 24,
            .size = .hw(.mobile_desktop(.fit, .percent(50)), .mobile_desktop(.percent(40), .fit)),
            .padding = .vertical(12),
        })({
            Text("Resources").font(18, 100, .white).end();
            Stack().style(&.{ .child_gap = 16 })({
                RedirectLink(.{ .url = "https://docs.tether.sh", .aria_label = "docs page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Vapor Docs").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://docs.tether.sh", .aria_label = "docs page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Reverb Docs").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://docs.tether.sh", .aria_label = "docs page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Canopy Docs").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://blog.tether.sh", .aria_label = "blog page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Blog").style(&Styles.muted_text);
                });
            });
        });
        Stack().style(&.{
            .child_gap = 24,
            .size = .hw(.mobile_desktop(.fit, .percent(50)), .mobile_desktop(.percent(40), .fit)),
            .padding = .vertical(12),
        })({
            Text("Projects").font(18, 100, .white).end();
            Stack().style(&.{ .child_gap = 16 })({
                RedirectLink(.{ .url = "/acorn", .aria_label = "nightwatch page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Acorn").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://heightsandminds.org", .aria_label = "heights and minds page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Heights & Minds").style(&Styles.muted_text);
                });
                RedirectLink(.{ .url = "https://metal.tether.sh", .aria_label = "metal page of tether" }).style(&.{
                    .visual = .{ .text_color = .white, .text_decoration = .none },
                })({
                    Text("Metal").style(&Styles.muted_text);
                });
            });
        });

        Stack().style(&.{
            .child_gap = 24,
            .size = .hw(.mobile_desktop(.fit, .percent(50)), .mobile_desktop(.percent(40), .fit)),
            .padding = .vertical(12),
        })({
            Box().style(&.{ .child_gap = 8, .layout = .left_center })({
                Text("TETHER").font(18, 100, .white).end();
                Graphic(.{ .src = "src/assets/logonormal.svg" }).style(&.{
                    .size = .{ .width = .px(38) },
                    .visual = .{ .text_color = .white, .fill = .white },
                    .layout = .center,
                });
            });
            Text("Lace up 🤘").style(&.{ .visual = .{ .font_size = 14, .text_color = .white } });
        });
    });
}

const Styles = struct {
    pub const footer = &Style{
        .visual = .{ .border = .top(.hex("#E4E4E4")), .background = .palette(.dark_text) },
        .size = .hw(.percent(50), .percent(100)),
        .layout = if (Vapor.isMobile()) .top_center else .x_even_center,
    };

    pub const full_size = Style{
        .size = .hw(.percent(100), .percent(100)),
    };

    pub const full_width = Style{
        .size = .w(.percent(100)),
    };

    pub const big_heading = Style{
        .style_id = "big-heading",
        .visual = .{
            .font_size = 80,
            .font_weight = 900,
        },
        .margin = .all(0),
    };

    pub const subheading = Style{ .visual = .{ .font_size = 32, .font_weight = 700 } };

    pub const miniheading = &Style{ .visual = .{ .font_size = 20, .font_weight = 500 } };

    pub const logo_text = &Style{ .visual = .{ .font_size = 20, .font_weight = 100 } };

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
                .{ .border = .simple(.palette(.text_tint_color)), .background = .palette(.alternate_background), .text_color = .white, .text_decoration = .none },
                .{ .border = .simple(.palette(.alternate_border_color)), .background = .palette(.background), .text_color = .palette(.text_color), .text_decoration = .none },
            ),
        });
        return base;
    }

    pub fn text(_: Theme.Mode) Style {
        return Style{
            .layout = .center,
        };
    }
};

var active1: bool = false;
var active2: bool = false;
var active3: bool = false;

fn toggle_expand(active: *bool) void {
    active.* = !active.*;
}

pub fn VideoStack(active: *bool) Vapor.ButtonBuilder(.static) {
    return CtxButton(toggle_expand, .{active})
        .direction(.column)
        .height(.percent(70))
        .width(.percent(24))
        .shadow(.card(.transparentizeHex(.palette(.tint), 0.1)))
        .border(.simple(.transparentizeHex(.palette(.tint), 0.1)))
        .layer(.grid(4, 1, .transparentizeHex(.palette(.tint), 0.05)))
        .background(.palette(.background))
        .duration(100)
        .hover(.{
            .border = .simple(.transparentizeHex(.palette(.tint), 0.5)),
            .shadow = .card(.transparentizeHex(.palette(.tint), 0.5)),
            .transform = .scaleDecimal(1.02),
        })
        .padding(.all(8))
        .spacing(4)
        .layout(.center);
}
const Form = struct {
    email: []const u8 = "",
    password: []const u8 = "",
    confirm_password: []const u8 = "",

    pub var __validations = .{
        .email = Vaporize.Validation{ .field_type = .email },
        .password = Vaporize.Validation{ .field_type = .password },
        .confirm_password = Vaporize.Validation{ .field_type = .password, .match = true, .target_field = "password" },
    };
};

const FormLogin = Compiler.vaporize.Form(Form);
var login_form: FormLogin = undefined;

pub fn form() void {
    Stack()
        .width(.percent(100)).layout(.center).spacing(16)
        .height(.fit)
        .background(.palette(.background))
        .border(.simple(.palette(.text_color)))
        .pos(.relative)
        .children({
        Text("SIGN UP").font(84, 900, .palette(.text_color))
            .padding(.horizontal(12))
            .border(.bottom(.palette(.text_color)))
            .layout(.center)
            .width(.percent(100))
            .end();
        Stack()
            .width(.percent(100)).layout(.center).padding(.all(20))
            .children({
            login_form.render();
        });
    });
}
