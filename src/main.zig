const std = @import("std");
const Vapor = @import("vapor");
// const Bridge = Vapor.Bridge;
const RootPage = @import("routes/Page.zig");
const Navbar = @import("components/Navbar.zig");
const DocsNavbar = @import("components/DocNavbar.zig");
// const AcornNavbar = @import("components/AcornNavbar.zig");
const VaporDocs = @import("routes/docs/vapor/Page.zig");
const VaporDocsConcepts = @import("routes/docs/vapor/concepts/:concept/Page.zig");
const MetalDocs = @import("routes/docs/metal/Page.zig");
const Huh = @import("routes/huh/Page.zig");
const Install = @import("routes/install/Page.zig");
const Theme = @import("theme");
const TestPage = @import("routes/TestPage.zig");
const Vaporize = @import("vaporize");
const LegoCity = @import("routes/lego-city/Page.zig");
const JsonEditor = @import("routes/JsonEditor.zig");
const Stack = Vapor.Stack;
// const Content = @import("components/Content.zig");
// const Draggable = Vapor.Draggable;
//
// const Static = Vapor.Static;
// const Center = Vapor.Center;
// const Stack = Vapor.Stack;
// const Box = Vapor.Box;
// const Button = Vapor.Button;
// const TextFmt = Vapor.TextFmt;
const Text = Vapor.Text;
// const TextField = Vapor.TextField;
//
fn registerLayouts() !void {
    initLayouts();
    try Vapor.lib.registerLayout("/", layout, .{});
    try Vapor.lib.registerLayout("/docs", layoutDocs, .{ .reset = true });
}
//
// fn initHooks() void {
//     // _ = Vapor.registerHook("/docs", hook, .before);
//     // _ = Vapor.registerHook("/docs", hookAfter, .after);
// }
//
// fn hook(ctx: Vapor.lib.HookContext) void {
//     Vapor.print("Hook called {s}", .{ctx.to_path});
//     // DocsNavbar.reinitObserver();
// }
//
// fn hookAfter(ctx: Vapor.lib.HookContext) void {
//     // Content.initBoxes();
//     Vapor.print("After Hook called {s}", .{ctx.to_path});
// }
fn initLayouts() void {
    Navbar.init();
    DocsNavbar.init();
}

pub fn layout(page: *const fn () void) void {
    Navbar.render();
    page();
}

pub fn layoutDocs(page: *const fn () void) void {
    DocsNavbar.render();
    page();
}
//
// fn layoutAcorn(page: *const fn () void) void {
//     AcornNavbar.render();
//     page();
// }
//
// fn ErrorPage() void {
//     Center().size(.full).direction(.column).spacing(32).children({
//         Text("Page Not Found").font(72, 700, .palette(.text_color)).end();
//         Center().spacing(32).width(.percent(100)).children({
//             Button(.{ .on_press = Vapor.Kit.back })
//                 .duration(100)
//                 .hoverScale()
//                 .cursor(.pointer)
//                 .hw(.px(45), .px(160))
//                 .border(.sharp(.all(1), .palette(.text_color)))
//                 .children({
//                 Text("Go back").fontFamily("Montserrat").font(18, null, null).end();
//             });
//         });
//     });
// }
//
fn initPages() void {
    // JsonEditor.init();
    RootPage.init();
    Vapor.Page(.{ .route = "/" }, RootPage.render, null);
    // LegoCity.init();
    // Vapor.Page(.{ .route = "/lego-city" }, LegoCity.render, null);
    // Vapor.Page(.{ .route = "/error" }, ErrorPage, null); // Weird bug where if you put any route before the "/" it loads that route instead of the root
    VaporDocs.init();
    VaporDocsConcepts.init();
    //
    MetalDocs.init();
    Huh.init();
    Install.init();
}
//
// export fn immediateMode() void {
//     Vapor.cycle();
// }
//
// var counter: u32 = 0;
// fn increment() void {
//     Vapor.print("Increment", .{});
//     // Vapor.registerCtxTimeout("test", 1000, Vapor.print, .{ "Hello", .{} });
//     // test_struct.inner_struct.count += 1;
// }
// // //
// fn CounterWithBuider() void {
//     // const Center, Text, Button, TextFmt = .{ Vapor.Center, Vapor.Text, Vapor.Button, Vapor.TextFmt };
//     // Center().size(.full).direction(.column).children({
//     //     Text("Vapor").font(16 * 10, 700, .palette(.text_color)).end();
//     //     Center().spacing(32).width(.percent(100)).children({
//     Button(.{ .on_press = increment })
//         .duration(100)
//         .hoverScale()
//         .cursor(.pointer)
//         .hw(.px(45), .px(160))
//         .border(.sharp(.all(1), .palette(.text_color)))
//         .children({
//         Text("Increment").fontFamily("Montserrat").font(18, null, null).end();
//     });
//     Text(counter)
//         .width(.px(48))
//         .font(32, 700, .palette(.text_color)).end();
//     // });
//     // });
// }
//
// fn CounterWithStyle() void {
//     Center().style(Styles.container)({
//         Text("Vapor").style(Styles.title);
//         Center().style(Styles.controls)({
//             Button(.{ .on_press = increment }).style(Styles.button)({
//                 Text("Increment").style(Styles.button_text);
//             });
//             TextFmt("{d}", .{counter}).style(Styles.counter);
//         });
//     });
// }
//
// const Styles = struct {
//     pub const container = &Vapor.Style{
//         .size = .full,
//         .direction = .column,
//     };
//     pub const title = &Vapor.Style{
//         .visual = .font(160, 700, .palette(.text_color)),
//     };
//     pub const controls = &Vapor.Style{
//         .size = .{ .width = .percent(100) },
//         .child_gap = 32,
//     };
//
//     pub const button = &Vapor.Style{
//         .size = .hw(.px(45), .px(160)),
//         .visual = .{ .border = .sharp(.all(1), .palette(.text_color)), .cursor = .pointer },
//         .transition = .{ .duration = 100 },
//         .interactive = .hover_scale(),
//     };
//     pub const button_text = &Vapor.Style{
//         .visual = .{ .font_size = 18 },
//         .font_family = "Montserrat",
//     };
//     pub const counter = &Vapor.Style{
//         .size = .{ .width = .px(48) },
//         .visual = .font(32, 700, .palette(.text_color)),
//     };
// };
// var text: []const u8 = "";
// fn logText(evt: *Vapor.Event) void {
//     Vapor.print("From Text: {s}", .{evt.text()});
// }
//
// fn CommonButton() Vapor.Builder {
//     return Button(.{ .on_press = increment })
//         .border(.sharp(.all(1), .black))
//         .padding(.tblr(4, 4, 8, 8));
// }
//
// var binded: Vapor.Binded = .{};
// var draggable_id: usize = 0;
// var intialX: f32 = 0;
// var intialY: f32 = 0;
// var x: f32 = 0;
// var y: f32 = 0;
// var currentX: f32 = 0;
// var currentY: f32 = 0;
// fn drag(evt: *Vapor.Event) void {
//     evt.preventDefault();
//     const deltaX = evt.clientX() - intialX;
//     const deltaY = evt.clientY() - intialY;
//     x = currentX + deltaX;
//     y = currentY + deltaY;
//
//     binded.translate3d(.{ .x = x, .y = y });
//     // Vapor.print("Box: {any} {any}", .{ x, y });
// }
//
// fn addDraggable(_: *Vapor.Event) void {
//     // Vapor.print("Box: addDraggable Client {any} {any}", .{ evt.clientX(), evt.clientY() });
//     // Vapor.print("Box: addDraggable Offset {any} {any}", .{ evt.offsetX(), evt.offsetY() });
//     // intialX = evt.clientX();
//     // intialY = evt.clientY();
//     // draggable_id = draggable.addListener(.mousemove, drag) orelse unreachable;
// }
//
// fn removeDraggable(_: *Vapor.Event) void {
//     Vapor.print("Box: removeDraggable", .{});
//     _ = draggable.removeListener(.mousemove, draggable_id);
// }
//
// var draggable: Draggable = .{
//     // .on_drag = onDrag,
// };
// // fn mount() void {
// //     _ = draggable(&binded);
// // }
//
// fn onDrag(self: *Draggable, evt: *Vapor.Event) void {
//     Vapor.print("Box: onDrag {any}", .{evt});
//     self.updatePosition(self.x, self.y);
// }
//
// var drop_area: Vapor.Binded = .{};
//
// fn mount() void {
//     Vapor.println("mount", .{});
//     counter = 10;
//     Vapor.cycle();
// }
//
// fn onDragOver(evt: *Vapor.Event) void {
//     Vapor.print("Drag: onDrop {any}", .{evt});
// }
//
// fn App() void {
//     vaporize.compileForm(Form) catch unreachable;
//
//     // Text("Hello").end();
//     // CounterWithBuider();
//
//     // Vaporize.init();
//     // Center().size(.full).children({
//     // Static.Hooks(.{ .mounted = mount })({
//     //     Box().size(.full).layout(.x_between_center).children({
//     //         Box().width(.percent(25)).height(.percent(100)).background(.blue).children({
//     //             Text("Drag Here").end();
//     //         });
//     //         Box()
//     //             .pos(.absolute)
//     //             .width(.px(100)).height(.px(100))
//     //             .background(.red)
//     //             .createDraggable(&draggable)
//     //             .end();
//     //         Box().ref(&drop_area).width(.percent(25)).height(.percent(100)).background(.green).children({
//     //             Text("Drop Here").end();
//     //         });
//     //     });
//     // });
//     // });
// }
// const Count = struct {
//     count: u32,
// };
//
// fn fetchCounter() void {
//     _ = Vapor.Kit.fetch("http://localhost:8080/ping", handleCounter, .{ .method = .GET });
//     // const resp = future.await();
//     // Vapor.print("Fetched {any}", .{resp});
// }
//
// fn handleCounter(resp: Vapor.Kit.Response) void {
//     switch (resp) {
//         .ok => |data| {
//             const parsed = Vapor.Kit.glue(Count, data.body) catch |err| {
//                 Vapor.printErr("Failed to parse response: {any}", .{err});
//                 return;
//             };
//             counter = parsed.count;
//         },
//         .err => |err| {
//             Vapor.printErr("Failed to fetch: {s}", .{err.message});
//             return;
//         },
//     }
// }

//
// const Form2 = struct {
//     height: u32 = 0,
//     weight: u32 = 0,
//     pub var __validations = .{
//         .weight = Vaporize.Validation{
//             .min_value = 18,
//             .max_value = 120,
//             .err = "Weight must be between 5 and 250",
//         },
//         .height = Vaporize.Validation{
//             .min_value = 18,
//             .max_value = 120,
//             .err = "Height must be between 100 and 210",
//         },
//     };
// };

// fn CommonButton() Vapor.Builder {
//     return Button(.{ .on_press = increment })
//         .border(.sharp(.all(1), .black))
//         .padding(.tblr(4, 4, 8, 8));
// }

const Form = struct {
    username: []const u8 = "",
    email: []const u8 = "",
    phonenumber: []const u8 = "",
    password: []const u8 = "",
    age: u32 = 0,

    pub var __validations = .{
        .username = Vaporize.Validation{ .min = 3, .max = 10, .err = "Username must be between 3 and 10 characters" },
        .email = Vaporize.Validation{ .field_type = .email },
        .phonenumber = Vaporize.Validation{ .field_type = .telephone },
        .password = Vaporize.Validation{ .field_type = .password },
        .age = Vaporize.Validation{
            .min_value = 18,
            .max_value = 120,
            .err = "Age must be between 18 and 120",
        },
    };
};

var new_form: vaporize.Form(Form) = undefined;
fn App() void {
    // Text("Hello").end();
    // CommonButton().background(.red).children({
    //     Text("Hello").end();
    // });
    //
    // CommonButton().background(.blue).padding(.all(10)).border(.dashed(.all(1), .black)).children({
    //     Text("Hello").end();
    // });
    //
    //
    Stack().direction(.column).layout(.top_center).size(.full).children({
        Stack().width(.percent(60)).layout(.center).padding(.all(16))
            .border(.sharp(.tblr(1, 0, 0, 1), .palette(.text_color)))
            .children({
            Stack()
                .width(.percent(100)).layout(.center).spacing(16)
                .border(.simple(.palette(.text_color)))
                .children({
                Text("SIGN UP").font(84, 900, .palette(.text_color))
                    .padding(.horizontal(12))
                    .border(.bottom(.palette(.text_color)))
                    .layout(.center)
                    .width(.percent(100))
                    .end();
                Stack()
                    .width(.percent(100)).layout(.center).spacing(16).padding(.all(20))
                    .children({
                    new_form.render();
                });
            });
        });
    });
}

// fn App2() void {
//     // vaporize.compile("Form") catch unreachable;
//     // vaporize.compile("Form") catch unreachable;
//     Box().width(.percent(30)).layout(.center).spacing(16).padding(.all(20)).children({
//         new_form2.render();
//     });
// }

const style_config = Vaporize.StyleConfig{
    .code_style = .{ .visual = .{ .text_color = .palette(.tint) } },
    .text_style = .{
        .visual = .{ .text_color = .palette(.text_color) },
    },
    .heading_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
    .text_field_style = .{
        .size = .hw(.px(38), .percent(100)),
        .padding = .tblr(4, 4, 8, 8),
        .transition = .{ .duration = 100 },
        .visual = .{
            .outline = .none,
            .border = .simple(.palette(.text_color)),
            .background = .palette(.background),
            .font_size = 18,
        },
        .interactive = .{
            .hover = .{
                .border = .simple(.palette(.tint)),
            },
        },
        .font_family = "Montserrat",
    },
    .struct_style = .{
        .layout = .left_center,
        .direction = .column,
        .child_gap = 8,
        .size = .hw(.fit, .percent(100)),
    },
    .list_style = .{ .layout = .left_center, .direction = .column, .child_gap = 8 },
    .button_style = .{
        .layout = .center,
        .size = .hw(.px(52), .percent(50)),
        .visual = .{
            .border = .none,
            .background = .palette(.text_color),
            .cursor = .pointer,
            .font_size = 18,
            .text_color = .white,
        },
        .transition = .{ .duration = 100 },
        .interactive = .hoverScaleTextBackground(.white, .palette(.tint)),
        .child_gap = 8,
        .font_family = "Montserrat",
    },
};
//
// var new_form2: vaporize.comptimeForm(Form2) = undefined;
pub var vaporize: Vaporize.Compiler = undefined;
pub export fn init() void {
    // InitializeVapor
    Vapor.init(.{
        .mode = .atomic, // .atomic
    });

    // vaporize = Vaporize.init(Vapor.arena(.persist), .{
    //     .code_style = .{ .visual = .{ .text_color = .palette(.tint) } },
    //     .text_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
    // }) catch unreachable;
    vaporize = Vaporize.init(Vapor.arena(.persist), style_config) catch unreachable;
    // new_form.compile() catch unreachable;

    // // initHooks();
    //
    // Global style variables
    Vapor.setGlobalStyleVariables(.{ // Adds 11kb
        .themes = &[_]Vapor.ThemeDefinition{
            Vapor.ThemeDefinition{ .name = "light", .theme = Theme.Light, .default = true },
            Vapor.ThemeDefinition{ .name = "dark", .theme = Theme.Dark },
        },
    });

    // Initialize your root component or app
    registerLayouts() catch |err| {
        Vapor.lib.printlnSrcErr("Failed to register layout {any}", .{err}, @src());
    };
    initPages();
    // Vapor.Page(.{ .route = "/" }, App, null);
    // Vapor.Page(.{ .route = "/fjlskfj" }, App2, null);
}

pub fn main() void {}
