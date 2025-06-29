const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");

// Initialization
var wasi_js_code_editor: CodeEditor = undefined;
var chart_code_editor: CodeEditor = undefined;
var chart_use_code_editor: CodeEditor = undefined;
pub fn init() void {
    wasi_js_code_editor.init(&Fabric.lib.allocator_global, @embedFile("chart.js"));
    chart_code_editor.init(&Fabric.lib.allocator_global, @embedFile("chart_sample.zig"));
    chart_use_code_editor.init(&Fabric.lib.allocator_global, @embedFile("chart_use_case_sample.zig"));
    // sample_inst_events.init(&Fabric.lib.allocator_global, @embedFile("inst_even_sample.zig"));
}

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
        Static.Text("WASM Bridge", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt("The WASM Bridge is a comprehensive JavaScript-to-WebAssembly interface that enables seamless bidirectional communication between JavaScript and WebAssembly (WASM) modules in web applications. This bridge is particularly designed for WASM-based UI frameworks where the core application logic runs in WebAssembly while DOM manipulation and browser APIs are handled through JavaScript.");
        Static.Svg(@embedFile("bridge.svg"), .{
            .width = .percent(100),
            .height = .percent(100),
        });
        Static.Text("Architecture", .{
            .font_size = 28,
            .font_weight = 700,
        });
        Txt("The bridge consists of two main components:");
        Static.List(.{ .padding = .{ .left = 32 } })({
            Static.ListItem(.{})({
                Static.HtmlText("<strong>Import Object (wasi_env/extern functions)</strong> - Functions that WASM can call to interact with JavaScript/DOM", .{});
            });
            Static.ListItem(.{})({
                Static.HtmlText("<strong>Export Functions</strong> - WASM functions that JavaScript can call", .{});
            });
        });
        Txt("We can add our own additions to the wasi_env.js like so...");
        Static.Text("wasi_env.js", .{
            .font_size = 18,
            .font_weight = 700,
        });
        wasi_js_code_editor.render(0);
        Txt("Here we create the js side code to add or create a chart using the chart.js library.");
        Static.Text("main.zig", .{
            .font_size = 18,
            .font_weight = 700,
        });
        chart_code_editor.render(0);
        Txt("Then we create a extern function which gives our wasm code the ability to access this function.");
        Static.Text("How we use it?", .{
            .font_size = 18,
            .font_weight = 700,
        });
        chart_use_code_editor.render(0);
        Static.Text("Why is it so complicated?", .{
            .font_size = 18,
            .font_weight = 700,
        });
        Txt("Unlike JavaScript's high-level data types, WebAssembly operates with a fundamentally different memory model. Since WASM predates many modern web APIs and has different design constraints, the ergonomics of JavaScript-WASM interoperability require lower-level memory management.");
        Static.HtmlText("<strong>The Challenge</strong>: WebAssembly doesn't natively understand JavaScript concepts like strings, arrays, or objects. Instead, WASM works with linear memory—essentially one large contiguous buffer of bytes. When passing data between JavaScript and WASM, we must work at the pointer level.", .{ .font_size = 18 });
        Txt("The pointer acts as a memory address marker, and by adding the length, we define the exact boundaries of our data—this allows us to slice the specific string from the vast buffer of WASM memory, starting at the pointer location and extending for the specified number of bytes.");
    });
}
