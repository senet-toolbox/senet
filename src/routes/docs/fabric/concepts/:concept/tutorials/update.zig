const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Signal = Fabric.Signal; // 👈 Add the signal;

const Player = enum { x, o };

const GridBox = struct {
    clicked: bool = false,
    player: Player = undefined,
};

// Compile‑time embed of the SVG markup.
fn drawX() void {
    Static.Svg(@embedFile("../assets/X.svg"), .{ .width = .fixed(42), .height = .fixed(42) });
}

fn drawO() void {
    Static.Svg(@embedFile("../assets/O.svg"), .{ .width = .fixed(42), .height = .fixed(42) });
}

var grid_boxes: [9]GridBox = undefined;
var current_player: Player = .x;
var rerender: Signal(void) = undefined;
/// Initialise the board for a new game.
pub fn init() void {
    for (&grid_boxes) |*box| box.* = GridBox{};
    current_player = .x;
    rerender.init({}); // Initialise the force signal once
}

/// Button callback when a square is selected.
fn selectBox(box: *GridBox) void {
    if (box.clicked) {
        Fabric.println("This square is already taken!", .{});
        return;
    }

    box.clicked = true;
    box.player = current_player;

    // TODO: call checkWin() here.

    // Toggle turn
    current_player = switch (current_player) {
        .x => .o,
        .o => .x,
    };

    rerender.force(); // ⬅ Trigger a full re‑render via the signal
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
                .display = .flex, // 👈 Add the flex
                .border_color = .hex("#CCCCCC"),
                .height = .percent(33),
                .width = .percent(33),
                .border_thickness = .all(1),
                .padding = .all(24),
            })({
                if (box.clicked) switch (box.player) {
                    .x => drawX(),
                    .o => drawO(),
                };
            });
        }
    });
}
