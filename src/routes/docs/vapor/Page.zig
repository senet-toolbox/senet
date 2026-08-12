const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Row = Vapor.Row;
const Text = Vapor.Text;
const Link = Vapor.Link;
const Image = Vapor.Image;
const Svg = Vapor.Svg;
const Button = Vapor.Button;
const List = Vapor.List;
const ListItem = Vapor.ListItem;
const Graphic = Vapor.Graphic;
const Mark = Vapor.Mark;
const Vaporize = @import("vaporize");
const Icon = Vapor.Icon;
const Content = @import("../../../components/Content.zig");
const DocNavBar = @import("../../../components/DocNavbar.zig");
const Page = Vapor.Page;
const Custom = @import("../../../components/Custom.zig");
const root = @import("../../../main.zig");

// Initialization
var content: Content.new("") = undefined;

const Compiler = @import("../../../main.zig");

const components = .{
    .{ .tag = "counter", .function = counter },
    .{ .tag = "video", .function = Demo },
    // .{ .tag = "builder", .function = builder },
};

fn builder() void {
    Row()
        .height(.px(100)).layer(.dot(0.5, 20, .white)).background(.vapor_blue).layout(.center).children({
        Text("I like Dots!").font(48, 700, .white).fontFamily("Montserrat").end();
    });
}

var vapor_page: []const u8 = "";
var markdown: Compiler.vaporize.MarkDown(components) = .{};
var markdown_loaded: bool = false;
const fetch = Vapor.Fetch.Fetch.fetch;
pub fn init() void {
    Page(.{ .src = @src() }, render, null);
    fetch("/documents/vapor_page.md", .{ .method = .GET }).handle(handlePage, .{});
    content.init();
}

fn handlePage(resp: Vapor.Fetch.Result) void {
    switch (resp) {
        .ok => |data| {
            content.content_text = data.body;
            vapor_page = data.body;
            markdown.compile(vapor_page) catch |err| {
                Vapor.printErr("Failed to compile markdown: {any}", .{err});
                return;
            };
            markdown_loaded = true;
        },
        .err => |err| {
            Vapor.printErr("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
}

// Deinitialization
pub fn deinit() void {}

var copied: bool = false;
fn toggleIcon(_: void) void {
    copied = false;
    Vapor.cycle();
}

fn copy() void {
    Vapor.Clipboard.copy(vapor_page);
    copied = true;
    Vapor.timeout(1000, toggleIcon, .{{}});
}

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
    .{ .title = "Basics", .path = "/docs/vapor/concepts/basics" },
    .{ .title = "Project Structure", .path = "/docs/vapor/concepts/routing" },
    .{ .title = "Routing", .path = "/docs/vapor/concepts/routing" },
    .{ .title = "Reactivity", .path = "/docs/vapor/concepts/reactivity" },
    .{ .title = "Styling", .path = "/docs/vapor/concepts/styling" },
    .{ .title = "Kit", .path = "/docs/vapor/concepts/kit" },
    .{ .title = "Events & Handlers", .path = "/docs/vapor/concepts/events" },
    .{ .title = "Lifecycle Hooks", .path = "/docs/vapor/concepts/hooks" },
    .{ .title = "JS Libs", .path = "/docs/vapor/concepts/jslibs" },
    .{ .title = "Wasm Bridge", .path = "/docs/vapor/concepts/wasm-bridge" },
    .{ .title = "KeyStone", .path = "/docs/vapor/concepts/keystone" },
    .{ .title = "Gotchas", .path = "/docs/vapor/concepts/gotchas" },
    .{ .title = "Tutorials", .path = "/docs/vapor/concepts/tutorials" },
    .{ .title = "Metal", .path = "/docs/vapor/concepts/metal" },
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
    // if (!throttle()) {
    //     menu = !menu;
    //     Vapor.cycle();
    // }
    // sheet.toggle();
}

// fn code_snippet(text: []const u8) void {
//     Vapor.Row(.{
//         .height = .percent(100),
//         .background = .hex("#282a36"),
//         .border_radius = .all(8),
//         .padding = .all(8),
//         .width = .percent(100),
//         .direction = .column,
//     }).children({
//         Row().style(&.{
//             .layout = .end_center,
//             .width = .percent(100),
//             .padding = .horizontal(12),
//         }).children({
//             Vapor.Row(.{
//                 .width = .px(22),
//                 .height = .px(22),
//                 .border_radius = .all(4),
//                 .layout = .center,
//                 .cursor = .pointer,
//                 .transition = .{ .duration = 300 },
//                 .hover = .{ .background = .hex("#2D303E") },
//             }).children({
//                 Pure.Icon("bi bi-clipboard", .{
//                     .font_size = 16,
//                     .text_color = .hex("#cccccc"),
//                     .transition = .{ .duration = 300 },
//                     .hover = .{ .text_color = .hex("#ffffff") },
//                 });
//             });
//         });
//         Text(text).style(&.{
//             .font_size = 16,
//             .text_color = .hex("#ffffff"),
//         });
//     });
// }

var count: i32 = 0;
fn increment() void {
    count += 1;
}

var video: Vapor.Types.Video = .{
    .src = "/assets/kanban-mini.mp4",
    .autoplay = true,
    .muted = true,
    .loop = true,
};

fn Demo() void {
    Row().style(&.{
        .margin = .tb(24, 48),
        .size = .hw(.percent(100), .percent(100)),
        .layout = .center,
    }).children({
        Vapor.Video(&video)
            .aspectRatio(.landscape)
            .hw(.percent(90), .percent(90))
            .end();
    });
}

fn counter() void {
    Row().margin(.tb(12, 32)).spacing(48).width(.percent(100)).layout(.center).children({
        Button(increment, .{})
            .shadow(.card(.palette(.text_color)))
            .padding(.all(8))
            .border(.simple(.palette(.text_color)))
            .background(.palette(.background))
            .duration(100)
            .hoverScale()
            .width(.percent(30))
            .cursor(.pointer)
            .children({
            Vapor.Text("Click Me")
                .fontFamily("IBM Plex Mono,monospace")
                .font(22, 700, .palette(.text_color))
                .end();
        });
        Text(count)
            .fontFamily("IBM Plex Mono,monospace")
            .width(.px(100)).font(48, 700, .palette(.text_color)).end();
    });
}

fn alert() void {
    Vapor.alert("Welcome to Vapor!", .{});
}

const Counter = struct {
    count: u32 = 0,
    pub fn render(self: *Counter) void {
        Row().margin(.tb(12, 32)).spacing(16).width(.percent(100)).layout(.center).children({
            Button(counterIncrement, .{self})
                .padding(.all(8))
                .border(.simple(.palette(.text_color)))
                .background(.palette(.background))
                .duration(100)
                .hoverScale()
                .width(.percent(20))
                .cursor(.pointer)
                .children({
                Vapor.Text("-").fontFamily("IBM Plex Mono,monospace").font(18, null, .palette(.text_color)).end();
            });
            Text(self.count).width(.px(100)).font(24, 700, .palette(.text_color)).end();
        });
    }
    fn counterIncrement(self: *Counter) void {
        if (self.count == 0) {
            Vapor.alert("You can't go negative! On a u32");
            return;
        }
        self.count -= 1;
    }
};

fn alertComponent() void {
    Row().margin(.tb(12, 32)).spacing(16).width(.percent(100)).layout(.center).children({
        Button(alert, .{})
            .shadow(.card(.palette(.text_color)))
            .padding(.all(8))
            .border(.simple(.palette(.text_color)))
            .background(.palette(.background))
            .duration(100)
            .hoverScale()
            .width(.percent(20))
            .cursor(.pointer)
            .children({
            Vapor.Text("Alert!")
                .font(22, 700, .palette(.text_color))
                .fontFamily("IBM Plex Mono,monospace")
                .end();
        });
    });
}

fn component() void {
    markdown.render() catch |err| {
        Vapor.TextFmt("Failed to render markdown: {any}", .{err}).end();
    };
}

pub fn render() void {
    Row().style(&.{
        .layout = .x_between,
        .direction = .column,
        .size = .square_percent(100),
    }).children({
        Row().style(&.{
            .padding = .horizontal(12),
            .direction = .row,
            .size = .w(.percent(100)),
        }).children({
            Row().style(&.{
                .layout = .center,
                .size = .w(.percent(100)),
                .padding = .tb(60, 120),
                .direction = .column,
            }).children({
                Row().style(&.{
                    .size = .w(.mobile_desktop_percent(100, 50)),
                    // .width = .mobile_desktop_percent(100, 64),
                    // .size = .w(.percent(100)),
                    .child_gap = 32,
                    .direction = .column,
                    .padding = .bottom(80),
                    .margin = .tb(32, 32),
                }).children({
                    if (markdown_loaded) {
                        content.content(component);
                    } else {
                        Vapor.Null();
                    }
                });
            });
        });
    });
}
