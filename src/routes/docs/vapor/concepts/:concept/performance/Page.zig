const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Vaporize = @import("vaporize");
const Box = Static.Box;
const Custom = @import("../../../../../../components/Custom.zig");
const Content = @import("../../../../../../components/Content.zig");
const snippet = Custom.code_snippet_single;

// Initialization
var sample_events: CodeEditor = undefined;
var sample_inst_events: CodeEditor = undefined;
var performance_page: *Vaporize.Node = undefined;
var content: Content.new(@embedFile("performance_page.md")) = undefined;
pub fn init() void {
    content = .{};
    content.init();
    // content.init(@embedFile("performance_page.md"));
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("performance_page.md"));
    performance_page = parser.parse() catch unreachable;
    list = std.array_list.Managed(Item).init(Vapor.lib.allocator_global);
    for (0..buffer.len) |i| {
        buffer[i] = .{ .value = i, .id = std.fmt.allocPrint(Vapor.lib.allocator_global, "{d}", .{i}) catch unreachable };
    }
    list.appendSlice(&buffer) catch |err| Vapor.lib.printlnErr("Error appending {any}", .{err});
}

const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const TextFmt = Static.TextFmt;

const Item = struct { id: []const u8, value: usize };
var buffer: [100]Item = undefined;
var list: std.array_list.Managed(Item) = undefined;

fn remove() void {
    if (list.items.len == 0) return;
    const item = list.orderedRemove(0);
    Vapor.println("Removed {s}", .{item.id});
    Vapor.cycle();
}

fn component() void {
    Vaporize.traverse(performance_page, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color),
        .heading_color = .palette(.text_color),
    }, void, null) catch unreachable;
    snippet("metal create fullstack myapp");
    Button(.{ .on_press = remove })
        .size(.{ .width = .fit, .height = .fit })
        .background(.transparent)
        .cursor(.pointer)
        .border(.simple(.palette(.border_color_light)))
        .body()({
        TextFmt("Remove first Item", .{}).font(18, 500, .palette(.text_color)).layout(.center).close();
    });
    Box.layout(.flex)
        .wrap(.wrap)
        .body()({
        for (list.items) |i| {
            TextFmt("{d},", .{i.value}).font(18, 500, .palette(.text_color)).layout(.center).close();
        }
    });
}

pub fn render() void {
    content.content(component);
    // Box.style(&.{
    //     .child_gap = 8,
    //     .direction = .column,
    //     .margin = .{ .bottom = 32 },
    //     .size = .w(.percent(100)),
    // })({
    //     Vaporize.traverse(performance_page, .{
    //         .code_color = .palette(.tint),
    //         .text_color = .palette(.text_color),
    //         .heading_color = .palette(.text_color),
    //     }, void, null) catch unreachable;
    //     snippet("metal create fullstack myapp");
    //     Button(.{ .on_press = remove })
    //         .size(.{ .width = .fit, .height = .fit })
    //         .background(.transparent)
    //         .cursor(.pointer)
    //         .border(.simple(.palette(.border_color_light)))
    //         .body()({
    //         TextFmt("Remove first Item", .{}).font(18, 500, .palette(.text_color)).layout(.center).close();
    //     });
    //     Box.layout(.flex)
    //         .wrap(.wrap)
    //         .body()({
    //         for (list.items) |i| {
    //             TextFmt("{d},", .{i.value}).font(18, 500, .palette(.text_color)).layout(.center).close();
    //         }
    //     });
    // });
}
