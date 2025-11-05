const std = @import("std");
const Vapor = @import("fabric");
const Binded = Vapor.Binded;
const Static = Vapor.Static;
const TextField = Static.TextField;

var binded_textfield: Binded = Binded{};
fn onWrite(evt: *Vapor.Event) void {
    const input_text = evt.text();
    Vapor.println("{s}", .{input_text});
}

fn onKeyPress(evt: *Vapor.Event) void {
    const key = evt.key();
    if (std.mem.eql(u8, key, "k") and evt.metaKey()) {
        evt.preventDefault();
        Vapor.println("Open dialog\n", .{});
    } else if (std.mem.eql(u8, key, "Escape")) {
        evt.preventDefault();
        Vapor.println("Close dialog\n", .{});
    }
}

var listener_id: ?u32 = null;
fn mount() void {
    // Here we set globally and event listener for onKeyDown
    Vapor.eventListener(.keydown, onKeyPress);
    // here we attache a listener to the element itself
    listener_id = Vapor.addListener(binded_textfield.element, .keydown, onKeyPress);
}

fn destroy() void {
    // Here we remove the listener
    if (listener_id) |id| {
        Vapor.removeListener(id);
    }
}

pub fn render() void {
    // Hooks calls to mount when all its children have been added to screen.
    Static.Hooks(.{ .mounted = mount, .destroy = destroy })({
        TextField(.string)
            .bind(&binded_textfield)
            .onChange(onWrite)
            .plain();
    });
}
