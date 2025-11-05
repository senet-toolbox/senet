const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Page = Vapor.Page;
const Custom = @import("../../../components/Custom.zig");
const HtmlText = Custom.Chain.HtmlText;
const root = @import("../../../main.zig");
const Box = Static.Box;
const Svg = Static.Svg;
const Graphic = Static.Graphic;
const Center = Static.Center;
const Text = Static.Text;
const Stack = Static.Stack;
const List = Static.List;
const ListItem = Static.ListItem;

// Initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

// Deinitialization
pub fn deinit() void {}

// Render
const description =
    \\Vapor is a universal tree renderer that takes styled component hierarchies and renders them natively across
    \\platforms—from web browsers to iOS and macOS apps. Unlike black-box solutions, Vapor gives you direct access to the 
    \\rendering pipeline, so you can customize and optimize the engine for your exact use case.
;

const Route = struct {
    title: []const u8,
    path: []const u8,
};

const routes = [_]Route{
    .{ .title = "Introduction", .path = "/docs/vapor/concepts/introduction" },
    .{ .title = "Vapor Basics", .path = "/docs/vapor/concepts/basics" },
    .{ .title = "Static, Pure, Dynamic, Grain", .path = "/docs/vapor/concepts/reactivity" },
    .{ .title = "Routing", .path = "/docs/vapor/concepts/routing" },
    .{ .title = "Theme and Style", .path = "/docs/vapor/concepts/theme-and-style" },
    .{ .title = "Reactivity & Signals", .path = "/docs/vapor/concepts/reactivity-signals" },
    .{ .title = "Styling", .path = "/docs/vapor/concepts/styling" },
    .{ .title = "Kit", .path = "/docs/vapor/concepts/kit" },
    .{ .title = "Icons and Svgs", .path = "/docs/vapor/concepts/icons-and-svgs" },
    .{ .title = "Authentication", .path = "/docs/vapor/concepts/authentication" },
    .{ .title = "Using JS Libraries", .path = "/docs/vapor/concepts/using-js-libraries" },
    .{ .title = "Wasm Bridge", .path = "/docs/vapor/concepts/wasm-bridge" },
    .{ .title = "Custom Components", .path = "/docs/vapor/concepts/custom-components" },
    .{ .title = "Renderers & UI-Tree", .path = "/docs/vapor/concepts/renderers-ui-tree" },
    .{ .title = "Building a UI Layout Algorithmn", .path = "/docs/vapor/concepts/building-ui-layout-algorithm" },
    .{ .title = "Building a Reconciler", .path = "/docs/vapor/concepts/building-reconciler" },
    .{ .title = "Building a Renderer", .path = "/docs/vapor/concepts/building-renderer" },
};

var last_time: i64 = 0;
pub fn throttle() bool {
    const current_time = std.time.milliTimestamp();
    if (current_time - last_time < 60) {
        return true;
    }
    last_time = current_time;
    return false;
}

var menu: bool = false;
fn openMenu() void {
    if (!throttle()) {
        menu = !menu;
        Vapor.cycle();
    }
}

fn Txt(text: []const u8) void {
    Text(text).style(&.{
        .visual = .font(16, null, null),
    });
}

pub fn render() void {
    Box.style(&.{
        .padding = .horizontal(12),
        .direction = if (!Vapor.isMobile()) .row else .column,
        .size = .hw(.percent(100), .percent(100)),
    })({
        Box.style(&.{
            .size = .hw(.percent(100), .percent(100)),
            .layout = .top_center,
        })({
            Box.style(&.{
                .size = .w(.mobile_desktop_percent(100, 48)),
                .child_gap = 16,
                .direction = .column,
                .layout = .{ .x = .start, .y = .start },
                .padding = .tb(80, 80),
            })({
                Box.style(&.{
                    .child_gap = 16,
                    .direction = .column,
                    .margin = .{ .bottom = 32 },
                    .size = .w(.percent(100)),
                })({
                    Box.style(&.{
                        .layout = .x_between_center,
                        .margin = .{ .top = 0, .bottom = 32 },
                        .child_gap = 32,
                    })({
                        // Center.style(&.{ .size = .w(.percent(50)), .margin = .{ .top = 32 } })({
                        //     Graphic(.{ .src = "/src/routes/docs/metal/metal.svg" }).style(&.{
                        //         .layout = .center,
                        //         .size = .w(.percent(90)),
                        //     });
                        // });
                        Stack.style(&.{
                            .size = .w(.percent(100)),
                        })({
                            Text("Metal")
                                .font(192, 700, .palette(.text_color))
                                .margin(.l(-16))
                                .layout(.in_line)
                                .close();
                            // Graphic(.{ .src = "/src/routes/docs/metal/metal_text.svg" }).style(&.{
                            //     .layout = .center,
                            //     .size = .w(.percent(70)),
                            //     .visual = .{ .fill = .palette(.text_color) },
                            // });

                            HtmlText(
                                \\<strong>Vapor, Reverb, Canopy</strong> all run on Metal, there 
                                \\is no need for Docker Containers or
                                \\Runtimes.
                            ).style(&.{ .visual = .font(24, null, null) });
                        });
                    });
                    Text("It runs on my Machine!").style(&.{
                        .visual = .font(24, 500, .palette(.text_color)),
                        .font_family = "IBM Plex Sans",
                    });

                    Txt(
                        \\As we all know, switching machines, or having to reinstall megabytes of dependencies is a pain,
                        \\and eventually leads to the dreaded "It works on my machine" problem. 
                        \\Running a static blog shouldn’t require an entire runtime environment, build chain, and container stack. Nor should a full-stack app.
                    );

                    Txt(
                        \\The framework that is installed on one machine should run deterministically on another.
                        \\Every current JS framework or other framework currently ships dependencies. And there is no way to avoid them.
                    );

                    Text("Binary").style(&.{
                        .visual = .font(24, 500, .palette(.text_color)),
                        .font_family = "IBM Plex Sans",
                    });

                    HtmlText(
                        \\Metal is how Vapor, Reverb and Canopy, compile and build the binaries. Depending on persmissions,
                        \\Vapor will use wasm-opt and brotli, to compress the WASM binaries, this will reduce the total bundle size. For example, the raw
                        \\WASM binary of this site it 7MB, after compressing using Metal, we result in 180kb total. While other frameworks may ship 100kb-200kb by default.
                        \\Remember Vapor, is running WASM, so the browser not only parses this <a href="https://webassembly.org/docs/faq/">10x-20x</a> 
                        \\faster, but also runs <a href="https://hacks.mozilla.org/2018/01/oxidizing-source-maps-with-rust-and-webassembly/">1.5x-2x</a> faster.
                        \\And again, we only have one binary file running the Vapor server, and one vapor.wasm file which contains our UI, and client side functionality.
                    ).style(&.{
                        .visual = .font(18, null, null),
                    });

                    Stack.childGap(16).body()({
                        Text("Total file count").style(&.{
                            .visual = .font(24, 500, .palette(.text_color)),
                            .font_family = "IBM Plex Sans",
                        });
                        List.direction(.column).body()({
                            ListItem.style(&.{})({
                                Text("Vapor: server.exe, vapor.wasm, bundle.min.js").style(&.{
                                    .visual = .font(16, null, null),
                                });
                            });
                            ListItem.style(&.{})({
                                Text("Reverb: server.exe").style(&.{
                                    .visual = .font(16, null, null),
                                });
                            });
                            ListItem.style(&.{})({
                                Text("Canopy: server.exe").style(&.{
                                    .visual = .font(16, null, null),
                                });
                            });
                        });
                    });

                    Text("Caveat").style(&.{
                        .visual = .font(24, 500, .palette(.text_color)),
                        .font_family = "IBM Plex Sans",
                    });

                    Txt(
                        \\Alot of people are going to tell you that, Yes WASM is faster, but the overhead, between JS bridging to WASM, kills
                        \\your performace. This claim is valid, however the amount of time to bridge between WASM and JS is 10ns
                        \\so you would need to perform over 10,000,000 operations to hit and overhead of 1 second. Moving string around costs anywhere from 
                        \\hundreds of nanoseconds up to a few milliseconds, because of size. You pay for the linear encoding, due UTF-8 and UTF-16 differences. 
                        \\However, WASM is contionously being improved and changed, in the next year or so, a new model will be release, where no copying will be needed.
                        \\And you will be able to interact with JS string and object without the need of crossing a 'bridge' ie negligible cost.
                        \\One very simple way to not cross this boundary a ton, is just batch. Vapor does this by default. 
                    );
                });
            });
        });
    });
}
