const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");

// Initialization
var sample_events: CodeEditor = undefined;
var sample_inst_events: CodeEditor = undefined;
pub fn init() void {}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

pub fn render() void {
    Static.FlexBox(.{
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Project Structure", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt("Project structure in Fabric, is really up to you, by default fabric, uses the routes directory to hold all the routes");
        Static.Svg(@embedFile("routes.svg"), .{
            .width = .percent(50),
            .height = .percent(50),
        });
        Txt("The web directory holds the wasm bridge files, for connecting JS to fabric.wasm.");
        Txt("The src directory hold main, and anything else you want to use or create.");
        Txt("You make your application your own, Fabric core philosophy, is to be flexible, and adaptable.");
        Static.Text("web/", .{
            .font_size = 28,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text("wasi_obj.js", .{
            .font_size = 18,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt("wasi_obj.js includes the core of the wasm functionality this is where we fetch fabric.wasm, instantiate and render the routes. Loop to check if the UI needs to be updated.");
        Txt("wasi_obj.js handles the removal and addition of UI nodes, as well as window and route navigation. This file is the root, .js file and where all the js files work together.");
        Static.Text("wasi_env.js", .{
            .font_size = 18,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt("This file implements a WebAssembly (WASM) import object that provides JavaScript bindings for a web framework called \"Fabric\" written in Zig. It defines numerous functions that allow the WASM module to interact with the DOM, handle events, manage local storage, make HTTP requests, and control various browser APIs like clipboard access and navigation. The code essentially serves as a bridge between the Zig/WASM backend and JavaScript frontend, enabling the WASM application to manipulate web pages and respond to user interactions.");
        Static.Svg(@embedFile("bridge.svg"), .{
            .width = .percent(100),
            .height = .percent(100),
        });
        Static.Text("traversal.js", .{
            .font_size = 18,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt("This is Fabric's core DOM rendering engine that translates WebAssembly render commands into actual HTML elements. It handles 45+ component types, manages a virtual DOM-like system with dirty checking for efficient updates, and bridges JavaScript DOM APIs with the WASM runtime. The file also includes specialized features like client-side routing, a JSON editor component, and lifecycle hooks for component management.");
    });
}
