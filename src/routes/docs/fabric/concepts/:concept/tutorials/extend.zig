const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Player = enum { x, o }; // 🚧

const GridBox = struct { // 🚧
    clicked: bool = false,
    player: Player = undefined,
};

// Compile‑time embed of the SVG markup.
fn drawX() void { // 🚧
    Static.Svg(@embedFile("../assets/X.svg"), .{ .width = .px(42), .height = .px(42) });
}

fn drawO() void { // 🚧
    Static.Svg(@embedFile("../assets/O.svg"), .{ .width = .px(42), .height = .px(42) });
}

var grid_boxes: [9]GridBox = undefined;
var current_player: Player = .x; // 🚧

/// Initialise the board for a new game.
pub fn init() void {
    for (&grid_boxes) |*box| box.* = GridBox{};
    current_player = .x; // 🚧
}

/// Button callback when a square is selected. // 🚧
fn selectBox(box: *GridBox) void {
    Fabric.println("Selecting a box!", .{});
    if (box.clicked) return; // Ignore already‑played squares

    box.clicked = true;
    box.player = current_player;

    // TODO: call win‑detection here.

    // Swap turns
    current_player = switch (current_player) {
        .x => .o,
        .o => .x,
    };

    // Mark the component dirty so Fabric schedules a re‑render.
}

/// Render the interactive grid.
pub fn render() void {
    Static.FlexBox(.{
        .width = .percent(100),
        .height = .percent(100),
        .flex_wrap = .wrap,
    })({
        for (&grid_boxes) |*box| {
            Static.CtxButton(selectBox, .{box}, .{
                .display = .Center, // 🚧
                .border_color = .hex("#CCCCCC"),
                .border_thickness = .all(1),
                .width = .percent(33),
                .height = .percent(33),
                .padding = .all(24),
            })({
                if (box.clicked) switch (box.player) { // 🚧
                    .x => drawX(),
                    .o => drawO(),
                };
            });
        }
    });
}
