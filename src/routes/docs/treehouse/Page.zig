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
    Fabric.lib.registerLayout("/docs/treehouse", layout);
    ctx_sample.init(&Fabric.lib.allocator_global, @embedFile("context_sample.zig"));
    ctx_offload_sample.init(&Fabric.lib.allocator_global, @embedFile("context_offload_sample.zig"));
    // html_code_editor.init(&Fabric.lib.allocator_global, @embedFile("html_text_sample.zig"));
    // traversal_code_editor.init(&Fabric.lib.allocator_global, @embedFile("traversal_sample.js"));

    Page(@src(), render, null, .{});
}

// Deinitialization
pub fn deinit() void {}

const Route = struct {
    title: []const u8,
    path: []const u8,
};

const routes = [_]Route{
    .{ .title = "Introduction", .path = "/docs/reverb/concepts/introduction" },
    .{ .title = "Basics", .path = "/docs/reverb/concepts/basics" },
    .{ .title = "Routing", .path = "/docs/reverb/concepts/routing" },
    .{ .title = "Context", .path = "/docs/reverb/concepts/context" },
    .{ .title = "Middleware", .path = "/docs/reverb/concepts/middleware" },
    .{ .title = "Memory Tracking", .path = "/docs/reverb/concepts/memory" },
    .{ .title = "Project Structure", .path = "/docs/reverb/concepts/project" },
    .{ .title = "Loom Engine", .path = "/docs/reverb/concepts/loom" },
    .{ .title = "Scheduler", .path = "/docs/reverb/concepts/scheduler" },
    .{ .title = "Kit", .path = "/docs/reverb/concepts/kit" },
    .{ .title = "KeyStone", .path = "/docs/reverb/concepts/keystone" },
    .{ .title = "Gotchas", .path = "/docs/reverb/concepts/gotchas" },
    .{ .title = "Metal", .path = "/docs/reverb/concepts/metal" },
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
                .width = .mobile_desktop_percent(100, 62),
                .child_gap = 16,
                .direction = .column,
                .child_alignment = .{ .x = .start, .y = .start },
            })({
                // Static.Text("Fabric", .{
                //     .font_size = 64,
                //     .font_family = "Mrs Sheppards",
                // });
                Static.Svg(@embedFile("treehouse_text.svg"), .{
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
                Static.Text("What is Treehouse?", .{
                    // .margin = .{ .top = 32 },
                    .font_size = 32,
                    .font_weight = 700,
                });
                Static.Text(
                    \\Treehouse is the cache/database component of Tether.
                , .{
                    .font_size = 24,
                    .width = .percent(100),
                    .text_color = .hex("#666666"),
                    .margin = .{ .top = 8, .bottom = 8 },
                });
                Custom.HtmlText(
                    \\Treehouse is a cache/database. It can be used as either or both, moreover it is flexible, so it can be treated different
                    \\over time. The cache part of Treehouse is a akin to Redis, and follows the same API RESP3. The database side, follows
                    \\the same API as SQLite. Treehouse uses the same LOOM engine as Reverb under the hood. Treehouse uses an LSM tree
                    \\structure, for storage, and a B-tree for indexing. Essentially, Treehouse stores all data as key value pairs, and allows 
                    \\for fast lookups, but also table like operations. This means that every row in the database is a key value pair. It also
                    \\means that rows and tables are automically associated with a specific path, ie if a table is requests, it will be promoted
                    \\to the hot cache path. Which results in a significant performance boost. Since we are not doing disk IO.
                , .{
                    .font_size = 18,
                    .width = .percent(100),
                    .height = .fit,
                });
                Static.Text(
                    \\Treehouse can be interfaced with mem_tier, any redis compatible client, as well as SQLite. Specifically, we can use Nightwatch
                    \\to perform SQL queries, and also crud operations. 
                , .{
                    .font_size = 18,
                });
                Static.Text("Treehouse is Layered", .{
                    .font_size = 32,
                    .font_weight = 700,
                });
                Static.List(.{
                    .direction = .column,
                })({
                    Static.ListItem(.{})({
                        Static.Text("WAL (disk-memory)", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("SIMD Tagged Cache (in-memory)", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("Stash (in-memory)", .{
                            .font_size = 18,
                        });
                    });
                    Static.ListItem(.{})({
                        Static.Text("LSM Tree (disk-memory)", .{
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
                    Static.Text("curl -sSL https://raw.githubusercontent.com/tether-labs/treehouse/main/install.sh | bash", .{
                        .font_size = 16,
                        .font_family = "Azeret Mono, monospace",
                    });
                });

                Static.Text("Zero runtime allocation", .{
                    .font_size = 24,
                    .font_weight = 700,
                    .margin = .{ .top = 8 },
                });
                Custom.HtmlText(
                    \\All memory is allocated during startup, there is no runtime allocation. This means that we do not risk memory leaks.
                    \\This is important to note, as the developers like yourself, are responsible for determining the memory footprint of your application.
                    \\Moreover, this means internally, Memory tracking is far less comlex. Warnings and errors are thrown when hitting a predetermined
                    \\memory threshold.
                , .{});
                Custom.HtmlText(
                    \\This does not mean that disk IO is limited. We are currently talking about the memory footprint of the (in-memory) cache component.
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
                Custom.Intersection(.{
                    .id = "fabric-documentation",
                })({
                    Static.Text("Documentation", .{
                        .margin = .{ .top = 32 },
                        .font_size = 32,
                        .font_weight = 700,
                    });
                    Static.Text("This is the documenation of Fabric, a frontend toolkit for building UI. Fabric is one of 3 components of Tether.", .{
                        .font_size = 20,
                        .text_color = .hex("#666666"),
                    });
                    Static.Text("Fabric concepts:", .{
                        .font_size = 24,
                    });

                    Static.List(.{
                        .display = .Flex,
                        .child_gap = 8,
                        .direction = .column,
                        .child_alignment = .{ .x = .start, .y = .start },
                        .padding = .{ .left = 32 },
                    })({
                        for (routes) |route| {
                            Static.ListItem(.{
                                // .width = .percent(100),
                            })({
                                Static.Link(.{ .url = route.path, .aria_label = route.title }, .{
                                    .text_decoration = .none,
                                    // .width = .percent(100),
                                    .display = .Flex,
                                    .child_alignment = .{ .x = .start, .y = .center },
                                    .child_gap = 12,
                                    .padding = .{ .top = 4, .bottom = 4 },
                                    .cursor = .pointer,
                                    .border_thickness = .{ .bottom = 1 },
                                    .hover = .{ .border_thickness = .{ .bottom = 1 }, .border_color = .rgb(0, 0, 0) },
                                })({
                                    Static.Text(route.title, .{});
                                });
                            });
                        }
                    });
                });
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
            .file = "/routes/docs/treehouse",
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
