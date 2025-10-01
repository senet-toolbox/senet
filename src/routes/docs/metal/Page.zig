const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const Custom = @import("../../../components/Custom.zig");
const HtmlText = Custom.Chain.HtmlText;
const root = @import("../../../main.zig");
const Chain = Fabric.Chain;
const ChainClose = Fabric.ChainClose;
const Box = Chain.Box;
const Svg = ChainClose.Svg;
const Center = Chain.Center;
const Text = ChainClose.Text;
const Stack = Chain.Stack;

// Initialization
pub fn init() void {
    Page(@src(), render, null, &.{});
}

// Deinitialization
pub fn deinit() void {}

// Render
const description =
    \\Fabric is a universal tree renderer that takes styled component hierarchies and renders them natively across
    \\platforms—from web browsers to iOS and macOS apps. Unlike black-box solutions, Fabric gives you direct access to the 
    \\rendering pipeline, so you can customize and optimize the engine for your exact use case.
;

const Route = struct {
    title: []const u8,
    path: []const u8,
};

const routes = [_]Route{
    .{ .title = "Introduction", .path = "/docs/fabric/concepts/introduction" },
    .{ .title = "Fabric Basics", .path = "/docs/fabric/concepts/basics" },
    .{ .title = "Static, Pure, Dynamic, Grain", .path = "/docs/fabric/concepts/reactivity" },
    .{ .title = "Routing", .path = "/docs/fabric/concepts/routing" },
    .{ .title = "Theme and Style", .path = "/docs/fabric/concepts/theme-and-style" },
    .{ .title = "Reactivity & Signals", .path = "/docs/fabric/concepts/reactivity-signals" },
    .{ .title = "Styling", .path = "/docs/fabric/concepts/styling" },
    .{ .title = "Kit", .path = "/docs/fabric/concepts/kit" },
    .{ .title = "Icons and Svgs", .path = "/docs/fabric/concepts/icons-and-svgs" },
    .{ .title = "Authentication", .path = "/docs/fabric/concepts/authentication" },
    .{ .title = "Using JS Libraries", .path = "/docs/fabric/concepts/using-js-libraries" },
    .{ .title = "Wasm Bridge", .path = "/docs/fabric/concepts/wasm-bridge" },
    .{ .title = "Custom Components", .path = "/docs/fabric/concepts/custom-components" },
    .{ .title = "Renderers & UI-Tree", .path = "/docs/fabric/concepts/renderers-ui-tree" },
    .{ .title = "Building a UI Layout Algorithmn", .path = "/docs/fabric/concepts/building-ui-layout-algorithm" },
    .{ .title = "Building a Reconciler", .path = "/docs/fabric/concepts/building-reconciler" },
    .{ .title = "Building a Renderer", .path = "/docs/fabric/concepts/building-renderer" },
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
        Fabric.cycle();
    }
}

fn Txt(text: []const u8) void {
    Text(text).style(&.{
        .visual = .font(18, null, null),
    });
}

pub fn render() void {
    Box.style(&.{
        .layout = .{ .x = .start, .y = .start },
        .padding = .horizontal(12),
        .size = .hw(.percent(100), .percent(100)),
    })({
        Center.style(&.{
            .size = .w(.percent(100)),
            .padding = .{ .top = 60, .bottom = 120 },
            .direction = .column,
        })({
            Box.style(&.{
                .size = .w(.mobile_desktop_percent(100, 64)),
                .direction = .column,
                .padding = .{ .bottom = 80 },
            })({
                Box.style(&.{
                    .child_gap = 16,
                    .direction = .column,
                    .margin = .{ .bottom = 32 },
                    .size = .w(.percent(100)),
                })({
                    Box.style(&.{
                        .layout = .x_between_center,
                        .margin = .{ .top = 64, .bottom = 128 },
                        .child_gap = 32,
                    })({
                        Center.style(&.{ .size = .w(.percent(50)), .margin = .{ .top = 32 } })({
                            Svg(.{ .svg = @embedFile("metal.svg") }).style(&.{
                                .layout = .center,
                                .size = .w(.percent(70)),
                            });
                        });
                        Stack.style(&.{
                            .size = .w(.percent(50)),
                            .child_gap = 16,
                            .padding = .{ .top = 16 },
                        })({
                            Svg(.{ .svg = @embedFile("metal_text.svg") }).style(&.{
                                .layout = .center,
                                .size = .w(.percent(70)),
                            });

                            HtmlText(
                                \\<strong>Fabric, Reverb, Treehouse</strong> all run on Metal, there 
                                \\is no need for Docker Containers or
                                \\Runtimes.
                            ).style(&.{ .visual = .font(24, null, null) });
                        });
                    });
                    Text("The Docker Problem").style(&.{
                        .visual = .font(48, 700, .palette(.text_color)),
                    });

                    Txt(
                        \\As much as I agree, that your blog post about how Dogs are better than cats, is incredible, and a complete fact. 
                        \\Running a static blog shouldn’t require an entire runtime, build chain, and container stack.
                        \\Yet that’s what we do today when we docker run an Nginx image just to serve HTML.
                        \\Fabric flips that model. We ship one platform-native binary that does everything—file 
                        \\serving, routing, compression—out of the box. Tether and Treehouse follow the same pattern. If it runs on your laptop, it will run in prod, 
                        \\provided the underlying OS matches. No more “but it works on my machine.”
                    );

                    Text("Binary").style(&.{
                        .visual = .font(48, 700, .palette(.text_color)),
                    });

                    HtmlText(
                        \\Metal is how Fabric, and Tether and Treehouse, along with NightWatch, compile and build the binaries. Depending on persmissions,
                        \\Fabric will use wasm-opt and brotli, to compress the WASM binaries, this will reduce the total bundle size. For example, the raw
                        \\WASM binary of this site it 2.4MB, after compressing using Metal, we result in 300kb total. While other frameworks may ship 100kb-200kb.
                        \\Remeber Fabric, is running WASM, so the browser not only parses this <a href="https://webassembly.org/docs/faq/">10x-20x</a> 
                        \\faster, but also runs <a href="https://hacks.mozilla.org/2018/01/oxidizing-source-maps-with-rust-and-webassembly/">1.5x-2x</a> faster.
                        \\And again, we only have one binary file running the Fabric server, and one fabric.wasm file which contains our UI, and client side functionality.
                    ).style(&.{
                        .visual = .font(18, null, null),
                    });
                    Center.style(&.{
                        .size = .hw(.px(100), .percent(100)),
                    })({
                        HtmlText(
                            \\And of course best of all, no more "But it runs on my Machine?"
                        ).style(&.{ .visual = .font(32, 700, .palette(.text_color)) });
                    });
                    Text("Caveat").style(&.{ .visual = .font(48, 700, .palette(.text_color)) });

                    Txt(
                        \\Alot of people are going to tell you that, Yes WASM is faster, but the overhead, between JS bridging to WASM, kills
                        \\your performace. This claim is valid, however the amount of time to bridge between WASM and JS is 10ns
                        \\so you would need to perform over 10,000,000 operations to hit and overhead of 1 second. Moving string around costs anywhere from 
                        \\hundreds of nanoseconds up to a few milliseconds, because of size. You pay for the linear encoding, due UTF-8 and UTF-16 differences. 
                        \\However, WASM is contionously being improved and changed, in the next year or so, a new model will be release, where no copying will be needed.
                        \\And you will be able to interact with JS string and object without the need of crossing a 'bridge' ie negligible cost.
                        \\One very simple way to not cross this boundary a ton, is just batch. 
                    );
                });
            });
        });
    });
}
