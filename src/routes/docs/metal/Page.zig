const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const Navbar = @import("../../../components/Navbar.zig");
const Custom = @import("../../../components/Custom.zig");
const root = @import("../../../main.zig");

// Initialization
pub fn init() void {
    Page(@src(), render, null, .{});
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
    Static.Text(text, .{
        .font_size = 18,
    });
}

pub fn render() void {
    Navbar.render();
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .padding = .horizontal(12),
        .width = .percent(100),
        .height = .percent(100),
    })({
        // Fabric.Layout(@src(), .{})({
        // if (!Fabric.isMobile()) {
        // } else {
        //     Fabric.Layout(@src(), .{})({
        //         Static.FlexBox(.{
        //             .child_alignment = .{ .x = .between, .y = .center },
        //             .child_gap = 8,
        //             .padding = .horizontal(12),
        //             .height = .px(50),
        //             .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
        //             .width = .percent(100),
        //             .z_index = 999,
        //             .background = root.theme.getAttribute("background"),
        //         })({
        //             Static.FlexBox(.{ .child_alignment = .between_center, .child_gap = 12, .width = .percent(100) })({
        //                 Static.Link(.{ .url = "/", .aria_label = "home page of tether" }, .{
        //                     .text_decoration = .none,
        //                     .height = .px(36),
        //                     .display = .Center,
        //                 })({
        //                     Static.Image("/assets/circlelogo.webp", .{
        //                         .display = .Flex,
        //                         .child_alignment = .{ .x = .center, .y = .center },
        //                         .width = .px(42),
        //                         .height = .px(42),
        //                     });
        //                 });
        //                 Static.Button(.{ .onPress = openMenu }, .{
        //                     .width = .px(36),
        //                     .height = .px(36),
        //                 })({
        //                     Pure.Icon("bi bi-list", .{
        //                         .font_size = 24,
        //                     });
        //                 });
        //             });
        //         });
        //     });
        // }
        Static.Center(.{
            .width = .percent(100),
            .padding = .{ .top = 60, .bottom = 120 },
            .direction = .column,
        })({
            Static.FlexBox(.{
                .width = .clamp_percent(64, 786, 100),
                .direction = .column,
                .padding = .{ .bottom = 80 },
            })({
                Static.Box(.{
                    .child_gap = 16,
                    .direction = .column,
                    .margin = .{ .bottom = 32 },
                    .width = .percent(100),
                })({
                    Static.Box(.{
                        .child_alignment = .between_center,
                        .margin = .{ .top = 64, .bottom = 128 },
                        .child_gap = 32,
                    })({
                        Static.Center(.{ .width = .percent(50), .margin = .{ .top = 32 } })({
                            Static.Svg(@embedFile("metal.svg"), .{
                                .display = .Center,
                                .width = .percent(70),
                            });
                        });
                        Static.Column(.{
                            .width = .percent(50),
                            .child_gap = 16,
                            .padding = .{ .top = 16 },
                        })({
                            Static.Svg(@embedFile("metal_text.svg"), .{
                                .display = .Center,
                                .width = .percent(70),
                            });

                            Custom.HtmlText(
                                \\<strong>Fabric, Tether, Treehouse</strong> all run on Metal, there is no need for Docker Containers or Runtimes.
                            , .{
                                .font_size = 24,
                            });
                        });
                    });
                    Static.Text("The Docker Problem", .{
                        .font_size = 48,
                        .font_weight = 700,
                        .text_color = .hex("#1a1a1a"),
                    });

                    Txt(
                        \\As much as I agree, that your blog post about how Dogs are better than cats, is incredible, and a complete fact. 
                        \\Running a static blog shouldn’t require an entire runtime, build chain, and container stack.
                        \\Yet that’s what we do today when we docker run an Nginx image just to serve HTML.
                        \\Fabric flips that model. We ship one platform-native binary that does everything—file 
                        \\serving, routing, compression—out of the box. Tether and Treehouse follow the same pattern. If it runs on your laptop, it will run in prod, 
                        \\provided the underlying OS matches. No more “but it works on my machine.”
                        // \\The fact is, to install a runtime, a build system, a containerization
                        // \\system, just to serve that blog post to a user in there browser is unbeleivebly overkill. Therefore, For Fabric,
                        // \\we one binary file which acts as a server, and handles everything. That's it!.
                        // \\Tether and Treehouse are both just one binary each as well. This mean that whatever runs on your local system, will run exactly
                        // \\the same on your production system, as long as the OS underlying each is the same. No more, "But it works on my machine".
                    );

                    Static.Text("Binary", .{
                        .font_size = 48,
                        .font_weight = 700,
                        .text_color = .hex("#1a1a1a"),
                    });

                    Custom.HtmlText(
                        \\Metal is how Fabric, and Tether and Treehouse, along with NightWatch, compile and build the binaries. Depending on persmissions,
                        \\Fabric will use wasm-opt and brotli, to compress the WASM binaries, this will reduce the total bundle size. For example, the raw
                        \\WASM binary of this site it 2.4MB, after compressing using Metal, we result in 300kb total. While other frameworks may ship 100kb-200kb.
                        \\Remeber Fabric, is running WASM, so the browser not only parses this <a href="https://webassembly.org/docs/faq/">10x-20x</a> 
                        \\faster, but also runs <a href="https://hacks.mozilla.org/2018/01/oxidizing-source-maps-with-rust-and-webassembly/">1.5x-2x</a> faster.
                        \\And again, we only have one binary file running the Fabric server, and one fabric.wasm file which contains our UI, and client side functionality.
                    , .{
                        .font_size = 18,
                    });
                    Static.Center(.{
                        .width = .percent(100),
                        .height = .px(100),
                    })({
                        Custom.HtmlText(
                            \\And of course best of all, no more "But it runs on my Machine?"
                        , .{
                            .font_size = 32,
                            .font_weight = 700,
                        });
                    });
                    Static.Text("Caveat", .{
                        .font_size = 48,
                        .font_weight = 700,
                        .text_color = .hex("#1a1a1a"),
                    });

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
