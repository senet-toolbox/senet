const std = @import("std");
const Fabric = @import("vapor");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

// Initialization
var wasi_js_code_editor: CodeEditor = undefined;
var chart_code_editor: CodeEditor = undefined;
var chart_use_code_editor: CodeEditor = undefined;
var wasm_chart_code_editor: CodeEditor = undefined;
pub fn init() void {
    wasi_js_code_editor.init(&Fabric.lib.allocator_global, @embedFile("chart.js"));
    chart_code_editor.init(&Fabric.lib.allocator_global, @embedFile("chart_sample.zig"));
    chart_use_code_editor.init(&Fabric.lib.allocator_global, @embedFile("chart_use_case_sample.zig"));
    wasm_chart_code_editor.init(&Fabric.lib.allocator_global, @embedFile("wasm_chart_sample.zig"));
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
        Static.Text("Adding JS Libraries", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt(
            \\Fabric's philosophy to Javascript, is that Javascript is more glue than code. Libraries which are highly dynamic, ie Charts, or Graphics,  
            \\should be built with Javascript, but maintained and controlled by WASM. Fabric should handle the processing of data, and JS should 
            \\handle the Libary api calls.
        );
        Txt(
            \\In the previous section we talked about the WASM Bridge. We will now take a deeper look into 
            \\how we can add our favorite JS Libs, into Fabric.
        );
        Custom.HtmlText(
            \\In this example we will use <a href="https://www.chartjs.org/">chart.js</a> as the library sample. As you will see, 
            \\incorperating JS libs into Fabric, is a bit more cumbersome than the typical npm install... But since we are using WASM
            \\we can leverage its speed and type saftey while only using a few of the core features of chart.js.
        , .{
            .font_size = 18,
        });

        Static.Text("Steps", .{
            .font_size = 28,
            .font_weight = 700,
        });
        Static.List(.{
            .display = .Flex,
            .direction = .column,
            .child_gap = 16,
            .width = .percent(100),
        })({
            Static.ListItem(.{
                .list_style = .decimal,
            })({
                Txt(
                    \\Locate the index.html file and add the following cdn script tag:
                );
                Static.Text(
                    \\<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.9/dist/chart.umd.min.js"></script>
                , .{ .text_color = .hex("#802BFF"), .font_size = 18 });
                Txt(
                    \\This will import the entire library into our JS client. Later we will reduce this by only importing what we really use.
                );
            });
            Static.ListItem(.{
                .list_style = .decimal,
                .margin = .{ .top = 24, .bottom = 24 },
            })({
                Static.Image("/assets/chartfetching.webp", .{
                    .width = .percent(100),
                    .height = .percent(100),
                });
            });
            Static.ListItem(.{
                .list_style = .decimal,
            })({
                Txt(
                    \\Now lets add a function to the wasi_env.js file so we can create and edit charts from vapor.wasm.
                );
            });
            Static.ListItem(.{
                .list_style = .decimal,
                .width = .percent(100),
            })({
                wasi_js_code_editor.render(0);
            });
            Static.ListItem(.{
                .list_style = .decimal,
            })({
                Txt(
                    \\This function acts as a bridge between WebAssembly (WASM) code and JavaScript to create Chart.js charts. 
                    \\It's necessary because WASM and JavaScript cannot directly exchange string data - they can only pass numbers 
                    \\(including memory pointers).
                );
            });
            Static.List(.{
                .display = .Flex,
                .direction = .column,
                .child_gap = 16,
                .width = .percent(100),
            })({
                Static.ListItem(.{
                    .list_style = .decimal,
                })({
                    Custom.HtmlText(
                        \\<strong style="color: #802BFF">idPtr</strong> (number): Memory pointer to the start of the canvas element ID string in WASM memory
                    , .{ .font_size = 18 });
                });
                Static.ListItem(.{
                    .list_style = .decimal,
                })({
                    Custom.HtmlText(
                        \\<strong style="color: #802BFF">idLen</strong> (number): Length of the ID string in bytes
                    , .{ .font_size = 18 });
                });
                Static.ListItem(.{
                    .list_style = .decimal,
                })({
                    Custom.HtmlText(
                        \\<strong style="color: #802BFF">configPtr</strong> (number): Memory pointer to the start of the chart configuration JSON string in WASM memory
                    , .{ .font_size = 18 });
                });
                Static.ListItem(.{
                    .list_style = .decimal,
                })({
                    Custom.HtmlText(
                        \\<strong style="color: #802BFF">configLen</strong> (number): Length of the configuration string in bytes
                    , .{ .font_size = 18 });
                });
            });
            Static.ListItem(.{
                .list_style = .decimal,
            })({
                Txt(
                    \\In our Fabric codebase, we are going to JSON stringify the chart config and pass the pointer and length, to the JS side.
                );
            });
            Static.ListItem(.{
                .list_style = .decimal,
                .width = .percent(100),
            })({
                Static.Svg(@embedFile("bridge.svg"), .{
                    .width = .percent(100),
                    .height = .percent(100),
                });
            });
            Static.ListItem(.{
                .list_style = .decimal,
            })({
                Custom.HtmlText(
                    \\<strong style="color: #802BFF">requestAnimationFrame</strong> is a special type of browser function that says, 
                    \\"Hey! only run this code when you have loaded everything you need, then run the code."
                    \\This process is called "Repainting the DOM". 
                    \\It's like renovating a room: you wouldn't start painting the walls while the electrician is still 
                    \\installing outlets.
                    \\Or for example, lets say you want to paint a Gecko on the wall. First you need to lay the stencil down, 
                    \\and then you can start painting in all the colors.
                , .{ .font_size = 18 });
                Custom.HtmlText(
                    \\Similarly, <strong style="color: #802BFF">requestAnimationFrame</strong> ensures all the DOM elements are properly set 
                    \\up before your code tries to interact with them.
                    \\The browser essentially says: "Hold on, let me finish preparing everything, then I'll give you the 
                    \\green light to make your changes.
                , .{ .font_size = 18 });
            });
            Static.ListItem(.{ .list_style = .decimal, .width = .percent(100), .margin = .{ .bottom = 32 } })({
                Static.Image("/assets/repaint.webp", .{
                    .width = .percent(100),
                    .height = .percent(100),
                });
            });
            Static.ListItem(.{
                .list_style = .decimal,
            })({
                Static.Text("Wasm Side", .{
                    .font_size = 24,
                    .font_weight = 700,
                });
                Custom.HtmlText(
                    \\Now lets add our ZIG code so we can access <strong style="color: #802BFF">createChartWasm</strong>.
                    \\Create a new file anywhere you like. Then add the following code snippets:
                , .{ .font_size = 18 });
            });
            Static.ListItem(.{
                .list_style = .decimal,
                .width = .percent(100),
            })({
                wasm_chart_code_editor.render(0);
            });
            Static.ListItem(.{
                .list_style = .decimal,
            })({
                Static.Text("Now we can create Charts in Fabric and Zig", .{
                    .font_size = 24,
                    .font_weight = 700,
                });
            });
        });
        Static.Text("Yah I know it's annoying.", .{
            .font_size = 28,
            .font_weight = 700,
        });
        Custom.HtmlText(
            \\I'm not gonna pretend that creating multiple functions between the WASM side and JS side isn't 
            \\overly complex or frustrating. But unfortunately, the current state of WASM interoperability is limited 
            \\to passing pointers and numbers everywhere. But in the following year or so, we will be able to 
            \\grab objects from JS into WASM, and from WASM into JS, as well as strings and other data types. 
            \\Until then, this is the way it's done. There are some helper libs you can use that abstract away the boilerplate, 
            \\but I wanted to show you how it works under the hood. Now you know, and now you can build your own abstractions, or 
            \\forget using JS entirely, and build your own Chart.js version in Fabric or Zig.
        , .{ .font_size = 18 });
    });
}
