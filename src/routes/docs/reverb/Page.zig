const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const Menu = @import("Menu.zig");
const CodeEditor = @import("concepts/:concept/CodeEditor.zig");
const Custom = @import("../../../components/Custom.zig");
const root = @import("../../../main.zig");
const Sheet = @import("Sheet.zig").Sheet;
var sheet: Sheet(void, Menu.render) = undefined;

// Initialization
var ctx_sample: CodeEditor = undefined;
var ctx_offload_sample: CodeEditor = undefined;
pub fn init() void {
    sheet.init(&Fabric.lib.allocator_global);
    Fabric.lib.registerLayout("/docs/reverb", layout);
    ctx_sample.init(&Fabric.lib.allocator_global, @embedFile("context_sample.zig"));
    ctx_offload_sample.init(&Fabric.lib.allocator_global, @embedFile("context_offload_sample.zig"));
    // html_code_editor.init(&Fabric.lib.allocator_global, @embedFile("html_text_sample.zig"));
    // traversal_code_editor.init(&Fabric.lib.allocator_global, @embedFile("traversal_sample.js"));

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
    .{ .title = "Basics", .path = "/docs/fabric/concepts/basics" },
    .{ .title = "Project Structure", .path = "/docs/fabric/concepts/routing" },
    .{ .title = "Static, Pure, Dynamic, Grain", .path = "/docs/fabric/concepts/reactivity" },
    .{ .title = "Routing", .path = "/docs/fabric/concepts/routing" },
    .{ .title = "Reactivity", .path = "/docs/fabric/concepts/reactivity-signals" },
    .{ .title = "Styling", .path = "/docs/fabric/concepts/styling" },
    .{ .title = "Kit", .path = "/docs/fabric/concepts/kit" },
    .{ .title = "Event Handlers", .path = "/docs/fabric/concepts/events" },
    .{ .title = "LifeCycle Hooks", .path = "/docs/fabric/concepts/hooks" },
    .{ .title = "Event Handlers", .path = "/docs/fabric/concepts/events" },
    .{ .title = "Using JS Libraries", .path = "/docs/fabric/concepts/jslibs" },
    .{ .title = "Wasm Bridge", .path = "/docs/fabric/concepts/wasm-bridge" },
    .{ .title = "KeyStone", .path = "/docs/fabric/concepts/keystone" },
    .{ .title = "Gotchas", .path = "/docs/fabric/concepts/gotchas" },
    .{ .title = "Metal", .path = "/docs/fabric/concepts/metal" },
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

pub fn render() void {
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .padding = .horizontal(12),
        .direction = if (!Fabric.isMobile()) .row else .column,
        .width = .percent(100),
        .height = .percent(100),
    })({
        // Fabric.Layout(@src(), .{})({
        if (!Fabric.isMobile()) {} else {
            Static.FlexBox(.{
                .child_alignment = .{ .x = .between, .y = .center },
                .child_gap = 8,
                .padding = .horizontal(12),
                .height = .px(50),
                .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
                .width = .percent(100),
                .z_index = 999,
                .background = root.theme.getAttribute("background"),
                .border_color = root.theme.getAttribute("border_color"),
                .border_thickness = .{ .bottom = 1 },
            })({
                Static.FlexBox(.{ .child_alignment = .x_between_center, .child_gap = 12, .width = .percent(100) })({
                    Static.Link(.{ .url = "/", .aria_label = "home page of tether" }, .{
                        .text_decoration = .none,
                        .height = .px(36),
                        .display = .Center,
                    })({
                        Static.Image("/assets/circlelogo.webp", .{
                            .display = .Flex,
                            .child_alignment = .{ .x = .center, .y = .center },
                            .width = .px(42),
                            .height = .px(42),
                        });
                    });
                });
            });
        }
        Static.FlexBox(.{
            .height = .percent(100),
            .width = .percent(100),
            .child_alignment = .{ .y = .start, .x = .center },
            .padding = .{ .top = 60 },
        })({
            Static.FlexBox(.{
                .width = .clamp_percent(62, 62, 100),
                .child_gap = 16,
                .direction = .column,
                .child_alignment = .{ .x = .start, .y = .start },
            })({
                // Static.Text("Fabric", .{
                //     .font_size = 64,
                //     .font_family = "Mrs Sheppards",
                // });
                Static.Svg(@embedFile("reverb_text.svg"), .{
                    .margin = .{ .top = 16 },
                    .width = .percent(20),
                });

                // Static.Text("An Exposed UI Toolkit", .{
                //     .font_size = 32,
                //     .font_weight = 700,
                // });
                // Static.Image("/assets/FabricKit.webp", .{
                //     .width = .percent(100),
                //     .height = .percent(100),
                //     .border_radius = .all(8),
                //     .margin = .{ .bottom = 32 },
                // });
                Static.Text("What is Reverb?", .{
                    // .margin = .{ .top = 32 },
                    .font_size = 32,
                    .font_weight = 700,
                });
                Custom.HtmlText(
                    \\Reverb is a backend web framework. The purpose of Reverb is to be the connection between Fabric, and Treehouse. 
                    \\Reverb was heavily inspired by <a href="https://gofiber.io/">Golang Fiber</a>, and <a href="https://echo.labstack.c
                    \\om/">Echo</a>.
                    \\Reverb has been built from the ground up, with a focus on simplicity in design and development, yet with extreme performance
                    \\baked in.
                    \\Reverb uses a single threaded event-loop to handle all incoming requests and responses. This is achieved with a custom 
                    \\<a href="https://celerdata.com/glossary/single-instruction-multiple-data-simd">SIMD</a> HTTP parser, and
                    \\a SIMD response generator. This means that, Reverb can achieve exceptionally high performance metrics while being
                    \\being a single sequential system. Currently, 
                    \\Reverb is on par with <a href="https://gnet.host/">GNET</a>, which has a main focus explicitly on being event-loop only.
                , .{
                    .font_size = 18,
                    .width = .percent(100),
                    .height = .fit,
                });
                Static.Text(
                    \\While Reverb is single threaded, Reverb exposes a high performance Scheduler package. Within this package, you can make use
                    \\of the manual frame stack pointer swaping async, an atomic lock free thread pool, and much more. All through a simple 1-2 lines api interface.
                , .{
                    .font_size = 18,
                });
                Static.Text(
                    \\Therefore in heavy duty operations we can pause executation, or hand off these operations to a high performance thread pool. Thus we have full
                    \\control on the order of operations, and no more async function coloring.
                , .{
                    .font_size = 18,
                });

                Static.Text("Reverb is simple by nature", .{
                    .font_size = 32,
                    .font_weight = 700,
                });
                Static.List(.{
                    .direction = .column,
                })({
                    Static.ListItem(.{})({
                        Static.Text("Every Route function takes Context, which exposes all utils for handling responses and requests", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("Middlerware is just a function passed into the router instantiation", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("No runtime allocations", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("High performance SIMD JSON", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("Minimal memory management", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("Native performance", .{
                            .font_size = 18,
                        });
                    });
                });

                Static.Text("Installation", .{
                    .font_size = 24,
                    .font_weight = 700,
                    .margin = .{ .top = 8 },
                });
                Static.Center(.{
                    .id = "curl-install",
                    .border_radius = .all(8),
                    .border_color = .hex("#bfbfbf"),
                    .border_thickness = .all(1),
                    .padding = .all(12),
                    .width = .percent(100),
                })({
                    Static.Text("curl -sSL https://raw.githubusercontent.com/tether-labs/metal/main/install.sh | bash", .{
                        .font_size = 16,
                        .font_family = "Azeret Mono, monospace",
                    });
                });

                Static.Text("Zero allocation", .{
                    .font_size = 24,
                    .font_weight = 700,
                    .margin = .{ .top = 8 },
                });
                Custom.HtmlText(
                    \\No messages, and data, is cloned, or allocated during the entire read and write process. 
                    \\the <code>ctx: *Context</code> values passed to every handler function, holds the original data, and is mutable by default.
                    \\Context values should not be used outside the handler fucntion or taken reference to after the handler function returns.
                    \\If you were to offload data such as the request body, make sure to create an allocation, as the <code>*Context</code> param, is 
                    \\overided across all requests and responses.
                , .{});
                Custom.HtmlText(
                    \\Make sure to never pass the *Context to a thread, which is not cloned. This is considered undefined behaviour otherwise.
                , .{});
                ctx_sample.render(0);
                Static.Text("Offload example", .{
                    .font_size = 20,
                    .font_weight = 700,
                    .margin = .{ .top = 8 },
                });
                Custom.HtmlText(
                    \\Below is an example of copying and offloading the copied key to a atomic thread pool.
                , .{});
                ctx_offload_sample.render(0);
            });
        });
    });
}

fn layout(page: *const fn () void) void {
    if (Fabric.isMobile()) {
        Static.FlexBox(.{
            .child_alignment = .{ .x = .between, .y = .center },
            .child_gap = 8,
            .padding = .horizontal(12),
            .height = .px(50),
            .position = .{ .type = .fixed, .top = .px(0), .left = .percent(0), .right = .percent(0) },
            .width = .percent(100),
            .z_index = 999,
            .background = .hex("#ffffff"),
        })({
            Static.FlexBox(.{ .child_alignment = .x_between_center, .child_gap = 12, .width = .percent(100) })({
                Static.Link(.{ .url = "/", .aria_label = "home page of tether" }, .{
                    .text_decoration = .none,
                    .height = .px(36),
                    .display = .Center,
                })({
                    Static.Image("/assets/circlelogo.webp", .{
                        .display = .Flex,
                        .child_alignment = .{ .x = .center, .y = .center },
                        .width = .px(42),
                        .height = .px(42),
                    });
                });
                Static.Button(.{ .onPress = openMenu }, .{
                    .width = .px(36),
                    .height = .px(36),
                })({
                    if (menu) {
                        Pure.Icon("bi bi-x-lg", .{
                            .font_size = 24,
                        });
                    } else {
                        Pure.Icon("bi bi-list", .{
                            .font_size = 24,
                        });
                    }
                });
            });
        });
        sheet.render({});
        @call(.auto, page, .{});
    } else {
        Fabric.Remember(.{
            .file = "/routes/docs/fabric",
            .module = "",
            .column = 0,
            .fn_name = "",
            .line = 0,
        })({
            Menu.render({});
        });
        @call(.auto, page, .{});
    }
}
