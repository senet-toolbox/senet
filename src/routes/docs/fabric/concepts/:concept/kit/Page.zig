const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const CodeEditor = @import("../CodeEditor.zig");

// Initialization
var sample_fetch: CodeEditor = undefined;
pub fn init() void {
    sample_fetch.init(&Fabric.lib.allocator_global, @embedFile("sample_fetch.zig"));
}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

// Render
pub fn render() void {
    // Page Header
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Kit", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt("Fabric Kit is a utils module which contains the functions for fetching, navigation, parsing, url encoding and decoding, ect...");
        Txt("This module serves as a bridge between Zig applications running in WebAssembly and web browser APIs, providing essential networking, navigation, and data processing capabilities. ");
        Static.Svg(@embedFile("wasi_bridge.svg"), .{
            .width = .percent(100),
            .height = .percent(100),
        });
        Txt("While the above does look complex in implementation, usage is quite simple. In the future fetching will become even simpler with greater integration of WASM and JS.");
        Static.Center(.{})({
            sample_fetch.render(0);
        });
        Txt("There have been many approaches to fetching and handling response/requests. Fabric adopts a straightforward, callback-based approach for handling HTTP requests and responses, viewing the application as a static state machine. This means all application code executes sequentially, without waiting for asynchronous operations to complete. Such a design compels a more deliberate consideration of the application's state when data is not yet available.");
        Static.Svg(@embedFile("fetching.svg"), .{
            .width = .percent(100),
            .height = .percent(100),
        });
        Txt("This architecture treats components dependent on server-side data as isolated \"islands\" or modules. A long-running request or a malformed response within one island will not disrupt the execution of the rest of the application. In contrast to many JavaScript frameworks where a single async operation can block rendering, Fabric's modularity ensures continuous operation.");
        Txt("Since we employ callbacks, the DOM is only updated when you are done handling it. Fetching data does not impose immediate cost on the application's runtime. This keeps Fabric and any server-side application independent of each other, reinforcing its flexibility and modular design.");
        Static.Text("Functions", .{
            .font_size = 28,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text("fetch(url, callback, http_req)", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });

        Txt("Performs asynchronous HTTP requests to the specified URL with customizable headers, body, and request options, executing the provided callback when the response is received.");
        Static.Text("fetchWithParams(url, self, callback, http_req)", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Txt("Similar to fetch but includes additional context parameters, allowing for more complex callback scenarios where state needs to be passed through the request lifecycle.");
        Static.Text("glue(T, value, slice)", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Txt("Deserializes JSON data from a byte slice into a strongly-typed Zig struct, providing type-safe data binding for API responses and configuration.");
       Static.Text("navigate(path)", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Txt("Simple navigate function, will navigate to a new route.");
        Static.Text("parseParams(url, allocator)", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Txt("Extracts and decodes URL query parameters into a hash map, handling URL encoding and providing easy access to request parameters.");
        Static.Text("QueryBuilder", .{
            .font_size = 18,
            .font_weight = 600,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Txt("A comprehensive URL query string builder with methods for adding parameters (add), URL encoding (urlEncoder), and generating complete URLs (generateUrl).");
    });
}
