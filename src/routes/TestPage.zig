const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Box = Static.Box;
const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const Center = Static.Center;
const List = Static.List;
const ListItem = Static.ListItem;
const Stack = Static.Stack;
const Graphic = Static.Graphic;
const TextFmt = Static.TextFmt;
const Icon = Static.Icon;
const TextField = Static.TextField;
const Hooks = Static.Hooks;
const Mark = Fabric.Mark;

const Page = Fabric.Page;

var random: std.Random.DefaultPrng = std.Random.DefaultPrng.init(14);
var rand_num: usize = undefined;
const Item = struct { id: []const u8, value: usize };
var buffer: [100]Item = undefined;
var counter: usize = 0;
var length: usize = 10;
var list: std.array_list.Managed(Item) = undefined;

// var binded_textfield: Fabric.Binded = .{};
// var text: Fabric.Signal([]const u8) = undefined;
// var root_node: *Mark.Node = undefined;
pub fn init() void {
    // 1. Initialize the parser
    // const allocator = Fabric.lib.frame_arena.getFrameAllocator();
    // var parser = Mark.Parser.init(allocator, @embedFile("test.md"));

    // 2. Run the parser
    // root_node = parser.parse() catch unreachable;

    // text.init("isFocused");
    Page(@src(), render, null);
    // list = std.array_list.Managed(Item).init(Fabric.lib.allocator_global);
    // for (0..buffer.len) |i| {
    //     buffer[i] = .{ .value = i, .id = std.fmt.allocPrint(Fabric.lib.allocator_global, "{d}", .{i}) catch unreachable };
    // }
    // list.appendSlice(&buffer) catch |err| Fabric.lib.printlnErr("Error appending {any}", .{err});
}

fn increment() void {
    counter += 1;
    // rand_num = random.random().intRangeAtMost(usize, 1, list.items.len);
    // list.append() catch |err| Fabric.lib.printlnErr("Error appending {any}", .{err});
    Fabric.cycle();
}

fn decrement() void {
    rand_num = random.random().intRangeAtMost(usize, 1, list.items.len);
    if (list.items.len == 0 or rand_num > list.items.len - 1) return;
    // if (counter == 0) return;
    // counter -= 1;
    const item = list.orderedRemove(rand_num);
    Fabric.println("Removed {s}", .{item.id});
    // length -= 1;
    Fabric.cycle();
}

pub fn shuffle() void {
    random.random().shuffle(usize, &buffer);
    rand_num = random.random().intRangeAtMost(usize, 1, 5);
}

const funcs = [_]struct { func: *const fn () void, text: []const u8 }{
    // .{ .func = increment, .text = "Increment" },
    .{ .func = decrement, .text = "Decrement" },
};

fn log(_: *Fabric.Event) void {
    // Fabric.println("From binded Text: {s}", .{binded_textfield.text});
    // Fabric.println("From event Text : {s}", .{evt.text()});
    // binded_textfield.setText("Hello World");
}

// fn mount() void {
//     _ = binded_textfield.addListener(.focus, changeColor);
//     binded_textfield.focus();
//     Fabric.print("{any}", .{text.compare("isFocused")});
// }
//
// fn changeColor(_: *Fabric.Event) void {
//     if (binded_textfield.focused()) {
//         text.set("isFocused");
//     } else {
//         text.set("isNotFocused");
//     }
// }
//
// fn blur(_: *Fabric.Event) void {
//     Fabric.println("blur", .{});
//     text.set("isNotFocused");
// }

// const eql = std.mem.eql;
fn render() void {
    Text("Hello World").close();
    // Mark.traverse(root_node, .{}) catch unreachable;
    // Hooks(.{ .mounted = mount } )({
    //     TextField(.string)
    //         .bind(&binded_textfield)
    //         .onChange(log)
    //         .onFocus(changeColor)
    //         .onBlur(blur)
    //         .plain();
    // });

    // Button(.{ .on_press = binded_textfield.focus }).body()({
    // Text(text.get()).font(18, 700, if (eql(u8, text.get(), "isFocused")) .red else .palette(.text_color)).close();
    // });

    // Box.style(&.{ .size = .{ .width = .fit, .height = .px(160) } })({});
    // for (funcs) |stct| {
    //     Button(.{ .on_press = stct.func, .aria_label = stct.text }).size(.{ .width = .fit, .height = .px(160) }).body()({
    //         // TextFmt("{s}: {d}", .{ stct.text, counter }).id("counter").style(&.{
    //         //     .layout = .center,
    //         //     .visual = .font(18, 700, if (counter % 2 == 0) .red else .palette(.text_color)),
    //         // });
    //         TextFmt("{s}: {d}", .{ stct.text, counter }).font(18, 700, if (counter % 2 == 0) .red else .palette(.text_color)).layout(.center).close();
    //     });
    // }
    // // for (buffer[0..]) |i| {
    // //     // Fabric.println("i: {d}", .{i});
    // //     TextFmt("Index: {d}", .{i}).font(18, 500, .palette(.text_color)).close();
    // // }
    //
    // // for (0..length) |i| {
    // //     TextFmt("Index: {d}", .{i}).font(18, 500, .palette(.text_color)).close();
    // // }
    //
    // for (list.items) |i| {
    //     TextFmt("{d}", .{i.value}).font(18, 500, .palette(.text_color)).layout(.center).close();
    // }
}
