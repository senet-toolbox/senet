const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const ViewCode = @import("../ViewCode.zig");
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

var view_code: ViewCode = undefined;
var code_editor: CodeEditor = undefined;
// Initialization
pub fn init() void {
    code_editor.init(&Fabric.lib.allocator_global, @embedFile("main_sample.zig"));
}

// Deinitialization
pub fn deinit() void {}

// Render
pub fn render() void {
    // Page Header
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 8,
        .direction = .column,
    })({
        Static.Text("Basics", .{
            .font_size = 42,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text("The main.zig file is the root entry point for your Reverb server", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
        });
    });
    Static.Text(
        \\Reverb uses a single threaded event-loop known as Loom underneath the hood. Loom handles the reading and writing to 
        \\and from the client.
    , .{
        .font_size = 18,
    });
    Custom.PreImage("/assets/reverb_basics.webp", .{
        .width = .percent(100),
        .height = .percent(100),
    });
    Static.Column(.{
        .width = .percent(100),
    })({
        Static.Text("main.zig", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .bottom = 16 },
        });
        Custom.Intersection(.{
            .width = .percent(100),
        })({
            code_editor.render(0);
        });
    });

    // Core Functions Section
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 16,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Core Functions", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .bottom = 16 },
        });

        Static.FlexBox(.{
            .child_alignment = .{ .x = .start, .y = .start },
            .child_gap = 12,
            .direction = .column,
            .border_radius = .all(8),
            .margin = .{ .bottom = 20 },
        })({
            Static.Text("Config", .{
                .font_size = 18,
                .font_weight = 600,
                .text_color = .hex("#802BFF"),
                .font_family = "monospace",
            });
            Static.Text(
                \\The Config struct is used to configure the server. It contains the server address and port.
                \\The server address is the IP address or hostname of the server.
                \\The server port is the port number that the server will listen on.
            , .{
                .font_size = 18,
                .text_color = .hex("#4a4a4a"),
            });
        });

        // instantiate function
        Static.FlexBox(.{
            .child_alignment = .{ .x = .start, .y = .start },
            .child_gap = 12,
            .direction = .column,
            .border_radius = .all(8),
            .margin = .{ .bottom = 20 },
        })({
            Static.Text("new(Config, allocator: *Allocator)", .{
                .font_size = 18,
                .font_weight = 600,
                .text_color = .hex("#802BFF"),
                .font_family = "monospace",
            });
            Static.Text("This function initializes the Reverb framework and sets up the application environment.", .{
                .font_size = 18,
                .text_color = .hex("#4a4a4a"),
            });
        });

        // renderUI function
        Static.FlexBox(.{
            .child_alignment = .{ .x = .start, .y = .start },
            .child_gap = 12,
            .direction = .column,
            .border_radius = .all(8),
            .margin = .{ .bottom = 20 },
        })({
            Static.Text("addRoute([]const u8, []const u8, fn (*Context) anyerror!void, []const fn (*Context) anyerror!void)", .{
                .font_size = 18,
                .font_weight = 600,
                .text_color = .hex("#802BFF"),
                .font_family = "monospace",
            });
            Static.Text(
                \\This function adds a route to the server. The route is a combination of the path, method, and handler function.
                \\The last argument is a slice of middleware functions, which are called before the handler function.
                \\Middleware functions are called in the order they are passed into the server.
                \\The handler function is called when the route is matched and the request is made.
            , .{
                .font_size = 18,
                .text_color = .hex("#4a4a4a"),
            });
        });
        // renderUI function
        Static.FlexBox(.{
            .child_alignment = .{ .x = .start, .y = .start },
            .child_gap = 12,
            .direction = .column,
            .border_radius = .all(8),
            .margin = .{ .bottom = 20 },
        })({
            Static.Text("*Context", .{
                .font_size = 18,
                .font_weight = 600,
                .text_color = .hex("#802BFF"),
                .font_family = "monospace",
            });
            Static.Text(
                \\*Context is a struct that contains all the information about the request and response. 
                \\It is passed into every handler function, and is mutable by default.  
                \\Context values should not be used outside the handler function or taken reference to after the handler function returns.
                \\Context works similarly to the Context struct in Echo, but is a bit more flexible.
            , .{
                .font_size = 18,
                .text_color = .hex("#4a4a4a"),
            });
        });
    });
}
