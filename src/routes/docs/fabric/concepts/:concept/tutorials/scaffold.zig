const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;

/// Called from `instantiate()` to register the page.
pub fn init() void {
    // Source location (`@src()`) becomes the unique page key.
    Fabric.Page(@src(), render, null, .{});
}

/// Renders a full‑window flexbox with a header.
pub fn render() void {
    Static.Center(.{
        .width = .percent(100),
        .height = .percent(100),
    })({
        Static.Text("Tic‑Tac‑Toe!", .{});
    });
}
