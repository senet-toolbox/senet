const std = @import("std");
const Vapor = @import("vapor");
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Box = Static.Box;
const Button = Static.Button;
const TextFmt = Static.TextFmt;
const Page = Vapor.Page;

const Item = struct { id: []const u8, value: usize };
var buffer: [10000]Item = undefined;
var list: std.array_list.Managed(Item) = undefined;

pub fn init() void {
    // 1. Initialize the parser
    // const allocator = Vapor.lib.frame_arena.getFrameAllocator();
    // var parser = Mark.Parser.init(allocator, @embedFile("test.md"));

    // 2. Run the parser
    // root_node = parser.parse() catch unreachable;

    // text.init("isFocused");
    Page(.{ .src = @src() }, render, null);
    // list = std.array_list.Managed(Item).init(Vapor.lib.allocator_global);
    // for (0..buffer.len) |i| {
    //     buffer[i] = .{ .value = i, .id = std.fmt.allocPrint(Vapor.lib.allocator_global, "{d}", .{i}) catch unreachable };
    // }
    // list.appendSlice(&buffer) catch |err| Vapor.lib.printlnErr("Error appending {any}", .{err});
}

fn remove() void {
    if (list.items.len == 0) return;
    const item = list.orderedRemove(0);
    Vapor.println("Removed {s}", .{item.id});
    Vapor.cycle();
}

pub fn render() void {
    Box.style(&.{
        .child_gap = 8,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .size = .w(.percent(100)),
    })({
        Static.Text("Hello").plain();
        // Button(.{ .on_press = remove })
        //     .size(.{ .width = .fit, .height = .fit })
        //     .background(.transparent)
        //     .cursor(.pointer)
        //     .border(.simple(.palette(.border_color_light)))
        //     .body()({
        //     TextFmt("Remove first Item", .{}).font(18, 500, .palette(.text_color)).layout(.center).close();
        // });
        // Box.layout(.flex)
        //     .wrap(.wrap)
        //     .body()({
        //     for (list.items) |i| {
        //         TextFmt("{d},", .{i.value}).font(18, 500, .palette(.text_color)).layout(.center).close();
        //     }
        // });
    });
}
