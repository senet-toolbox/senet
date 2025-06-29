const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Element = Fabric.Element;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Binded = Fabric.Binded;

var input_element: Element = Element{};
fn onWrite(evt: *Fabric.Event) void {
    const input_text = evt.text();
    Fabric.println("{s}", .{input_text});
}

fn onKeyPress(evt: *Fabric.Event) void {
    const key = evt.key();
    if (std.mem.eql(u8, key, "k") and evt.metaKey()) {
        evt.preventDefault();
        Fabric.println("Open dialog\n", .{});
    } else if (std.mem.eql(u8, key, "Escape")) {
        evt.preventDefault();
        Fabric.println("Close dialog\n", .{});
    }
}

fn mount() void {
    // Here we set globally and event listener for onKeyDown
    Fabric.lib.eventListener(.keydown, onKeyPress);
    // here we attache a listener to the element itself
    input_element.addListener(.input, onWrite);
}

pub fn render() void {
    // Hooks calls to mount when all its children have been added to screen.
    Static.Hooks(.{ .mounted = mount }, .{})({
        Binded.Input(&input_element, .{
            .string = .{ .default = "Type text here..." },
        }, Style{
            .outline = .none,
            .border_color = .hex("#000000"),
            .padding = .all(4),
        });
    });
}
